require 'rest_client'
class RedcapApi
  ERROR_MESSAGE_DUPLICATE_PATIENT = 'More than one patient with record_id.'
  attr_accessor :api_token, :api_url
  SYSTEM = 'redcap'

  def self.initialize_redcap_api
    api_token = ApiToken.where(api_token_type: ApiToken::API_TOKEN_TYPE_REDCAP).first
    redcap_api = RedcapApi.new(api_token.token)
  end

  def initialize(api_token)
    @api_token = api_token

    @api_url = Rails.configuration.custom.app_config['redcap'][Rails.env]['host_url']
    if Rails.env.development? || Rails.env.test?
      @verify_ssl = Rails.configuration.custom.app_config['redcap'][Rails.env]['verify_ssl'] || true
    else
      @verify_ssl = true
    end
  end

  def patients
    payload = {
        :token => @api_token,
        :content => 'record',
        :format => 'json',
        :type => 'flat',
        'fields[0]' => 'email',
        'fields[1]' => 'first_name',
        'fields[2]' => 'last_name',
        'fields[3]' => 'record_id',
        'forms[0]' => 'code_assignment',
        :returnFormat => 'json'
    }

    api_response = redcap_api_request_wrapper(payload)

    { response: api_response[:response], error: api_response[:error] }
  end

  def next_record_id
    payload = {
      :token => @api_token,
      :content => 'record',
      :format => 'json',
      :type => 'flat',
      'fields[0]' => 'record_id',
      :returnFormat => 'json'
    }

    api_response = redcap_api_request_wrapper(payload)
    record_id = api_response[:response].map { |r| r['record_id'].to_i }.max
    record_id+=1

    { response: record_id, error: api_response[:error] }
  end

  def pending_invitation_code_assignments
    payload = {
        :token => @api_token,
        :content => 'record',
        :format => 'json',
        :type => 'flat',
        'fields[0]' => 'email',
        'fields[1]' => 'first_name',
        'fields[2]' => 'last_name',
        'fields[3]' => 'record_id',
        'forms[0]' => 'code_assignment',
        :returnFormat => 'json',
        :filterLogic => '([invitationcode]="") AND ([code_assignment_complete]="0")'
    }

    api_response = redcap_api_request_wrapper(payload)

    { response: api_response[:response], error: api_response[:error] }
  end

  def patient(record_id)
    error = nil
    response = nil
    payload = {
        :token => @api_token,
        :content => 'record',
        :format => 'json',
        :type => 'flat',
        'records[0]' => "#{record_id}",
        'forms[0]' => 'how_to_join',
        :returnFormat => 'json'
    }

    api_response = redcap_api_request_wrapper(payload)

    error = api_response[:error] if api_response[:error].present?

    if api_response[:response].is_a?(Array) && api_response[:response].size > 1
      error = RedcapApi::ERROR_MESSAGE_DUPLICATE_PATIENT
    end

    if api_response[:response].is_a?(Array) && api_response[:response].size == 1
      response = api_response[:response].first
    end

    { response: response, error: error }
  end

  def update_patient(record_id, consent_y, consent_d, ehr_consent_y, ehr_consent_d, withdrawn_y, withdrawal_d, wq_participant_status, pm_date, wq_paired_site, wq_paired_org)
    consent_d = Date.parse(consent_d) if consent_d
    ehr_consent_d = Date.parse(ehr_consent_d) if ehr_consent_d
    withdrawal_d = Date.parse(withdrawal_d) if withdrawal_d
    pm_date = Date.parse(pm_date) if pm_date
    if withdrawn_y == '1'
    studystatus_dt = DateTime.now
    payload = {
        :token => @api_token,
        :content => 'record',
        :format => 'csv',
        :type => 'flat',
        :overwriteBehavior => 'overwrite',
        :data => %(record_id,consent_y,consent_d,ehr_consent_y,ehr_consent_d,withdrawn_y,withdrawal_d,donotcontact,wq_participant_status,pm_date,wq_paired_site,wq_paired_org
"#{record_id}","#{consent_y}","#{consent_d}","#{ehr_consent_y}","#{ehr_consent_d}","#{withdrawn_y}","#{withdrawal_d}","1",#{wq_participant_status},#{pm_date},#{wq_paired_site},#{wq_paired_org}),
        :returnContent => 'ids',
        :returnFormat => 'json'
    }
    else
    payload = {
        :token => @api_token,
        :content => 'record',
        :format => 'csv',
        :type => 'flat',
        :overwriteBehavior => 'overwrite',
        :data => %(record_id,consent_y,consent_d,ehr_consent_y,ehr_consent_d,withdrawn_y,withdrawal_d,wq_participant_status,pm_date,wq_paired_site,wq_paired_org
"#{record_id}","#{consent_y}","#{consent_d}","#{ehr_consent_y}","#{ehr_consent_d}","#{withdrawn_y}","#{withdrawal_d}",#{wq_participant_status},#{pm_date},#{wq_paired_site},#{wq_paired_org}),
        :returnContent => 'ids',
        :returnFormat => 'json'
    }
    end

    api_response = redcap_api_request_wrapper(payload)

    { response: record_id, error: api_response[:error] }
  end

  def create_patient(first_name, last_name, email, phone, pmi_id, consent_y, consent_d, ehr_consent_y, ehr_consent_d, withdrawn_y, withdrawal_d, wq_participant_status, pm_date, wq_paired_site, wq_paired_org)
    record_id = next_record_id
    record_id = record_id[:response]
    consent_d = Date.parse(consent_d) if consent_d
    ehr_consent_d = Date.parse(ehr_consent_d) if ehr_consent_d
    withdrawal_d = Date.parse(withdrawal_d) if withdrawal_d
    pm_date = Date.parse(pm_date) if pm_date
    ts = Date.today
    if withdrawn_y == '1'
    payload = {
        :token => @api_token,
        :content => 'record',
        :format => 'csv',
        :type => 'flat',
        :overwriteBehavior => 'overwrite',
        :data => %(record_id,first_name,last_name,email,phone_1,phone1_type,pmi_id,healthpro_y,healthpro_status_complete,consent_y,consent_d,ehr_consent_y,ehr_consent_d,ts,withdrawn_y,withdrawal_d,donotcontact,wq_participant_status,pm_date,wq_paired_site,wq_paired_org
"#{record_id}","#{first_name}","#{last_name}","#{email}","#{phone}","4","#{pmi_id}","1","2","#{consent_y}","#{consent_d}","#{ehr_consent_y}","#{ehr_consent_d}","#{ts}","#{withdrawn_y}","#{withdrawal_d}","1",#{wq_participant_status},#{pm_date},#{wq_paired_site},#{wq_paired_org}),
        :returnContent => 'ids',
        :returnFormat => 'json'
    }
    else
    payload = {
        :token => @api_token,
        :content => 'record',
        :format => 'csv',
        :type => 'flat',
        :overwriteBehavior => 'overwrite',
        :data => %(record_id,first_name,last_name,email,phone_1,phone1_type,pmi_id,healthpro_y,healthpro_status_complete,consent_y,consent_d,ehr_consent_y,ehr_consent_d,ts,withdrawn_y,withdrawal_d,wq_participant_status,pm_date,wq_paired_site,wq_paired_org
"#{record_id}","#{first_name}","#{last_name}","#{email}","#{phone}","4","#{pmi_id}","1","2","#{consent_y}","#{consent_d}","#{ehr_consent_y}","#{ehr_consent_d}","#{ts}","#{withdrawn_y}","#{withdrawal_d}",#{wq_participant_status},#{pm_date},#{wq_paired_site},#{wq_paired_org}),
        :returnContent => 'ids',
        :returnFormat => 'json'
    }
    end

    api_response = redcap_api_request_wrapper(payload)
    record_id = api_response[:response].first

    { response: record_id, error: api_response[:error] }
  end

  def assign_invitation_code(record_id, invitation_code)
    payload = {
        :token => @api_token,
        :content => 'record',
        :format => 'csv',
        :type => 'flat',
        :overwriteBehavior => 'overwrite',
        :data => %(record_id,invitationcode,code_assignment_complete
"#{record_id}","#{invitation_code}","2"),
        :returnContent => 'count',
        :returnFormat => 'json'
    }

    api_response = redcap_api_request_wrapper(payload)

    { response: api_response[:response], error: api_response[:error] }
  end

  def match(record_id, pmi_id, consent_y, consent_d, ehr_consent_y, ehr_consent_d, withdrawn_y, withdrawal_d, wq_participant_status, pm_date, wq_paired_site, wq_paired_org)
    consent_d = Date.parse(consent_d) if consent_d
    ehr_consent_d = Date.parse(ehr_consent_d) if ehr_consent_d
    withdrawal_d = Date.parse(withdrawal_d) if withdrawal_d
    pm_date = Date.parse(pm_date) if pm_date
    if withdrawn_y == '1'
    payload = {
        :token => @api_token,
        :content => 'record',
        :format => 'csv',
        :type => 'flat',
        :overwriteBehavior => 'overwrite',
        :data => %(record_id,pmi_id,healthpro_y,healthpro_status_complete,consent_y,consent_d,ehr_consent_y,ehr_consent_d,withdrawn_y,withdrawal_d,donotcontact,wq_participant_status,pm_date,wq_paired_site,wq_paired_org
"#{record_id}","#{pmi_id}","1","2","#{consent_y}","#{consent_d}","#{ehr_consent_y}","#{ehr_consent_d}","#{withdrawn_y}","#{withdrawal_d}","1",#{wq_participant_status},#{pm_date},#{wq_paired_site},#{wq_paired_org}),
        :returnContent => 'count',
        :returnFormat => 'json'
    }

    else
    payload = {
        :token => @api_token,
        :content => 'record',
        :format => 'csv',
        :type => 'flat',
        :overwriteBehavior => 'overwrite',
        :data => %(record_id,pmi_id,healthpro_y,healthpro_status_complete,consent_y,consent_d,ehr_consent_y,ehr_consent_d,withdrawn_y,withdrawal_d,wq_participant_status,pm_date,wq_paired_site,wq_paired_org
"#{record_id}","#{pmi_id}","1","2","#{consent_y}","#{consent_d}","#{ehr_consent_y}","#{ehr_consent_d}","#{withdrawn_y}","#{withdrawal_d}",#{wq_participant_status},#{pm_date},#{wq_paired_site},#{wq_paired_org}),
        :returnContent => 'count',
        :returnFormat => 'json'
    }
    end

    api_response = redcap_api_request_wrapper(payload)

    { response: api_response[:response], error: api_response[:error] }
  end

  def pmi_id(record_id, pmi_id)
    payload = {
        :token => @api_token,
        :content => 'record',
        :format => 'csv',
        :type => 'flat',
        :overwriteBehavior => 'overwrite',
        :data => %(record_id,pmi_id
"#{record_id}","#{pmi_id}"),
        :returnContent => 'count',
        :returnFormat => 'json'
    }

    api_response = redcap_api_request_wrapper(payload)

    { response: api_response[:response], error: api_response[:error] }
  end

  def decline(record_id)
    payload = {
        :token => @api_token,
        :content => 'record',
        :format => 'csv',
        :type => 'flat',
        :overwriteBehavior => 'overwrite',
        :data => %(record_id,donotcontact,studystatus_ehr_y
"#{record_id}","0","0"),
        :returnContent => 'count',
        :returnFormat => 'json'
    }

    api_response = redcap_api_request_wrapper(payload)

    { response: api_response[:response], error: api_response[:error] }
  end

  private
    def redcap_api_request_wrapper(payload, parse_response = true)
      response = nil
      error =  nil
      begin
        response = RestClient::Request.execute(
          method: :post,
          url: @api_url,
          payload: payload,
          content_type:  'application/json',
          accept: 'json',
          verify_ssl: @verify_ssl
        )
        ApiLog.create_api_log(@api_url, payload, response, nil, RedcapApi::SYSTEM)
        response = JSON.parse(response) if parse_response
      rescue Exception => e
        ExceptionNotifier.notify_exception(e)
        ApiLog.create_api_log(@api_url, payload, nil, e.message, RedcapApi::SYSTEM)
        error = e
        Rails.logger.info(e.class)
        Rails.logger.info(e.message)
        Rails.logger.info(e.backtrace.join("\n"))
      end
      { response: response, error: error }
    end
end