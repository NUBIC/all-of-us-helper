require 'redcap_api'
class MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_match, only: [:accept, :decline]

  def accept
    authorize @match
    redcap_api = initialize_redcap_api
    if @match.accept!(redcap_api, match_params)
      flash[:success] = 'You have successfully made a match.'
    else
      flash[:alert] = 'Failed to make a match.'
    end
  end

  def decline
    authorize @match
    redcap_api = initialize_redcap_api
    if @match.decline!(redcap_api)
      flash[:success] = 'You have successfully declined a match.'
    else
      flash[:alert] = 'Failed to decline a match.'
    end
  end

  def create
    @unmatched_patients = Patient.not_deleted.by_registration_status(Patient::REGISTRATION_STATUS_UNMATCHED).map { |patient| ["#{patient.full_name} (#{patient.email})", patient.id] }
    @health_pro = HealthPro.find(match_params[:health_pro_id])
    @health_pro.status = HealthPro::STATUS_MATCHED
    if match_params[:patient_id].present?
      patient = Patient.not_deleted.find(match_params[:patient_id])
      patient.pmi_id = @health_pro.pmi_id
      patient.birth_date = Date.parse(@health_pro.date_of_birth)
      patient.general_consent_status = @health_pro.general_consent_status
      patient.general_consent_date = @health_pro.general_consent_date
      patient.ehr_consent_status = @health_pro.ehr_consent_status
      patient.ehr_consent_date = @health_pro.ehr_consent_date
      patient.withdrawal_status = @health_pro.withdrawal_status
      patient.withdrawal_date = @health_pro.withdrawal_date
      patient.biospecimens_location = @health_pro.biospecimens_location
      patient.participant_status = @health_pro.participant_status
      patient.paired_site = @health_pro.paired_site
      patient.paired_organization = @health_pro.paired_organization
      patient.physical_measurements_completion_date = @health_pro.physical_measurements_completion_date
    end

    @match = Match.new(health_pro_id: match_params[:health_pro_id], patient_id: match_params[:patient_id], status: Match::STATUS_ACCEPTED)

    if match_params[:empi_match_id].present? && match_params[:patient_id].present?
      empi_match = EmpiMatch.find(match_params[:empi_match_id])
      patient.gender =  empi_match.gender
      patient.nmhc_mrn = empi_match.nmhc_mrn
      patient.ethnicity = empi_match.ethnicity if empi_match.ethnicity
      empi_match.empi_race_matches.each do |empi_race_match|
        patient.races << empi_race_match.race
      end
      patient.build_patient_empi_match(empi_match: empi_match)
    end

    begin
      Match.transaction do
        @match.save!
        @health_pro.save!
        patient.save!
        patient.set_registration_status
        patient.save!
        redcap_api = RedcapApi.initialize_redcap_api
        redcap_match = redcap_api.match(patient.record_id, @health_pro.pmi_id, @health_pro.general_consent_status, @health_pro.general_consent_date, @health_pro.ehr_consent_status, @health_pro.ehr_consent_date, @health_pro.withdrawal_status, @health_pro.withdrawal_date, @health_pro.participant_status, @health_pro.physical_measurements_completion_date, @health_pro.paired_site, @health_pro.paired_organization)
        raise "Error assigning pmi_id #{@health_pro.pmi_id} to record_id #{patient.record_id}." if redcap_match[:error].present?
      end
      flash[:success] = 'You have successfully added a match.'
    rescue Exception => e
      Rails.logger.info(e.class)
      Rails.logger.info(e.message)
      Rails.logger.info(e.backtrace.join("\n"))
      flash[:alert] = 'Failed to add a match.'
    end
  end

  private
    def match_params
      params.require(:match).permit(:empi_match_id, :health_pro_id, :patient_id)
    end

    def load_match
      @match = Match.find(params[:id])
    end
end