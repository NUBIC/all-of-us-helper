class Patient < ApplicationRecord
  has_paper_trail
  has_many :invitation_code_assignments
  has_many :matches
  has_and_belongs_to_many :races
  has_one :patient_empi_match

  ERROR_MESSAGE_FAILED_TO_ASSIGN_INVITATION_CODE = 'Failed to assign an invitation code.'

  REGISTRATION_STATUS_UNMATCHED = 'unmatched'
  REGISTRATION_STATUS_MATCHED = 'matched'
  REGISTRATION_STATUS_READY = 'ready'
  REGISTRATION_STATUS_REGISTERED = 'registered'
  REGISTRATION_STATUSES = [REGISTRATION_STATUS_UNMATCHED, REGISTRATION_STATUS_MATCHED, REGISTRATION_STATUS_READY, REGISTRATION_STATUS_REGISTERED]

  ETHNICITY_HISPANIC_OR_LATINO = 'Hispanic or Latino'
  ETHNICITY_NOT_HISPANIC_OR_LATINO = 'Not Hispanic or Latino'
  ETHNICITY_UNKNOWN_OR_NOT_REPORTED = 'Unknown or Not Reported'
  ETHNICITIES = [ETHNICITY_HISPANIC_OR_LATINO, ETHNICITY_NOT_HISPANIC_OR_LATINO, ETHNICITY_UNKNOWN_OR_NOT_REPORTED]

  GENDER_MALE = 'Male'
  GENDER_FEMALE = 'Female'
  GENDER_UNKNOWN_OR_NOT_REPORTED = 'Unknown or Not Reported'
  GENDERS = [GENDER_MALE, GENDER_FEMALE, GENDER_UNKNOWN_OR_NOT_REPORTED]

  validates :pmi_id, uniqueness: { case_sensitive: false }, allow_blank: true

  after_initialize :set_defaults


  scope :by_registration_status, ->(registration_status) do
    if registration_status.present? && registration_status != 'all'
      where(registration_status: registration_status)
    end
  end

  scope :search_across_fields, ->(search_token, options={}) do
    if search_token
      search_token.downcase!
    end
    options = { sort_column: 'last_name', sort_direction: 'asc' }.merge(options)

    if search_token
      p = where(["lower(record_id) like ? OR lower(pmi_id) like ? OR lower(last_name) like ? OR lower(first_name) like ? OR lower(email) like ?", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%", "%#{search_token}%"])
    end

    sort = options[:sort_column] + ' ' + options[:sort_direction] + ', patients.id ASC'
    p = p.nil? ? order(sort) : p.order(sort)

    p
  end

  scope :no_previously_declined_match, -> do
    where('NOT EXISTS (SELECT 1 FROM matches JOIN health_pros ON matches.health_pro_id = health_pros.id WHERE patients.id = matches.patient_id AND matches.status = ?)', Match::STATUS_DECLINED)
  end

  scope :by_matchable_criteria, ->(first_name, last_name) do
    where('registration_status = ? AND pmi_id IS NULL AND lower(first_name) = ? AND lower(last_name) = ?', Patient::REGISTRATION_STATUS_UNMATCHED, first_name.try(:downcase), last_name.try(:downcase))
  end

  def accepted_match
    matches.where(status: Match::STATUS_ACCEPTED).first
  end

  def invitation_code
     if invitation_code_assignments.is_active.any?
       invitation_code_assignments.is_active.first.invitation_code.code
     end
  end

  def full_name
    name = [first_name, last_name].compact.join(' ')
  end

  def self.create_or_update!(patient)
    p = Patient.where(record_id: patient['record_id']).first
    if p
      p.attributes = patient
    else
      p = Patient.new(record_id: patient['record_id'], first_name: patient['first_name'], last_name: patient['last_name'], email: patient['email'])
    end

    p.save!
    p
  end

  def assign_invitation_code(redcap_api, invitation_code=nil)
    invitation_code_assignment = nil
    if invitation_code.blank?
      invitation_code = InvitationCode.get_unassigned_invitation_code
    end

    begin
      Patient.transaction do
        redcap_patient_invitation_code = redcap_api.assign_invitation_code(record_id, invitation_code.code)
        raise "Error assigning invitation code #{invitation_code.code} to record_id #{record_id}." if redcap_patient_invitation_code[:error].present?
        invitation_code_assignment = invitation_code_assignments.build(invitation_code: invitation_code)
        save!
      end
    rescue Exception => e
      invitation_code_assignment = nil
      Rails.logger.info(e.class)
      Rails.logger.info(e.message)
      Rails.logger.info(e.backtrace.join("\n"))
    end
    invitation_code_assignment
  end

  def demographics_ready?
    nmhc_mrn.present? && ethnicity.present? && gender.present? && races.any?
  end

  def ready?
    accepted_match && general_consent_status == HealthPro::YES && general_consent_date.present? && ehr_consent_status == HealthPro::YES && ehr_consent_date.present? && withdrawal_status == HealthPro::NO && withdrawal_date.blank? && biospecimens_location  == HealthPro::BIOSPECIMEN_LOCATION_NORTHWESTERN
  end

  def set_registration_status
    self.registration_status = determine_registration_status
  end

  def determine_registration_status
    determined = nil
    currently_ready = ready?


    if currently_ready
      determined = case registration_status
                   when Patient::REGISTRATION_STATUS_UNMATCHED, Patient::REGISTRATION_STATUS_READY
                     Patient::REGISTRATION_STATUS_READY

                   when Patient::REGISTRATION_STATUS_READY
                     Patient::REGISTRATION_STATUS_READY
                   end
    else
      determined = case registration_status
                   when Patient::REGISTRATION_STATUS_UNMATCHED, Patient::REGISTRATION_STATUS_READY, Patient::REGISTRATION_STATUS_REGISTERED
                     Patient::REGISTRATION_STATUS_MATCHED
                   end
    end
    determined
  end

  def registered?
    [Patient::REGISTRATION_STATUS_REGISTERED].include?(self.registration_status)
  end

  def match
    if matches.any?
      matches.first
    end
  end

  private
    def set_defaults
      if self.new_record? &&
        if self.registration_status.blank?
          self.registration_status = Patient::REGISTRATION_STATUS_UNMATCHED
        end
        uuid = UUID.new
        self.uuid = uuid.generate
      end
    end
end