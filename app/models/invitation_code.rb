class InvitationCode < ApplicationRecord
  has_one :invitation_code_assignment

  ASSIGNMENT_STATUS_UNASSIGNED = 'Unassigned'
  ASSIGNMENT_STATUS_ASSIGNED = 'Assigned'
  ASSIGNMENT_STATUSES = [ASSIGNMENT_STATUS_UNASSIGNED, ASSIGNMENT_STATUS_ASSIGNED]

  after_initialize :set_defaults

  scope :search_across_fields, ->(search_token, options={}) do
    if search_token
      search_token.downcase!
    end
    options = { sort_column: 'code', sort_direction: 'asc' }.merge(options)

    if search_token
      ic = where(["lower(code) like ?", "%#{search_token}%"])
    end

    sort = options[:sort_column] + ' ' + options[:sort_direction] + ', invitation_codes.id ASC'
    ic = ic.nil? ? order(sort) : ic.order(sort)

    ic
  end

  scope :by_assignment_status, ->(assignment_status) do
    if assignment_status.present?
     where(assignment_status: assignment_status)
    end
  end

  def self.get_unassigned_invitation_code
    invitation_code = nil
    unassigned_invitation_codes = InvitationCode.by_assignment_status(InvitationCode::ASSIGNMENT_STATUS_UNASSIGNED)

    if unassigned_invitation_codes.any?
      invitation_code = unassigned_invitation_codes[Random.rand(0..(unassigned_invitation_codes.size-1))]
    end
    invitation_code
  end

  private
    def set_defaults
      if self.new_record? && self.assignment_status.blank?
        self.assignment_status = ASSIGNMENT_STATUS_UNASSIGNED
      end
    end
end