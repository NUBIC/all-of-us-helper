class ApiMetadata < ApplicationRecord
  API_OPERATION_REDCAP_RECRUITMENT_PATIENTS = 'REDCap Recruitment Patients'
  API_OPERATION_REDCAP_RECRUITMENT_UPDATE_PATIENT = 'REDCap Update Patient'
  API_OPERATION_STUDY_TRACKER_COHORTS = 'Study Tracker Cohorts'
  API_OPERATIONS = [API_OPERATION_REDCAP_RECRUITMENT_PATIENTS, API_OPERATION_REDCAP_RECRUITMENT_UPDATE_PATIENT, API_OPERATION_STUDY_TRACKER_COHORTS]

  def self.last_called_at_by_api_operation(api_operation)
    api_metadata = ApiMetadata.where(api_operation: api_operation).first
    if api_metadata.present?
      api_metadata.last_called_at
    end
  end

  def self.update_last_called_at(api_operation, last_called_at = nil)
    if last_called_at.blank?
      last_called_at = Date.today
    end
    api_metadata = ApiMetadata.where(api_operation: api_operation).first

    if api_metadata.blank?
      ApiMetadata.create!(system: StudyTrackerApi::SYSTEM, api_operation: api_operation, last_called_at: last_called_at)
    else
      api_metadata.last_called_at = last_called_at
      api_metadata.save!
    end
  end
end