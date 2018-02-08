class Patient < ApplicationRecord
  has_many :invitation_code_assignments
  has_many :matches
  ERROR_MESSAGE_FAILED_TO_ASSIGN_INVITATION_CODE = 'Failed to assign an invitation code.'

  validates :pmi_id, uniqueness: { case_sensitive: false }, allow_blank: true

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
end