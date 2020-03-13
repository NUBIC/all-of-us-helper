require 'redcap_api'
require 'study_tracker_api'
namespace :recruitment do
  desc 'Load cohorts'
  task(load_cohorts: :environment) do  |t, args|
    begin
      last_called_at = ApiMetadata.last_called_at_by_api_operation(ApiMetadata::API_OPERATION_STUDY_TRACKER_COHORTS)
      if last_called_at.blank?
        last_called_at = Date.parse('1/1/1900')
      end

      last_called_at = last_called_at.to_date - 30
      study_tracker_api = StudyTrackerApi.new
      study_tracker_api.generate_token
      options = { 'current_status_after' =>  last_called_at }
      response = study_tracker_api.cohorts(options)
      cohorts = response[:response]
      options = { system: RedcapApi::SYSTEM_REDCAP_RECRUITMENT, api_token_type: ApiToken::API_TOKEN_TYPE_REDCAP_RECRUITMENT }
      redcap_api = RedcapApi.initialize_redcap_api(options)
      response = redcap_api.recruitment_patients
      recruitment_patients = response[:response]

      cohorts['cohorts'].each do |cohort|
        if cohort['identifier'].present?
          if cohort['identifier']['primary_record_number'].present?
            if cohort['identifier']['primary_record_number']['type'] == 'nmhc'
              puts cohort['identifier']['primary_record_number']['record_number']
              recruitment_patient = recruitment_patients.detect{ |recruitment_patient| recruitment_patient['mrn'] ==  cohort['identifier']['primary_record_number']['record_number'] }
              if recruitment_patient.present?
                st_event = cohort['current_status']['status']
                st_event_d = cohort['current_status']['date']
                st_import_d = cohort['status_history'].map { |status| status['date'].present? ? Date.parse(status['date']).to_s(:date) : nil}.compact.min
                redcap_api.update_recruitment_patient(recruitment_patient['record_id'], st_event, st_event_d, st_import_d)
              else
                mrn = cohort['identifier']['primary_record_number']['record_number'] || ''
                ApiError.create!(system: RedcapApi::SYSTEM_REDCAP_RECRUITMENT, api_operation: ApiMetadata::API_OPERATION_REDCAP_RECRUITMENT_UPDATE_PATIENT,  error: "The following NMHC MRN was not able to be found the All of Us MyChart Recruitment Tracking REDCap project: #{mrn}.")
              end
            end
          end
        end
      end
      ApiMetadata.update_last_called_at(ApiMetadata::API_OPERATION_STUDY_TRACKER_COHORTS)
    rescue => error
      handle_error(t, error)
    end
  end
end

def handle_error(t, error)
  puts error.class
  puts error.message
  puts error.backtrace.join("\n")

  Rails.logger.info(error.class)
  Rails.logger.info(error.message)
  Rails.logger.info(error.backtrace.join("\n"))
  ExceptionNotifier.notify_exception(error)
end