require 'redcap_api'
require 'health_pro_api'
require 'redcap_api'
namespace :health_pro_api_migrate do
  desc "Health Pro API migration"
  # RAILS_ENV=staging bundle exec rake health_pro_api_migrate:migrate["?"]
  task :migrate, [:pmi_id] => [:environment] do |t, args|
    begin
      redcap_api = RedcapApi.initialize_redcap_api
      if !args[:pmi_id].present?
        batch_health_pro = BatchHealthPro.new
        batch_health_pro.batch_type = BatchHealthPro::BATCH_TYPE_HEALTH_PRO_API
        batch_health_pro.health_pro_file = nil
        batch_health_pro.created_user = 'mjg994'
        batch_health_pro.save!
        batch_health_pro.import_api(update_previously_matched: false)
        patients = Patient.all
      else
        # batch_health_pro = BatchHealthPro.last
        # patients = Patient.where(pmi_id: args[:pmi_id]).all
        batch_health_pro = BatchHealthPro.new
        batch_health_pro.batch_type = BatchHealthPro::BATCH_TYPE_HEALTH_PRO_API
        batch_health_pro.health_pro_file = nil
        batch_health_pro.created_user = 'mjg994'
        batch_health_pro.save!
        pmi_id = args[:pmi_id]
        pmi_id.gsub!('P','')
        pmi_id = pmi_id.to_i
        batch_health_pro.import_api(update_previously_matched: false, participantId: pmi_id)
        patients = Patient.where(pmi_id: args[:pmi_id]).all
      end

      patients.each do |patient|
        puts "Step 1: here is the copying of the patient: #{patient.pmi_id}."
        patient_health_pro_api_migration = PatientHealthProApiMigration.new
        patient_health_pro_api_migration.record_id = patient.record_id
        patient_health_pro_api_migration.first_name = patient.first_name
        patient_health_pro_api_migration.last_name = patient.last_name
        patient_health_pro_api_migration.email = patient.email
        patient_health_pro_api_migration.pmi_id = patient.pmi_id
        patient_health_pro_api_migration.gender = patient.gender
        patient_health_pro_api_migration.nmhc_mrn = patient.nmhc_mrn
        patient_health_pro_api_migration.registration_status = patient.registration_status
        patient_health_pro_api_migration.general_consent_status = patient.general_consent_status
        patient_health_pro_api_migration.general_consent_date = patient.general_consent_date
        patient_health_pro_api_migration.ehr_consent_status = patient.ehr_consent_status
        patient_health_pro_api_migration.ehr_consent_date = patient.ehr_consent_date
        patient_health_pro_api_migration.withdrawal_status = patient.withdrawal_status
        patient_health_pro_api_migration.withdrawal_date = patient.withdrawal_date
        patient_health_pro_api_migration.biospecimens_location = patient.biospecimens_location
        patient_health_pro_api_migration.uuid = patient.uuid
        patient_health_pro_api_migration.birth_date = patient.birth_date
        patient_health_pro_api_migration.ethnicity = patient.ethnicity
        patient_health_pro_api_migration.participant_status = patient.participant_status
        patient_health_pro_api_migration.deleted_at = patient.deleted_at
        patient_health_pro_api_migration.physical_measurements_completion_date = patient.physical_measurements_completion_date
        patient_health_pro_api_migration.paired_site = patient.paired_site
        patient_health_pro_api_migration.paired_organization = patient.paired_organization
        patient_health_pro_api_migration.health_pro_email = patient.health_pro_email
        patient_health_pro_api_migration.health_pro_login_phone = patient.health_pro_login_phone
        patient_health_pro_api_migration.phone_1 = patient.phone_1
        patient_health_pro_api_migration.health_pro_api_migrated = patient.health_pro_api_migrated
        patient_health_pro_api_migration.save!

        puts "Step 2: here is the start of the patient update: #{patient.pmi_id}."
        health_pro = HealthPro.where("batch_health_pro_id = ? AND pmi_id = ?",  batch_health_pro.id, patient.pmi_id).first
        if health_pro.present?
          patient.first_name = health_pro.first_name
          patient.last_name = health_pro.last_name
          patient.birth_date = Date.parse(health_pro.date_of_birth) if health_pro.date_of_birth.present?
          patient.gender = health_pro.sex_to_patient_gender
          patient.general_consent_status = health_pro.general_consent_status
          patient.general_consent_date = health_pro.general_consent_date
          patient.ehr_consent_status = health_pro.ehr_consent_status
          patient.ehr_consent_date = health_pro.ehr_consent_date
          patient.withdrawal_status = health_pro.withdrawal_status
          patient.withdrawal_date = health_pro.withdrawal_date
          patient.biospecimens_location = health_pro.biospecimens_location
          patient.participant_status = health_pro.participant_status
          patient.physical_measurements_completion_date = health_pro.physical_measurements_completion_date
          patient.paired_site = health_pro.paired_site
          patient.paired_organization = health_pro.paired_organization
          patient.health_pro_email = health_pro.email
          patient.health_pro_phone = health_pro.phone
          patient.health_pro_login_phone = health_pro.login_phone
          patient.genomic_consent_status = health_pro.consent_for_genomics_ror
          patient.genomic_consent_status_date = health_pro.consent_for_genomics_ror_date
          patient.questionnaire_on_cope_may = health_pro.questionnaire_on_cope_may
          patient.questionnaire_on_cope_may_time = health_pro.questionnaire_on_cope_may_time
          patient.questionnaire_on_cope_june = health_pro.questionnaire_on_cope_june
          patient.questionnaire_on_cope_june_time = health_pro.questionnaire_on_cope_june_time
          patient.questionnaire_on_cope_july = health_pro.questionnaire_on_cope_july
          patient.questionnaire_on_cope_july_authored = health_pro.questionnaire_on_cope_july_authored
          patient.core_participant_date = health_pro.core_participant_date
          patient.deactivation_status = health_pro.deactivation_status
          patient.deactivation_date = health_pro.deactivation_date
          patient.required_ppi_surveys_complete = health_pro.required_ppi_surveys_complete
          patient.completed_surveys = health_pro.completed_surveys
          patient.basics_ppi_survey_complete = health_pro.basics_ppi_survey_complete
          patient.basics_ppi_survey_completion_date = health_pro.basics_ppi_survey_completion_date
          patient.health_ppi_survey_complete = health_pro.health_ppi_survey_complete
          patient.health_ppi_survey_completion_date = health_pro.health_ppi_survey_completion_date
          patient.lifestyle_ppi_survey_complete = health_pro.lifestyle_ppi_survey_complete
          patient.lifestyle_ppi_survey_completion_date = health_pro.lifestyle_ppi_survey_completion_date
          patient.hist_ppi_survey_complete = health_pro.hist_ppi_survey_complete
          patient.hist_ppi_survey_completion_date = health_pro.hist_ppi_survey_completion_date
          patient.meds_ppi_survey_complete = health_pro.meds_ppi_survey_complete
          patient.meds_ppi_survey_completion_date = health_pro.meds_ppi_survey_completion_date
          patient.family_ppi_survey_complete = health_pro.family_ppi_survey_complete
          patient.family_ppi_survey_completion_date = health_pro.family_ppi_survey_completion_date
          patient.access_ppi_survey_complete = health_pro.access_ppi_survey_complete
          patient.access_ppi_survey_completion_date = health_pro.access_ppi_survey_completion_date
          patient.health_pro_api_migrated = true
          patient.save!
          sleep(1)
          puts "Step 3: here is the REDCap update: #{patient.pmi_id}."
          redcap_patient = redcap_api.update_patient(patient.record_id, patient.general_consent_status, patient.general_consent_date, patient.ehr_consent_status, patient.ehr_consent_date, patient.withdrawal_status, patient.withdrawal_date, patient.participant_status, patient.physical_measurements_completion_date, patient.paired_site, patient.paired_organization, patient.health_pro_email, patient.health_pro_phone, patient.health_pro_login_phone, patient.genomic_consent_status, patient.genomic_consent_status_date, patient.core_participant_date, patient.deactivation_status, patient.deactivation_date, patient.required_ppi_surveys_complete, patient.completed_surveys, patient.basics_ppi_survey_complete, patient.basics_ppi_survey_completion_date, patient.health_ppi_survey_complete, patient.health_ppi_survey_completion_date, patient.lifestyle_ppi_survey_complete, patient.lifestyle_ppi_survey_completion_date, patient.hist_ppi_survey_complete, patient.hist_ppi_survey_completion_date, patient.meds_ppi_survey_complete, patient.meds_ppi_survey_completion_date, patient.family_ppi_survey_complete, patient.family_ppi_survey_completion_date, patient.access_ppi_survey_complete, patient.access_ppi_survey_completion_date, patient.questionnaire_on_cope_may, patient.questionnaire_on_cope_may_time, patient.questionnaire_on_cope_june, patient.questionnaire_on_cope_june_time, patient.questionnaire_on_cope_july, patient.questionnaire_on_cope_july_authored)
        end
      end
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