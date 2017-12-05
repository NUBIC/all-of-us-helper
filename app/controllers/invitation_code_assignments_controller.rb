class InvitationCodeAssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_patient, only: [:new, :create]

  def new
    @invitation_codes = load_invitation_codes
    @invitation_code_assignment = @patient.invitation_code_assignments.build
  end

  def create
    # authorize Repository
    @invitation_code_assignment = @patient.invitation_code_assignments.new(invitation_code_assignment_params)

    if @invitation_code_assignment.save
      flash[:success] = 'You have successfully created an invitation code assignment.'
      redirect_to patients_url(@patient)
    else
      @invitation_codes = load_invitation_codes
      flash.now[:alert] = 'Failed to create an invitation code assignment.'
      render action: 'new'
    end
  end

  private
    def load_invitation_codes
      @invitaiton_codes = InvitationCode.where(assignment_status: InvitationCode::ASSIGNMENT_STATUS_UNASSIGNED).map { |invitation_code| [invitation_code.code, invitation_code.id] }
    end

    def invitation_code_assignment_params
      params.require(:invitation_code_assignment).permit(:invitation_code_id)
    end

    def load_patient
      @patient = Patient.find(params[:patient_id])
    end
end