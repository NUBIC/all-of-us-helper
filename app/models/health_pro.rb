class HealthPro < ApplicationRecord
  has_paper_trail
  belongs_to :batch_health_pro
  has_many :matches

  STATUS_PENDING              = 'pending'
  STATUS_PREVIOUSLY_MATCHED   = 'previously matched'
  STATUS_MATCHABLE            = 'matchable'
  STATUS_UNMATCHABLE          = 'unmatchable'
  STATUS_MATCHED              = 'matched'
  STATUS_DECLINED             = 'declined'
  STATUSES = [STATUS_MATCHABLE, STATUS_UNMATCHABLE, STATUS_MATCHED, STATUS_PREVIOUSLY_MATCHED, STATUS_DECLINED]

  SEX_MALE = 'Male'
  SEX_FEMALE = 'Female'
  SEX_INTERSEX = 'Intersex'
  SEX_NONE = 'None of these describe me (optional free text)'
  SEXES = [SEX_MALE, SEX_FEMALE, SEX_INTERSEX, SEX_NONE]

  YES = '1'
  NO = '0'

  BIOSPECIMEN_LOCATION_NORTHWESTERN =   'nwfeinberggalter'

  after_initialize :set_defaults

  scope :by_status, ->(status) do
    if status.present?
     where(status: status)
    end
  end

  scope :search_across_fields, ->(search_token, options={}) do
    if search_token
      search_token.downcase!
    end
    options = { sort_column: 'last_name', sort_direction: 'asc' }.merge(options)

    if search_token
      p = where(["lower(pmi_id) like ? OR lower(last_name) like ? OR lower(first_name) like ? OR lower(email) like ? OR lower(street_address) like ? OR lower(city) like ? OR lower(state) like ? OR lower(zip) like ?", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%"])
    end

    sort = options[:sort_column] + ' ' + options[:sort_direction] + ', health_pros.id ASC'
    p = p.nil? ? order(sort) : p.order(sort)

    p
  end

  def determine_matches
    matched_pmi_patients = Patient.where(pmi_id: self.pmi_id)
    matched_demographic_patients = Patient.where('NOT EXISTS (SELECT 1 FROM matches JOIN health_pros ON matches.health_pro_id = health_pros.id WHERE patients.id = matches.patient_id AND matches.status = ?)', Match::STATUS_DECLINED).where('registration_status = ? AND pmi_id IS NULL AND lower(first_name) = ? AND lower(last_name) = ?', Patient::REGISTRATION_STATUS_UNMATCHED, self.first_name.try(:downcase), self.last_name.try(:downcase))
    if matched_pmi_patients.count == 1
      self.status = HealthPro::STATUS_PREVIOUSLY_MATCHED
    elsif matched_demographic_patients.size > 0
      self.status = HealthPro::STATUS_MATCHABLE
      matched_demographic_patients.each do |matched_demographic_patient|
        matches.build(patient: matched_demographic_patient)
      end
    else
      self.status = HealthPro::STATUS_UNMATCHABLE
    end
  end

  def matchable?
    self.status == HealthPro::STATUS_MATCHABLE
  end

  def address
    [self.street_address, self.city, self.state, self.zip].compact.join(', ')
  end

  def pending_matches?
    pending_matches.any?
  end

  def pending_matches
    matches.by_status(Match::STATUS_PENDING)
  end

  def sex_to_patient_gender
    mapped = Patient::GENDERS.detect { |gender| gender == self.sex }
    if mapped.present?
      mapped
    else
      Patient::GENDER_UNKNOWN_OR_NOT_REPORTED
    end
  end

  private
    def set_defaults
      if self.new_record? && self.status.blank?
        self.status = HealthPro::STATUS_PENDING
      end
    end
end