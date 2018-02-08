require 'redcap_api'
class PatientsController < ApplicationController
  PATIENT_CONTROLLER_SHOW_REDCAP_ERROR = 'Failed to communicate with REDCap.'
  before_action :authenticate_user!
  before_action :load_patient, only: [:show]
  helper_method :sort_column, :sort_direction

  def index
    authorize Patient
    params[:page]||= 1
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction
    @patients = Patient.search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def show
    authorize @patient
    @invitation_code_assignment = @patient.invitation_code_assignments.build
  end

  def record_id
    authorize Patient
    redcap_api = initialize_redcap_api
    @patient = Patient.where(record_id: params[:record_id]).first

    if @patient.blank?
      redcap_patient_response = redcap_api.patient(params[:record_id])
      if redcap_patient_response[:error].present?
        flash[:alert] = PATIENT_CONTROLLER_SHOW_REDCAP_ERROR
        redirect_to root_url and return
      end

      @patient = Patient.create_or_update!(redcap_patient_response[:response].slice('record_id', 'first_name', 'last_name', 'email'))
    end

    redirect_to patient_url(@patient)
  end

  private
    def patient_params
      params.require(:patient).permit(:record_id, :first_name, :last_name, :email)
    end

    def load_patient
      @patient = Patient.find(params[:id])
    end

    def sort_column
      ['record_id', 'pmi_id', 'first_name', 'email', 'last_name'].include?(params[:sort]) ? params[:sort] : 'last_name'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end
end