class InvitationCodeAssignment < ApplicationRecord
  has_paper_trail
  belongs_to :patient
  belongs_to :invitation_code

  validates_presence_of :invitation_code_id

  after_initialize :set_defaults
  after_create :inactivate_other_assignments, :set_invitation_code_assignment_status

  scope :is_active, -> do
    where(active: true)
  end

  scope :is_inactive, -> do
    where(active: false)
  end

  private
    def set_defaults
      if self.new_record? && self.active.nil?
        self.active = true
      end
    end

    def inactivate_other_assignments
      patient.invitation_code_assignments.reject { |invitation_code_assignment| invitation_code_assignment == self }.each do |invitation_code_assignment|
        invitation_code_assignment.active = false
        invitation_code_assignment.save!
      end
    end

    def set_invitation_code_assignment_status
      invitation_code.assignment_status = InvitationCode::ASSIGNMENT_STATUS_ASSIGNED
      invitation_code.save!
    end
end