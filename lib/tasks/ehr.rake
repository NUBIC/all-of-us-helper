# consent date <  4/24/2018
#
# OR
#
# consent date >  6/7/2018

require 'csv'
namespace :ehr do
  desc "Validate consents"
  task(validate_consents: :environment) do  |t, args|
    subject_template = { pmi_id: nil, ehr_consent_date: nil, status: nil }
    vibrent_subjects_file = CSV.new(File.open('lib/setup/data/new_illinois_query_24_June_no_filters_corrected.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    vibrent_subjects = vibrent_subjects_file.map { |vibrent_subject| vibrent_subject.to_hash }
    vibrent_subjects_file = CSV.new(File.open('lib/setup/data/new_illinois_query_24_June_no_filters_corrected.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    invalid_vibrent_subjects = vibrent_subjects_file.select { |vibrent_subject| vibrent_subject.to_hash['questionnaire_id'].strip == '126' }
    puts vibrent_subjects.size
    puts invalid_vibrent_subjects.size

    invalid_subjects= []
    batch_health_pro = BatchHealthPro.last
    invalid_vibrent_subjects.each do |invalid_vibrent_subject|
      subject = subject_template.dup
      pmi_id = "P#{invalid_vibrent_subject.to_hash['participant_id']}"
      subject[:pmi_id] = pmi_id
      puts pmi_id
      health_pro = batch_health_pro.health_pros.where("pmi_id in (?)", pmi_id).first
      if health_pro.present?
        ehr_consent_date = Date.parse(health_pro.ehr_consent_date)
        subject[:ehr_consent_date] = ehr_consent_date
        puts ehr_consent_date
        if ehr_consent_date >= Date.parse('4/24/2018') && ehr_consent_date <= Date.parse('6/7/2018')
          puts "Invalid pmi_id #{pmi_id} is within the dark age."
          subject[:status] = 'Within the dark age'
        else
          puts "Invalid pmi_id #{pmi_id} has escaped the dark age."
          subject[:status] = 'Outside the dark age'
        end
      else
        subject[:ehr_consent_date] = nil
        subject[:status] = 'Disappeared.'
      end
      invalid_subjects << subject
    end

    headers = subject_template.keys
    row_header = CSV::Row.new(headers, headers, true)
    row_template = CSV::Row.new(headers, [], false)

    CSV.open('lib/setup/data_out/invalid_subjects.csv', "wb") do |csv|
      csv << row_header
      invalid_subjects.each do |subject|
        row = row_template.dup
        row[:pmi_id] = subject[:pmi_id]
        row[:ehr_consent_date] = subject[:ehr_consent_date]
        row[:status] = subject[:status]
        csv << row
      end
    end
  end

  desc 'Compare HelathPro to StudyTracker'
  task(compare_healthpro_to_study_tracker: :environment) do  |t, args|
    subjects = []
    subject_template = { source: nil, pmi_id: nil, biospecimens_location: nil, general_consent_status: nil, general_consent_date: nil, general_consent_status_st: nil, general_consent_date_st: nil,  ehr_consent_status: nil, ehr_consent_date: nil, ehr_consent_status_st: nil, ehr_consent_date_st: nil, withdrawal_status: nil, withdrawal_date: nil, withdrawal_status_st: nil, withdrawal_date_st: nil, nmhc_mrn: nil, status: nil, participant_status: nil }
    st_subjects = CSV.new(File.open('lib/setup/data/STU00204480_subjects.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    pmi_ids = st_subjects.map { |subject| subject.to_hash['case number']  }

    # batch_health_pro = BatchHealthPro.last
    health_pros = HealthPro.where(batch_health_pro_id: [142, 143])
    health_pros.where("pmi_id in (?)", pmi_ids).each do |health_pro|
    # batch_health_pro.health_pros.where("pmi_id in (?)", pmi_ids).each do |health_pro|
    # batch_health_pro.health_pros.where("pmi_id in (?) AND biospecimens_location = ? AND general_consent_status = '1' AND general_consent_date IS NOT NULL AND ehr_consent_status = '1' AND ehr_consent_date IS NOT NULL AND withdrawal_status = '0' AND withdrawal_date IS NULL", 'nwfeinberggalter').each do |health_pro|
      study_tracker_activities  = CSV.new(File.open('lib/setup/data/STU00204480_activities.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
      study_tracker_activities = study_tracker_activities.select { |study_tracker_activity| study_tracker_activity.to_hash['case number'] ==  health_pro.pmi_id }
      subject = subject_template.dup
      subject[:source] = 'HealthPro'
      subject[:pmi_id] = health_pro.pmi_id
      subject[:participant_status] = health_pro.participant_status
      subject[:biospecimens_location] = health_pro.biospecimens_location

      subject[:general_consent_status] = health_pro.general_consent_status
      subject[:general_consent_date] = Date.parse(health_pro.general_consent_date)
      study_tracker_activity_consented = study_tracker_activities.select { |study_tracker_activity| study_tracker_activity.to_hash['name'] == 'Consented' && study_tracker_activity.to_hash['date'].present? &&  study_tracker_activity.to_hash['state'] == 'completed' }.first
      if study_tracker_activity_consented
        subject[:nmhc_mrn] = study_tracker_activity_consented.to_hash['nmhc_record_number']
        subject[:general_consent_status_st] = '1'
        subject[:general_consent_date_st] = Date.parse(study_tracker_activity_consented.to_hash['date'])
      else
        subject[:general_consent_status_st] = '0'
      end

      subject[:ehr_consent_status] = health_pro.ehr_consent_status
      subject[:ehr_consent_date] = Date.parse(health_pro.ehr_consent_date) if health_pro.ehr_consent_date
      study_tracker_activity_ehr_consent = study_tracker_activities.select { |study_tracker_activity| study_tracker_activity.to_hash['name'] == 'EHR Consent' && study_tracker_activity.to_hash['date'].present? &&  study_tracker_activity.to_hash['state'] == 'completed' }.first
      if study_tracker_activity_ehr_consent
        subject[:ehr_consent_status_st] = '1'
        subject[:ehr_consent_date_st] = Date.parse(study_tracker_activity_ehr_consent.to_hash['date'])
      else
        subject[:ehr_consent_status_st] = '0'
      end

      subject[:withdrawal_status] = health_pro.withdrawal_status
      subject[:withdrawal_date] = Date.parse(health_pro.withdrawal_date) if health_pro.withdrawal_date
      study_tracker_activity_withdrawal = study_tracker_activities.select { |study_tracker_activity| study_tracker_activity.to_hash['name'] == 'Withdrawn' && study_tracker_activity.to_hash['date'].present? &&  study_tracker_activity.to_hash['state'] == 'completed' }.first
      if study_tracker_activity_withdrawal
        subject[:withdrawal_status_st] = '1'
        subject[:withdrawal_date_st] = Date.parse(study_tracker_activity_withdrawal.to_hash['date']) if study_tracker_activity_withdrawal.to_hash['date']
      else
        subject[:withdrawal_status_st] = '0'
      end

      if subject[:general_consent_status] == subject[:general_consent_status_st] &&
         subject[:general_consent_date] == subject[:general_consent_date_st] &&
         subject[:ehr_consent_status] == subject[:ehr_consent_status_st] &&
         subject[:ehr_consent_date] == subject[:ehr_consent_date_st] &&
         subject[:withdrawal_status] == subject[:withdrawal_status_st] &&
         subject[:withdrawal_date] == subject[:withdrawal_date_st]

         subject[:status] = 'matches'
       else
         puts 'begin'
         puts subject[:general_consent_status]
         puts subject[:general_consent_status_st]

         puts subject[:general_consent_date]
         puts subject[:general_consent_date_st]

         puts subject[:ehr_consent_status]
         puts subject[:ehr_consent_status_st]

         puts subject[:ehr_consent_date]
         puts subject[:ehr_consent_date_st]

         puts subject[:withdrawal_status]
         puts subject[:withdrawal_status_st]

         puts subject[:withdrawal_date]
         puts subject[:withdrawal_date_st]

         puts 'end'

         if match_status(subject[:general_consent_status], subject[:general_consent_date], subject[:general_consent_status_st], subject[:general_consent_date_st]) &&
            match_status(subject[:ehr_consent_status], subject[:ehr_consent_date], subject[:ehr_consent_status_st], subject[:ehr_consent_date_st]) &&
            match_status(subject[:withdrawal_status], subject[:withdrawal_date],subject[:withdrawal_status_st], subject[:withdrawal_date_st])

            subject[:status] = 'matches'
          else
            subject[:status] = 'mismatches'
          end
       end

      subjects << subject
    end

    study_tracker_activities  = CSV.new(File.open('lib/setup/data/STU00204480_activities.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
    study_tracker_activities = study_tracker_activities.reject { |study_tracker_activity| subjects.detect { |subject| subject[:pmi_id] == study_tracker_activity.to_hash['case number'] } }
    case_numbers = study_tracker_activities.map { |study_tracker_activity| study_tracker_activity.to_hash['case number']  }.uniq

    case_numbers.each do |case_number|
      case_number_study_tracker_activities = study_tracker_activities.select { |study_tracker_activity| study_tracker_activity.to_hash['case number'] == case_number }
      health_pro = health_pros.where(pmi_id: case_number).first

      subject = subject_template.dup
      subject[:source] = 'StudyTracker'
      subject[:pmi_id] = case_number
      subject[:participant_status] = health_pro.participant_status if health_pro
      subject[:biospecimens_location] = health_pro.biospecimens_location if health_pro

      subject[:general_consent_status] = health_pro.general_consent_status if health_pro
      subject[:general_consent_date] = Date.parse(health_pro.general_consent_date) if health_pro && health_pro.general_consent_date
      study_tracker_activity_consented = case_number_study_tracker_activities.select { |study_tracker_activity| study_tracker_activity.to_hash['name'] == 'Consented' && study_tracker_activity.to_hash['date'].present? &&  study_tracker_activity.to_hash['state'] == 'completed' }.first
      if study_tracker_activity_consented
        subject[:nmhc_mrn] = study_tracker_activity_consented.to_hash['nmhc_record_number']
        subject[:general_consent_status_st] = '1'
        subject[:general_consent_date_st] = Date.parse(study_tracker_activity_consented.to_hash['date']) if study_tracker_activity_consented.to_hash['date']
      else
        subject[:general_consent_status_st] = '0'
      end

      subject[:ehr_consent_status] = health_pro.ehr_consent_status if health_pro
      subject[:ehr_consent_date] = Date.parse(health_pro.ehr_consent_date) if health_pro && health_pro.ehr_consent_date
      study_tracker_activity_ehr_consent = case_number_study_tracker_activities.select { |study_tracker_activity| study_tracker_activity.to_hash['name'] == 'EHR Consent' && study_tracker_activity.to_hash['date'].present? &&  study_tracker_activity.to_hash['state'] == 'completed' }.first
      if study_tracker_activity_ehr_consent
        subject[:ehr_consent_status_st] = '1'
        subject[:ehr_consent_date_st] = Date.parse(study_tracker_activity_ehr_consent.to_hash['date']) if study_tracker_activity_ehr_consent.to_hash['date']
      else
        subject[:ehr_consent_status_st] = '0'
      end

      subject[:withdrawal_status] = health_pro.withdrawal_status if health_pro
      subject[:withdrawal_date] = Date.parse(health_pro.withdrawal_date) if health_pro && health_pro.withdrawal_date
      study_tracker_activity_withdrawal = case_number_study_tracker_activities.select { |study_tracker_activity| study_tracker_activity.to_hash['name'] == 'Withdrawn' && study_tracker_activity.to_hash['date'].present? &&  study_tracker_activity.to_hash['state'] == 'completed' }.first
      if study_tracker_activity_withdrawal
        subject[:withdrawal_status_st] = '1'
        subject[:withdrawal_date_st] = Date.parse(study_tracker_activity_withdrawal.to_hash['date']) if study_tracker_activity_withdrawal.to_hash['date']
      else
        subject[:withdrawal_status_st] = '0'
      end

      if match_status(subject[:general_consent_status], subject[:general_consent_date], subject[:general_consent_status_st], subject[:general_consent_date_st]) &&
         match_status(subject[:ehr_consent_status], subject[:ehr_consent_date], subject[:ehr_consent_status_st], subject[:ehr_consent_date_st]) &&
         match_status(subject[:withdrawal_status], subject[:withdrawal_date] , subject[:withdrawal_status_st], subject[:withdrawal_date_st])
         subject[:status] = 'matches'
       else
         subject[:status] = 'mismatches'
       end

      subjects << subject
    end

    headers = subject_template.keys
    row_header = CSV::Row.new(headers, headers, true)
    row_template = CSV::Row.new(headers, [], false)
    CSV.open('lib/setup/data_out/subjects.csv', "wb") do |csv|
      csv << row_header
      subjects.each do |subject|
        row = row_template.dup
        row[:source] = subject[:source]
        row[:pmi_id] = subject[:pmi_id]
        row[:status] = subject[:status]
        row[:participant_status] = subject[:participant_status]

        row[:nmhc_mrn] = subject[:nmhc_mrn]
        row[:biospecimens_location] = subject[:biospecimens_location]

        row[:general_consent_status] = subject[:general_consent_status]
        row[:general_consent_date] = subject[:general_consent_date]
        row[:general_consent_status_st] = subject[:general_consent_status_st]
        row[:general_consent_date_st] = subject[:general_consent_date_st]

        row[:ehr_consent_status] = subject[:ehr_consent_status]
        row[:ehr_consent_date] = subject[:ehr_consent_date]
        row[:ehr_consent_status_st] = subject[:ehr_consent_status_st]
        row[:ehr_consent_date_st] = subject[:ehr_consent_date_st]

        row[:withdrawal_status] = subject[:withdrawal_status]
        row[:withdrawal_date] = subject[:withdrawal_date]
        row[:withdrawal_status_st] = subject[:withdrawal_status_st]
        row[:withdrawal_date_st] = subject[:withdrawal_date_st]
        csv << row
      end
    end
  end
end

def match_status(status, date, status_st, date_st)
  match = false
  if status == status_st && status == '1' && date == date_st
    match = true
  elsif status == status_st && status == '1' && date != date_st
    match = false
  elsif status == status_st && status == '0'
    match = true
  end
  match
end