require 'csv'
require 'study_tracker_api'
require 'redcap_api'
namespace :migrate do
  desc "Synch uuid"
  task(synch_uuid: :environment) do |t, args|
    subjects = CSV.new(File.open('lib/setup/data/STU00204480_subjects.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    subjects.each do |subject|
      patient = Patient.where(pmi_id: subject.to_hash['case_number'].strip)
      if patient
        patient.uuid = subject.to_hash['uuid']
        patient.save!
      end
    end
  end

  desc "Accept matches"
  task(auto_accept_matches: :environment) do |t, args|
    subjects = CSV.new(File.open('lib/setup/data/STU00204480_subjects.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    pmi_ids = subjects.map { |subject| subject.to_hash['case number'].strip  }
    batch_health_pro = BatchHealthPro.last
    health_pros = HealthPro.where(batch_health_pro_id: batch_health_pro.id, pmi_id: pmi_ids, status: HealthPro::STATUS_MATCHABLE)

    health_pros.each do |health_pro|
      puts health_pro.matches.size
      puts health_pro.empi_matches.size
      if health_pro.matches.size == 1 && health_pro.empi_matches.size == 1
        match = health_pro.matches.first
        redcap_api = RedcapApi.initialize_redcap_api
        match_params = {}
        match_params[:empi_match_id] = health_pro.empi_matches.first.id
        match.accept!(redcap_api,  match_params)
      end
    end
  end

  desc "Patients final"
  task(patients_final: :environment) do |t, args|
    subjects = CSV.new(File.open('lib/setup/data/STU00204480_subjects.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    pmi_ids = subjects.map { |subject| subject.to_hash['case number']  }
    missing_pmi_ids = pmi_ids - Patient.all.map(&:pmi_id)
    batch_health_pro = BatchHealthPro.last
    health_pros = HealthPro.where(batch_health_pro_id: batch_health_pro.id, pmi_id: pmi_ids, status: HealthPro::STATUS_MATCHABLE)

    missing_pmi_ids.each do |missing_pmi_id|
      puts "processing: #{missing_pmi_id}"
      health_pro = HealthPro.where(batch_health_pro_id: batch_health_pro.id, pmi_id: missing_pmi_id).first
      if health_pro.present?
        subjects = CSV.new(File.open('lib/setup/data/STU00204480_subjects.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
        subject = subjects.select { |subject| subject.to_hash['case number'] == missing_pmi_id }.first
        puts subject.to_hash['case number']
        patient = Patient.new
        patient.first_name = health_pro.first_name
        patient.last_name = health_pro.last_name
        patient.uuid = subject.to_h['uuid']
        patient.pmi_id = health_pro.pmi_id
        patient.birth_date = Date.parse(health_pro.date_of_birth)
        patient.general_consent_status = health_pro.general_consent_status
        patient.general_consent_date = health_pro.general_consent_date
        patient.ehr_consent_status = health_pro.ehr_consent_status
        patient.ehr_consent_date = health_pro.ehr_consent_date
        patient.withdrawal_status = health_pro.withdrawal_status
        patient.withdrawal_date = health_pro.withdrawal_date
        patient.biospecimens_location = health_pro.biospecimens_location
        patient.gender = subject.to_h['gender']
        patient.nmhc_mrn = subject.to_h['nmhc_record_number']
        patient.ethnicity = subject.to_h['ethnicity']
        patient.record_id = health_pro.pmi_id
        patient.email = health_pro.email

        subject.to_h['races'].split(',').each do |race|
          race = Race.where(name: race).first
          patient.races << race
        end

        patient.registration_status = Patient::REGISTRATION_STATUS_REGISTERED
        patient.save!
      else
        puts "#{missing_pmi_id} is not present in the latest health pro file"
      end
    end

    existing_patients = Patient.where(registration_status: [Patient::REGISTRATION_STATUS_MATCHED, Patient::REGISTRATION_STATUS_READY])
    existing_patients.each do |existing_patient|
      subjects = CSV.new(File.open('lib/setup/data/STU00204480_subjects.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
      subject = subjects.select { |subject| subject.to_hash['case number'] ==  existing_patient.pmi_id }.first
      existing_patient.uuid = subject.to_h['uuid']
      existing_patient.registration_status = Patient::REGISTRATION_STATUS_REGISTERED
      existing_patient.save!
    end
  end

  desc "Rollback patients to matched from registered"
  task(rollback_patients: :environment) do |t, args|
    Patient.where(registration_status: Patient::REGISTRATION_STATUS_REGISTERED, nmhc_mrn: '').each do |patient|
      patient.registration_status = Patient::REGISTRATION_STATUS_MATCHED
      patient.save!
    end
  end

  desc "Create matches for rollbacked patients"
  task(create_matches_for_rollbacked_patients: :environment) do |t, args|
    last_batch_health_pro_id = BatchHealthPro.maximum(:id)
    Patient.where(registration_status: Patient::REGISTRATION_STATUS_MATCHED).where('NOT EXISTS(SELECT 1 FROM matches WHERE patients.id = matches.patient_id)').each do |patient|
      health_pro = HealthPro.where(batch_health_pro_id: last_batch_health_pro_id, pmi_id: patient.pmi_id).first
      Match.create(health_pro_id: health_pro.id, patient_id: patient.id, status: Match::STATUS_ACCEPTED)
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