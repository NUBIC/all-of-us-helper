require 'redcap_api'
require 'study_tracker_api'
class PatientsController < ApplicationController
  PATIENT_CONTROLLER_SHOW_REDCAP_ERROR = 'Failed to communicate with REDCap.'
  before_action :authenticate_user!
  before_action :load_patient, only: [:show, :register, :update]
  helper_method :sort_column, :sort_direction

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

  def index
    authorize Patient
    params[:page]||= 1
    params[:registration_status]||= 'all'
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction
    @patients = Patient.search_across_fields(params[:search], options).by_registration_status(params[:registration_status]).paginate(per_page: 10, page: params[:page])
  end

  def create
    authorize Patient
    health_pro = HealthPro.find(patient_params[:health_pro_id])
    health_pro.status = HealthPro::STATUS_ADDED
    patient = Patient.new
    patient.first_name = health_pro.first_name
    patient.last_name = health_pro.last_name
    patient.email = health_pro.email
    patient.pmi_id = health_pro.pmi_id
    patient.gender = health_pro.sex_to_patient_gender
    patient.general_consent_status = health_pro.general_consent_status
    patient.general_consent_date = health_pro.general_consent_date
    patient.ehr_consent_status = health_pro.ehr_consent_status
    patient.ehr_consent_date = health_pro.ehr_consent_date
    patient.withdrawal_status = health_pro.withdrawal_status
    patient.withdrawal_date = health_pro.withdrawal_date
    patient.biospecimens_location = health_pro.biospecimens_location
    patient.birth_date = health_pro.date_of_birth
    patient.participant_status = health_pro.participant_status

    if patient_params[:empi_match_id].present?
      empi_match = EmpiMatch.find(patient_params[:empi_match_id])
      patient.gender =  empi_match.gender
      patient.nmhc_mrn = empi_match.nmhc_mrn
      patient.ethnicity = empi_match.ethnicity if empi_match.ethnicity
      empi_match.empi_race_matches.each do |empi_race_match|
        patient.races << empi_race_match.race
      end
      patient.build_patient_empi_match(empi_match: empi_match)
    end

    match = Match.new
    match.health_pro = health_pro
    match.status = Match::STATUS_ACCEPTED

    begin
      Patient.transaction do
        redcap_api = initialize_redcap_api
        redcap_patient = redcap_api.create_patient(patient.first_name, patient.last_name, patient.email, health_pro.phone, health_pro.pmi_id, health_pro.general_consent_status, health_pro.general_consent_date, health_pro.ehr_consent_status, health_pro.ehr_consent_date)
        raise "Error creating a patient pmi_id #{health_pro.pmi_id}." if redcap_patient[:error].present?
        record_id = redcap_patient[:response]
        patient.record_id = record_id
        patient.save!
        match.patient = patient
        health_pro.save!
        match.save!
        patient.set_registration_status
        patient.save!
      end
      flash[:success] = 'You have successfully added a match.'
    rescue Exception => e
      Rails.logger.info(e.class)
      Rails.logger.info(e.message)
      Rails.logger.info(e.backtrace.join("\n"))
      flash[:alert] = 'Failed to add a match.'
    end
  end

  def show
    authorize @patient
    @invitation_code_assignment = @patient.invitation_code_assignments.build
  end

  def update
    authorize @patient
    options = {}
    options[:proxy_user] = current_user.username
    error = nil
    if @patient.update_attributes(patient_params)
      if @patient.registered?
        study_tracker_api = initialize_study_tracker_api
        registraion_results = study_tracker_api.register(options, @patient)
        error = registraion_results[:error]
      end
    else
      error = 'Patient could not be updated.'
    end

    if error.nil?
      flash[:success] = 'You have successfully updated a patient.'
      redirect_to patient_url(@patient)
    else
      flash.now[:alert] = "Failed to update patient: #{error}."
      render action: 'show'
    end
  end

  def register
    authorize Patient
    options = {}
    options[:proxy_user] = current_user.username
    study_tracker_api = initialize_study_tracker_api
    registration_results = study_tracker_api.register(options, @patient)

    if registration_results[:error].present?
      flash[:alert] = "Failed to register the patient."
    else
      @patient.registration_status = Patient::REGISTRATION_STATUS_REGISTERED
      @patient.save!
      flash[:success] = 'You have successfully registered a patient.'
    end
    redirect_to patient_url(@patient)
  end

  private
    def patient_params
      params.require(:patient).permit(:record_id, :first_name, :last_name, :email, :gender, :ethnicity, :nmhc_mrn, :empi_match_id, :health_pro_id, { race_ids:[] })
    end

    def load_patient
      @patient = Patient.find(params[:id])
    end

    def sort_column
      ['record_id', 'pmi_id', 'first_name', 'email', 'last_name', 'registration_status'].include?(params[:sort]) ? params[:sort] : 'last_name'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end
end