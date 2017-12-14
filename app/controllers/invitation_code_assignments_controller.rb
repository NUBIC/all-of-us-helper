class InvitationCodeAssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_patient, only: [:create]

  def create
    redcap_api = initalize_redcap_api
    if @patient.assign_invitation_code(redcap_api)
      flash[:success] = 'You have successfully assigned an invitation code.'
    else
      flash[:alert] = 'Failed to assign an invitation code.'
    end
    redirect_to patient_url(@patient)
  end

  private
    def invitation_code_assignment_params
      params.require(:invitation_code_assignment).permit(:invitation_code_id)
    end

    def load_patient
      @patient = Patient.find(params[:patient_id])
    end
end