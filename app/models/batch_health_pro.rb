require 'csv'
require 'study_tracker_api'
class BatchHealthPro < ApplicationRecord
  has_paper_trail
  STATUS_PENDING = 'pending'
  STATUS_READY = 'ready'
  STATUS_EXPIRED = 'expired'
  STATUS_ERROR = 'error'
  STATUSES = [STATUS_PENDING, STATUS_READY, STATUS_EXPIRED, STATUS_ERROR]

  MATCH_STATUS_OPEN = 'open'
  MATCH_STATUS_CLOSED = 'closed'
  MATCH_STATUSES = [MATCH_STATUS_OPEN, MATCH_STATUS_CLOSED]

  mount_uploader :health_pro_file, HealthProFileUploader

  has_many :health_pros
  validates_presence_of :health_pro_file
  validates_size_of :health_pro_file, maximum: 10.megabytes, message: 'must be less than 10MB'

  after_destroy :remove_health_pro_file!
  after_initialize :set_defaults

  scope :by_status, ->(*statuses) do
    if statuses.any?
     where(status: statuses)
    end
  end

  scope :by_match_status, ->(match_status) do
    case match_status
      when BatchHealthPro::MATCH_STATUS_OPEN
        where('EXISTS (SELECT 1 FROM health_pros JOIN matches ON health_pros.id = matches.health_pro_id WHERE batch_health_pros.id = health_pros.batch_health_pro_id AND matches.status = ?)', Match::STATUS_PENDING)
      when BatchHealthPro::MATCH_STATUS_CLOSED
        where('NOT EXISTS (SELECT 1 FROM health_pros JOIN matches ON health_pros.id = matches.health_pro_id WHERE batch_health_pros.id = health_pros.batch_health_pro_id AND matches.status = ?)', Match::STATUS_PENDING)
      else
        where('1=1')
    end
  end

  def self.expire
    BatchHealthPro.by_status(BatchHealthPro::STATUS_READY).update_all(status: BatchHealthPro::STATUS_EXPIRED)
  end

  def pending?
    status == BatchHealthPro::STATUS_PENDING
  end

  def ready?
    status == BatchHealthPro::STATUS_READY
  end

  def import
    begin
      data = ''
      f = File.open(health_pro_file.current_path)
      f.each_line do |line|
        unless line.match(/^""\n/) || line.include?('Confidential Information') || line.include?('This file contains information that is sensitive and confidential. Do not distribute either the file or its contents.')
          data += line
        end
      end
      health_pros_from_file = CSV.new(data, headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")

      if errors.empty?
        BatchHealthPro.transaction do
          health_pros_from_file.each do |health_pro_from_file|
            row ={}
            BatchHealthPro.headers_map.each_pair do |k,v|
              row[v.to_sym] = health_pro_from_file.to_hash[k.to_s]
            end

            health_pros.build(row)
          end

          health_pros.each do |health_pro|
            health_pro.determine_matches

            if health_pro.matchable?
              health_pro.determine_empi_matches
            end

            health_pro.save!

            if health_pro.status == HealthPro::STATUS_PREVIOUSLY_MATCHED
              matched_pmi_patient = Patient.where(pmi_id: health_pro.pmi_id).first
              matched_pmi_patient.birth_date = Date.parse(health_pro.date_of_birth)
              matched_pmi_patient.gender = health_pro.sex if matched_pmi_patient.gender.blank? && health_pro.sex.present?
              matched_pmi_patient.general_consent_status = health_pro.general_consent_status
              matched_pmi_patient.general_consent_date = health_pro.general_consent_date
              matched_pmi_patient.ehr_consent_status = health_pro.ehr_consent_status
              matched_pmi_patient.ehr_consent_date = health_pro.ehr_consent_date
              matched_pmi_patient.withdrawal_status = health_pro.withdrawal_status
              matched_pmi_patient.withdrawal_date = health_pro.withdrawal_date
              matched_pmi_patient.biospecimens_location = health_pro.biospecimens_location
              matched_pmi_patient.participant_status = health_pro.participant_status
              if matched_pmi_patient.registered? && matched_pmi_patient.changed?
                error = nil
                options = {}
                options[:proxy_user] = self.created_user
                study_tracker_api = StudyTrackerApi.new
                registraion_results = study_tracker_api.register(options, matched_pmi_patient)
                error = registraion_results[:error]
              end
              matched_pmi_patient.save!
            end
          end
        end
        self.status = BatchHealthPro::STATUS_READY
        save!
      else
        false
      end
    rescue Exception => e
      ExceptionNotifier.notify_exception(e)
      set_status_to_error
      Rails.logger.info(e.class)
      Rails.logger.info(e.message)
      Rails.logger.info(e.backtrace.join("\n"))
      false
    end
  end

  def set_status_to_error
    begin
      self.status = BatchHealthPro::STATUS_ERROR
      save!
    rescue Exception => e
    end
  end

  def self.headers_map
    {
      'PMI ID' => 'pmi_id',
      'Biobank ID' => 'biobank_id',
      'Last Name' => 'last_name',
      'First Name' => 'first_name',
      'Date of Birth' => 'date_of_birth',
      'Language' => 'language',
      'Participant Status' => 'participant_status',
      # Participant Status
      'General Consent Status' => 'general_consent_status',
      'General Consent Date' => 'general_consent_date',
      'EHR Consent Status' => 'ehr_consent_status',
      'EHR Consent Date' => 'ehr_consent_date',
      'CABoR Consent Status' => 'cabor_consent_status',
      'CABoR Consent Date' => 'cabor_consent_date',
      'Withdrawal Status' => 'withdrawal_status',
      'Withdrawal Date' => 'withdrawal_date',
      'Street Address' => 'street_address',
      'City' => 'city',
      'State' => 'state',
      'ZIP' => 'zip',
      'Email' => 'email',
      'Phone' => 'phone',
      'Sex' => 'sex',
      'Gender Identity' => 'gender_identity',
      'Race/Ethnicity' => 'race_ethnicity',
      'Education' => 'education',
      'Required PPI Surveys Complete' => 'required_ppi_surveys_complete',
      'Completed Surveys' => 'completed_surveys',
      'Basics PPI Survey Complete' => 'basics_ppi_survey_complete',
      'Basics PPI Survey Completion Date' => 'basics_ppi_survey_completion_date',
      'Health PPI Survey Complete' => 'health_ppi_survey_complete',
      'Health PPI Survey Completion Date' => 'health_ppi_survey_completion_date',
      'Lifestyle PPI Survey Complete' => 'lifestyle_ppi_survey_complete',
      'Lifestyle PPI Survey Completion Date' => 'lifestyle_ppi_survey_completion_date',
      'Hist PPI Survey Complete' => 'hist_ppi_survey_complete',
      'Hist PPI Survey Completion Date' => 'hist_ppi_survey_completion_date',
      'Meds PPI Survey Complete' => 'meds_ppi_survey_complete',
      'Meds PPI Survey Completion Date' => 'meds_ppi_survey_completion_date',
      'Family PPI Survey Complete' => 'family_ppi_survey_complete',
      'Family PPI Survey Completion Date' => 'family_ppi_survey_completion_date',
      'Access PPI Survey Complete' => 'access_ppi_survey_complete',
      'Access PPI Survey Completion Date' => 'access_ppi_survey_completion_date',
      'Physical Measurements Status' => 'physical_measurements_status',
      'Physical Measurements Completion Date' => 'physical_measurements_completion_date',
      'Paired Site' => 'paired_site',
      'Paired Organization' => 'paired_organization',
      #Paired Site
      #Paired Organization
      #'Physical Measurements Location' => 'physical_measurements_location',
      'Physical Measurements Site' => 'physical_measurements_location',
      'Samples for DNA Received' => 'samples_for_dna_received',
      'Biospecimens' => 'biospecimens',
      '8 mL SST Collected' => 'eight_ml_sst_collected',
      '8 mL SST Collection Date' => 'eight_ml_sst_collection_date',
      '8 mL PST Collected' => 'eight_ml_pst_collected',
      '8 mL PST Collection Date' => 'eight_ml_pst_collection_date',
      '4 mL Na-Hep Collected' => 'four_ml_na_hep_collected',
      '4 mL Na-Hep Collection Date' => 'four_ml_na_hep_collection_date',
      '4 mL EDTA Collected' => 'four_ml_edta_collected',
      '4 mL EDTA Collection Date' => 'four_ml_edta_collection_date',
      '1st 10 mL EDTA Collected' => 'first_10_ml_edta_collected',
      '1st 10 mL EDTA Collection Date' => 'first_10_ml_edta_collection_date',
      '2nd 10 mL EDTA Collected' => 'second_10_ml_edta_collected',
      '2nd 10 mL EDTA Collection Date' => 'second_10_ml_edta_collection_date',
      'Urine 10 mL Collected' => 'urine_10_ml_collected',
      'Urine 10 mL Collection Date' => 'urine_10_ml_collection_date',
      'Saliva Collected' => 'saliva_collected',
      'Saliva Collection Date' => 'saliva_collection_date',
      # 'Biospecimens Location' => 'biospecimens_location'
      'Biospecimens Site' => 'biospecimens_location'
    }
  end

  private
    def set_defaults
      if self.new_record?
        self.status = BatchHealthPro::STATUS_PENDING
      end
    end
end