require 'rest_client'
class StudyTrackerApi
  SEARCH_TYPE_IDENTIFIERS = 'identifiers'
  SEARCH_TYPE_DEMOGRAPHICS = 'demographics'
  SEARCH_TYPES = [SEARCH_TYPE_IDENTIFIERS, SEARCH_TYPE_DEMOGRAPHICS]
  IRB_NUMBER = 'STU00204480'
  ORG_NMHC = 'nmhc'
  EVENT_TYPE_NAME_CONSENTED = 'Consented'
  EVENT_TYPE_NAME_EHR_CONSENT = 'EHR Consent'
  EVENT_TYPE_NAME_WITHDRAWN = 'Withdrawn'
  SYSTEM = 'study tracker'

  def initialize
    @user = Rails.application.config.all_of_us_helper_api_users['study_tracker']['api_user']
    @password = Rails.application.config.all_of_us_helper_api_users['study_tracker']['password']

    if Rails.env.development? || Rails.env.test?
      @verify_ssl = Rails.configuration.custom.app_config['study_tracker'][Rails.env]['verify_ssl'] || true
    else
      @verify_ssl = true
    end
  end

  def empi_lookup(options)
    options = { 'study_id' => StudyTrackerApi::IRB_NUMBER, 'search_type' => StudyTrackerApi::SEARCH_TYPE_DEMOGRAPHICS }.merge(options)
    url = Rails.configuration.custom.app_config['study_tracker'][Rails.env]['empi_lookup'] + '?' + URI.encode_www_form(options)
    api_response = study_tracker_api_request_wrapper(url: url, method: :get, parse_response: true)
    { response: api_response[:response], error: api_response[:error] }
  end

  def register(options, patient)
    begin
      payload = {}
      payload[:subject] = {}
      payload[:subject][:irb_number] = StudyTrackerApi::IRB_NUMBER
      payload[:subject][:ethnicity] = patient.ethnicity
      payload[:subject][:gender] = patient.gender
      payload[:subject][:case_number] = patient.pmi_id
      payload[:subject][:uuid] = patient.uuid
      payload[:subject][:first_name] = patient.first_name
      payload[:subject][:last_name] = patient.last_name
      payload[:subject][:birth_date] = patient.birth_date
      payload[:subject][:races] = patient.races.map { |race| race.name }
      payload[:subject][:record_numbers] = []
      payload[:subject][:record_numbers] << { org: StudyTrackerApi::ORG_NMHC, record_number: patient.nmhc_mrn }
      payload[:subject][:events] = []

      if patient.general_consent_status == HealthPro::YES
        payload[:subject][:events] << { name: StudyTrackerApi::EVENT_TYPE_NAME_CONSENTED, date: patient.general_consent_date }
      end

      if patient.ehr_consent_status == HealthPro::YES
        payload[:subject][:events] << { name: StudyTrackerApi::EVENT_TYPE_NAME_EHR_CONSENT, date: patient.ehr_consent_date }
      end

      if patient.withdrawal_status == HealthPro::YES
        payload[:subject][:events] << { name: StudyTrackerApi::EVENT_TYPE_NAME_WITHDRAWN, date: patient.withdrawal_date }
      end
      url = Rails.configuration.custom.app_config['study_tracker'][Rails.env]['register'].gsub(':id', patient.uuid)
      url = url + '?' + URI.encode_www_form(options)

      api_response = study_tracker_api_request_wrapper(url: url, method: :put, parse_response: true, payload: payload)

      { response: api_response[:response], error: api_response[:error] }
    rescue Exception => e
      error = e
      Rails.logger.info(e.class)
      Rails.logger.info(e.message)
      Rails.logger.info(e.backtrace.join("\n"))
      { response: nil, error: error }
    end
  end

  private
    def study_tracker_api_request_wrapper(options={})
      response = nil
      error =  nil
      begin
        case options[:method]
        when :get
          response = RestClient::Request.execute(
            method: options[:method],
            url: options[:url],
            user: @user,
            password: @password,
            accept: 'json',
            verify_ssl: @verify_ssl,
            headers: {
              content_type: 'application/json; charset=utf-8'
            }
          )
          ApiLog.create_api_log(options[:url], nil, response, nil, StudyTrackerApi::SYSTEM)
        else
           payload = ActiveSupport::JSON.encode(options[:payload])
           response = RestClient::Request.execute(
            method: options[:method],
            user: @user,
            password: @password,
            url: options[:url],
            payload: payload,
            content_type:  'application/json',
            accept: 'json',
            verify_ssl: @verify_ssl,
            headers: {
              content_type: 'application/json; charset=utf-8'
            }
          )
          ApiLog.create_api_log(options[:url], options[:payload], response, nil, StudyTrackerApi::SYSTEM)
        end
        response = JSON.parse(response) if options[:parse_response]
      rescue Exception => e
        ExceptionNotifier.notify_exception(e)
        ApiLog.create_api_log(options[:url], options[:payload], nil, e.message, StudyTrackerApi::SYSTEM)
        error = e
        Rails.logger.info(e.class)
        Rails.logger.info(e.message)
        Rails.logger.info(e.backtrace.join("\n"))
      end

      if response[:errors].present?
        error = response[:errors]
      end

      { response: response, error: error }
    end
end