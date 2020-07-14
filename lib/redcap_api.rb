require 'rest_client'
class RedcapApi
  ERROR_MESSAGE_DUPLICATE_PATIENT = 'More than one patient with record_id.'
  attr_accessor :api_token, :api_url, :system
  SYSTEM_REDCAP = 'redcap'
  SYSTEM_REDCAP_RECRUITMENT = 'redcap recruitment'

  def self.initialize_redcap_api(options={})
    options = { system: SYSTEM_REDCAP, api_token_type: ApiToken::API_TOKEN_TYPE_REDCAP }.merge(options)
    api_token = ApiToken.where(api_token_type: options[:api_token_type]).first
    redcap_api = RedcapApi.new(api_token.token, options[:system])
  end

  def initialize(api_token, system)
    @api_token = api_token
    @system = system

    @api_url = Rails.configuration.custom.app_config['redcap'][Rails.env]['host_url']
    if Rails.env.development? || Rails.env.test?
      @verify_ssl = Rails.configuration.custom.app_config['redcap'][Rails.env]['verify_ssl'] || true
    else
      @verify_ssl = true
    end
  end

  def recruitment_patients
    payload = {
        :token => @api_token,
        :content => 'record',
        :format => 'json',
        :type => 'flat',
        'fields[0]' => 'record_id',
        'fields[1]' => 'mrn',
        'fields[2]' => 'st_event',
        'fields[3]' => 'st_event_d',
        'fields[4]' => 'st_import_d',
        :returnFormat => 'json'
    }

    api_response = redcap_api_request_wrapper(payload)

    { response: api_response[:response], error: api_response[:error] }
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
        'fields[4]' => 'phone_1',
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
        'fields[4]' => 'phone_1',
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

  def update_patient(record_id, consent, consent_d, ehr_consent, ehr_consent_d, withdrawn_y, withdrawal_d, wq_participant_status, pm_date, wq_paired_site, wq_paired_org, health_pro_email, health_pro_phone, health_pro_login_phone, gror_consent, gror_consent_d, core_participant_d, deactivation_status, deactivation_date, required_ppi_complete_y, completed_surveys, basics_ppi_complete_y, basics_ppi_complete_d, health_ppi_complete_y, health_ppi_complete_d, lifestyle_ppi_complete_y, lifestyle_ppi_complete_d, history_ppi_complete_y, history_ppi_complete_d, meds_ppi_complete_y, meds_ppi_complete_d, family_ppi_complete_y, family_ppi_complete_d, access_ppi_complete_y, access_ppi_complete_d, copemay_complete_y, copemay_complete_d, copejune_complete_y, copejune_complete_d, copejuly_complete_y, copejuly_complete_d)
    consent_d = Date.parse(consent_d) if consent_d
    ehr_consent_d = Date.parse(ehr_consent_d) if ehr_consent_d
    withdrawal_d = Date.parse(withdrawal_d) if withdrawal_d
    pm_date = Date.parse(pm_date) if pm_date
    gror_consent_d = Date.parse(gror_consent_d) if gror_consent_d
    core_participant_d = Date.parse(core_participant_d) if core_participant_d
    deactivation_date = Date.parse(deactivation_date) if deactivation_date
    basics_ppi_complete_d = Date.parse(basics_ppi_complete_d) if basics_ppi_complete_d
    health_ppi_complete_d = Date.parse(health_ppi_complete_d) if health_ppi_complete_d
    lifestyle_ppi_complete_d = Date.parse(lifestyle_ppi_complete_d) if lifestyle_ppi_complete_d
    history_ppi_complete_d = Date.parse(history_ppi_complete_d) if history_ppi_complete_d
    meds_ppi_complete_d = Date.parse(meds_ppi_complete_d) if meds_ppi_complete_d
    family_ppi_complete_d = Date.parse(family_ppi_complete_d) if family_ppi_complete_d
    access_ppi_complete_d = Date.parse(access_ppi_complete_d) if access_ppi_complete_d
    copemay_complete_d = Date.parse(copemay_complete_d) if copemay_complete_d
    copejune_complete_d = Date.parse(copejune_complete_d) if copejune_complete_d
    copejuly_complete_d = Date.parse(copejuly_complete_d) if copejuly_complete_d

    if (withdrawn_y == HealthPro::HEALTH_PRO_API_WITHDRAWAL_STATUS_NO_USE || deactivation_status == HealthPro::HEALTH_PRO_API_DEACTIVATION_STATUS_NO_CONTACT)
    payload = {
        :token => @api_token,
        :content => 'record',
        :format => 'csv',
        :type => 'flat',
        :overwriteBehavior => 'overwrite',
        :data => %(record_id,consent,consent_d,ehr_consent,ehr_consent_d,withdrawn_y,withdrawal_d,donotcontact,wq_participant_status,pm_date,wq_paired_site,wq_paired_org,health_pro_email,health_pro_phone,health_pro_login_phone,gror_consent,gror_consent_d,core_participant_d,deactivation_status,deactivation_date,required_ppi_complete_y,completed_surveys,basics_ppi_complete_y,basics_ppi_complete_d,health_ppi_complete_y,health_ppi_complete_d,lifestyle_ppi_complete_y,lifestyle_ppi_complete_d,history_ppi_complete_y,history_ppi_complete_d,meds_ppi_complete_y,meds_ppi_complete_d,family_ppi_complete_y,family_ppi_complete_d,access_ppi_complete_y,access_ppi_complete_d,copemay_complete_y,copemay_complete_d,copejune_complete_y,copejune_complete_d,copejuly_complete_y,copejuly_complete_d
"#{record_id}","#{consent}","#{consent_d}","#{ehr_consent}","#{ehr_consent_d}","#{map_withdrawn_y(withdrawn_y)}","#{withdrawal_d}","1","#{wq_participant_status}","#{pm_date}","#{wq_paired_site}","#{wq_paired_org}","#{health_pro_email}","#{health_pro_phone}","#{health_pro_login_phone}","#{gror_consent}","#{gror_consent_d}","#{core_participant_d}","#{map_deactivation_status(deactivation_status)}","#{deactivation_date}","#{map_required_ppi_complete_y(required_ppi_complete_y)}","#{completed_surveys}","#{map_y_column(basics_ppi_complete_y)}","#{ basics_ppi_complete_d}","#{map_y_column(health_ppi_complete_y)}","#{health_ppi_complete_d}","#{map_y_column(lifestyle_ppi_complete_y)}","#{lifestyle_ppi_complete_d}","#{map_y_column(history_ppi_complete_y)}","#{history_ppi_complete_d}","#{map_y_column(meds_ppi_complete_y)}","#{meds_ppi_complete_d}","#{map_y_column(family_ppi_complete_y)}","#{family_ppi_complete_d}","#{map_y_column(access_ppi_complete_y)}","#{access_ppi_complete_d}","#{map_y_column(copemay_complete_y)}","#{copemay_complete_d}","#{map_y_column(copejune_complete_y)}","#{copejune_complete_d}","#{map_y_column(copejuly_complete_y)}","#{copejuly_complete_d}"),
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
        :data => %(record_id,consent,consent_d,ehr_consent,ehr_consent_d,withdrawn_y,withdrawal_d,wq_participant_status,pm_date,wq_paired_site,wq_paired_org,health_pro_email,health_pro_phone,health_pro_login_phone,gror_consent,gror_consent_d,core_participant_d,deactivation_status,deactivation_date,required_ppi_complete_y,completed_surveys,basics_ppi_complete_y,basics_ppi_complete_d,health_ppi_complete_y,health_ppi_complete_d,lifestyle_ppi_complete_y,lifestyle_ppi_complete_d,history_ppi_complete_y,history_ppi_complete_d,meds_ppi_complete_y,meds_ppi_complete_d,family_ppi_complete_y,family_ppi_complete_d,access_ppi_complete_y,access_ppi_complete_d,copemay_complete_y,copemay_complete_d,copejune_complete_y,copejune_complete_d,copejuly_complete_y,copejuly_complete_d
"#{record_id}","#{consent}","#{consent_d}","#{ehr_consent}","#{ehr_consent_d}","#{map_withdrawn_y(withdrawn_y)}","#{withdrawal_d}","#{wq_participant_status}","#{pm_date}","#{wq_paired_site}","#{wq_paired_org}","#{health_pro_email}","#{health_pro_phone}","#{health_pro_login_phone}","#{gror_consent}","#{gror_consent_d}","#{core_participant_d}","#{map_deactivation_status(deactivation_status)}","#{deactivation_date}","#{map_required_ppi_complete_y(required_ppi_complete_y)}","#{completed_surveys}","#{map_y_column(basics_ppi_complete_y)}","#{basics_ppi_complete_d}","#{map_y_column(health_ppi_complete_y)}","#{health_ppi_complete_d}","#{map_y_column(lifestyle_ppi_complete_y)}","#{lifestyle_ppi_complete_d}","#{map_y_column(history_ppi_complete_y)}","#{history_ppi_complete_d}","#{map_y_column(meds_ppi_complete_y)}","#{meds_ppi_complete_d}","#{map_y_column(family_ppi_complete_y)}","#{family_ppi_complete_d}","#{map_y_column(access_ppi_complete_y)}","#{access_ppi_complete_d}","#{map_y_column(copemay_complete_y)}","#{copemay_complete_d}","#{map_y_column(copejune_complete_y)}","#{copejune_complete_d}","#{map_y_column(copejuly_complete_y)}","#{copejuly_complete_d}"),
        :returnContent => 'ids',
        :returnFormat => 'json'
    }
    end

    api_response = redcap_api_request_wrapper(payload)

    { response: record_id, error: api_response[:error] }
  end

  def create_patient(first_name, last_name, email, phone_1, pmi_id, consent, consent_d, ehr_consent, ehr_consent_d, withdrawn_y, withdrawal_d, wq_participant_status, pm_date, wq_paired_site, wq_paired_org, health_pro_email, health_pro_phone, health_pro_login_phone, gror_consent, gror_consent_d, core_participant_d, deactivation_status, deactivation_date, required_ppi_complete_y, completed_surveys, basics_ppi_complete_y, basics_ppi_complete_d, health_ppi_complete_y, health_ppi_complete_d, lifestyle_ppi_complete_y, lifestyle_ppi_complete_d, history_ppi_complete_y, history_ppi_complete_d, meds_ppi_complete_y, meds_ppi_complete_d, family_ppi_complete_y, family_ppi_complete_d, access_ppi_complete_y, access_ppi_complete_d, copemay_complete_y, copemay_complete_d, copejune_complete_y, copejune_complete_d, copejuly_complete_y, copejuly_complete_d, site_preference___1, site_preference___2, site_preference___3, site_preference___4)
    record_id = next_record_id
    record_id = record_id[:response]
    consent_d = Date.parse(consent_d) if consent_d
    ehr_consent_d = Date.parse(ehr_consent_d) if ehr_consent_d
    withdrawal_d = Date.parse(withdrawal_d) if withdrawal_d
    pm_date = Date.parse(pm_date) if pm_date
    gror_consent_d = Date.parse(gror_consent_d) if gror_consent_d
    core_participant_d = Date.parse(core_participant_d) if core_participant_d
    deactivation_date = Date.parse(deactivation_date) if deactivation_date
    basics_ppi_complete_d = Date.parse(basics_ppi_complete_d) if basics_ppi_complete_d
    health_ppi_complete_d = Date.parse(health_ppi_complete_d) if health_ppi_complete_d
    lifestyle_ppi_complete_d = Date.parse(lifestyle_ppi_complete_d) if lifestyle_ppi_complete_d
    history_ppi_complete_d = Date.parse(history_ppi_complete_d) if history_ppi_complete_d
    meds_ppi_complete_d = Date.parse(meds_ppi_complete_d) if meds_ppi_complete_d
    family_ppi_complete_d = Date.parse(family_ppi_complete_d) if family_ppi_complete_d
    access_ppi_complete_d = Date.parse(access_ppi_complete_d) if access_ppi_complete_d
    copemay_complete_d = Date.parse(copemay_complete_d) if copemay_complete_d
    copejune_complete_d = Date.parse(copejune_complete_d) if copejune_complete_d
    copejuly_complete_d = Date.parse(copejuly_complete_d) if copejuly_complete_d

    ts = Date.today
    if (withdrawn_y == HealthPro::HEALTH_PRO_API_WITHDRAWAL_STATUS_NO_USE || deactivation_status == HealthPro::HEALTH_PRO_API_DEACTIVATION_STATUS_NO_CONTACT)
    payload = {
        :token => @api_token,
        :content => 'record',
        :format => 'csv',
        :type => 'flat',
        :overwriteBehavior => 'overwrite',
        :data => %(record_id,first_name,last_name,email,phone_1,phone1_type,pmi_id,healthpro_y,healthpro_status_complete,consent,consent_d,ehr_consent,ehr_consent_d,ts,withdrawn_y,withdrawal_d,donotcontact,wq_participant_status,pm_date,wq_paired_site,wq_paired_org,health_pro_email,health_pro_phone,health_pro_login_phone,gror_consent,gror_consent_d,core_participant_d,deactivation_status,deactivation_date,required_ppi_complete_y,completed_surveys,basics_ppi_complete_y,basics_ppi_complete_d,health_ppi_complete_y,health_ppi_complete_d,lifestyle_ppi_complete_y,lifestyle_ppi_complete_d,history_ppi_complete_y,history_ppi_complete_d,meds_ppi_complete_y,meds_ppi_complete_d,family_ppi_complete_y,family_ppi_complete_d,access_ppi_complete_y,access_ppi_complete_d,copemay_complete_y,copemay_complete_d,copejune_complete_y,copejune_complete_d,copejuly_complete_y,copejuly_complete_d,site_preference___1,site_preference___2,site_preference___3,site_preference___4,how_to_join_complete
"#{record_id}","#{first_name}","#{last_name}","#{email}","#{phone_1}","4","#{pmi_id}","1","2","#{consent}","#{consent_d}","#{ehr_consent}","#{ehr_consent_d}","#{ts}","#{map_withdrawn_y(withdrawn_y)}","#{withdrawal_d}","1",#{wq_participant_status},#{pm_date},#{wq_paired_site},#{wq_paired_org},#{health_pro_email},#{health_pro_phone},#{health_pro_login_phone},"#{gror_consent}","#{gror_consent_d}","#{core_participant_d}","#{map_deactivation_status(deactivation_status)}","#{deactivation_date}","#{map_required_ppi_complete_y(required_ppi_complete_y)}","#{completed_surveys}","#{map_y_column(basics_ppi_complete_y)}","#{basics_ppi_complete_d}","#{map_y_column(health_ppi_complete_y)}","#{health_ppi_complete_d}","#{map_y_column(lifestyle_ppi_complete_y)}","#{lifestyle_ppi_complete_d}","#{map_y_column(history_ppi_complete_y)}","#{history_ppi_complete_d}","#{map_y_column(meds_ppi_complete_y)}","#{meds_ppi_complete_d}","#{map_y_column(family_ppi_complete_y)}","#{family_ppi_complete_d}","#{map_y_column(access_ppi_complete_y)}","#{access_ppi_complete_d}","#{map_y_column(copemay_complete_y)}","#{copemay_complete_d}","#{map_y_column(copejune_complete_y)}","#{copejune_complete_d}","#{map_y_column(copejuly_complete_y)}","#{copejuly_complete_d}","#{site_preference___1}","#{site_preference___2}","#{site_preference___3}","#{site_preference___4}","2"),
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
        :data => %(record_id,first_name,last_name,email,phone_1,phone1_type,pmi_id,healthpro_y,healthpro_status_complete,consent,consent_d,ehr_consent,ehr_consent_d,ts,withdrawn_y,withdrawal_d,wq_participant_status,pm_date,wq_paired_site,wq_paired_org,health_pro_email,health_pro_phone,health_pro_login_phone,referralsource,gror_consent,gror_consent_d,core_participant_d,deactivation_status,deactivation_date,required_ppi_complete_y,completed_surveys,basics_ppi_complete_y,basics_ppi_complete_d,health_ppi_complete_y,health_ppi_complete_d,lifestyle_ppi_complete_y,lifestyle_ppi_complete_d,history_ppi_complete_y,history_ppi_complete_d,meds_ppi_complete_y,meds_ppi_complete_d,family_ppi_complete_y,family_ppi_complete_d,access_ppi_complete_y,access_ppi_complete_d,copemay_complete_y,copemay_complete_d,copejune_complete_y,copejune_complete_d,copejuly_complete_y,copejuly_complete_d,site_preference___1,site_preference___2,site_preference___3,site_preference___4,how_to_join_complete
"#{record_id}","#{first_name}","#{last_name}","#{email}","#{phone_1}","4","#{pmi_id}","1","2","#{consent}","#{consent_d}","#{ehr_consent}","#{ehr_consent_d}","#{ts}","#{map_withdrawn_y(withdrawn_y)}","#{withdrawal_d}",#{wq_participant_status},#{pm_date},#{wq_paired_site},#{wq_paired_org},#{health_pro_email},#{health_pro_phone},#{health_pro_login_phone},"17","#{gror_consent}","#{gror_consent_d}","#{core_participant_d}","#{map_deactivation_status(deactivation_status)}","#{deactivation_date}","#{map_required_ppi_complete_y(required_ppi_complete_y)}","#{completed_surveys}","#{map_y_column(basics_ppi_complete_y)}","#{basics_ppi_complete_d}","#{map_y_column(health_ppi_complete_y)}","#{health_ppi_complete_d}","#{map_y_column(lifestyle_ppi_complete_y)}","#{lifestyle_ppi_complete_d}","#{map_y_column(history_ppi_complete_y)}","#{history_ppi_complete_d}","#{map_y_column(meds_ppi_complete_y)}","#{meds_ppi_complete_d}","#{map_y_column(family_ppi_complete_y)}","#{family_ppi_complete_d}","#{map_y_column(access_ppi_complete_y)}","#{access_ppi_complete_d}","#{map_y_column(copemay_complete_y)}","#{copemay_complete_d}","#{map_y_column(copejune_complete_y)}","#{copejune_complete_d}","#{map_y_column(copejuly_complete_y)}","#{copejuly_complete_d}","#{site_preference___1}","#{site_preference___2}","#{site_preference___3}","#{site_preference___4}","2"),
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

  def match(record_id, pmi_id, consent, consent_d, ehr_consent, ehr_consent_d, withdrawn_y, withdrawal_d, wq_participant_status, pm_date, wq_paired_site, wq_paired_org, health_pro_email, health_pro_phone, health_pro_login_phone, gror_consent, gror_consent_d, core_participant_d, deactivation_status, deactivation_date, required_ppi_complete_y, completed_surveys, basics_ppi_complete_y, basics_ppi_complete_d, health_ppi_complete_y, health_ppi_complete_d, lifestyle_ppi_complete_y, lifestyle_ppi_complete_d, history_ppi_complete_y, history_ppi_complete_d, meds_ppi_complete_y, meds_ppi_complete_d, family_ppi_complete_y, family_ppi_complete_d, access_ppi_complete_y, access_ppi_complete_d, copemay_complete_y, copemay_complete_d, copejune_complete_y, copejune_complete_d, copejuly_complete_y, copejuly_complete_d)
    consent_d = Date.parse(consent_d) if consent_d
    ehr_consent_d = Date.parse(ehr_consent_d) if ehr_consent_d
    withdrawal_d = Date.parse(withdrawal_d) if withdrawal_d
    pm_date = Date.parse(pm_date) if pm_date
    gror_consent_d = Date.parse(gror_consent_d) if gror_consent_d
    core_participant_d = Date.parse(core_participant_d) if core_participant_d
    deactivation_date = Date.parse(deactivation_date) if deactivation_date
    basics_ppi_complete_d = Date.parse(basics_ppi_complete_d) if basics_ppi_complete_d
    health_ppi_complete_d = Date.parse(health_ppi_complete_d) if health_ppi_complete_d
    lifestyle_ppi_complete_d = Date.parse(lifestyle_ppi_complete_d) if lifestyle_ppi_complete_d
    history_ppi_complete_d = Date.parse(history_ppi_complete_d) if history_ppi_complete_d
    meds_ppi_complete_d = Date.parse(meds_ppi_complete_d) if meds_ppi_complete_d
    family_ppi_complete_d = Date.parse(family_ppi_complete_d) if family_ppi_complete_d
    access_ppi_complete_d = Date.parse(access_ppi_complete_d) if access_ppi_complete_d
    copemay_complete_d = Date.parse(copemay_complete_d) if copemay_complete_d
    copejune_complete_d = Date.parse(copejune_complete_d) if copejune_complete_d
    copejuly_complete_d = Date.parse(copejuly_complete_d) if copejuly_complete_d


    if (withdrawn_y == HealthPro::HEALTH_PRO_API_WITHDRAWAL_STATUS_NO_USE || deactivation_status == HealthPro::HEALTH_PRO_API_DEACTIVATION_STATUS_NO_CONTACT)
    payload = {
        :token => @api_token,
        :content => 'record',
        :format => 'csv',
        :type => 'flat',
        :overwriteBehavior => 'overwrite',
        :data => %(record_id,pmi_id,healthpro_y,healthpro_status_complete,consent,consent_d,ehr_consent,ehr_consent_d,withdrawn_y,withdrawal_d,donotcontact,wq_participant_status,pm_date,wq_paired_site,wq_paired_org,health_pro_email,health_pro_phone,health_pro_login_phone,gror_consent,gror_consent_d,core_participant_d,deactivation_status,deactivation_date,required_ppi_complete_y,completed_surveys,basics_ppi_complete_y,basics_ppi_complete_d,health_ppi_complete_y,health_ppi_complete_d,lifestyle_ppi_complete_y,lifestyle_ppi_complete_d,history_ppi_complete_y,history_ppi_complete_d,meds_ppi_complete_y,meds_ppi_complete_d,family_ppi_complete_y,family_ppi_complete_d,access_ppi_complete_y,access_ppi_complete_d,copemay_complete_y,copemay_complete_d,copejune_complete_y,copejune_complete_d,copejuly_complete_y,copejuly_complete_d
"#{record_id}","#{pmi_id}","1","2","#{consent}","#{consent_d}","#{ehr_consent}","#{ehr_consent_d}","#{map_withdrawn_y(withdrawn_y)}","#{withdrawal_d}","1","#{wq_participant_status}","#{pm_date}","#{wq_paired_site}","#{wq_paired_org}","#{health_pro_email}","#{health_pro_phone}","#{health_pro_login_phone}","#{gror_consent}","#{gror_consent_d}","#{core_participant_d}","#{map_deactivation_status(deactivation_status)}","#{deactivation_date}","#{map_required_ppi_complete_y(required_ppi_complete_y)}","#{completed_surveys}","#{map_y_column(basics_ppi_complete_y)}","#{basics_ppi_complete_d}","#{map_y_column(health_ppi_complete_y)}","#{health_ppi_complete_d}","#{map_y_column(lifestyle_ppi_complete_y)}","#{lifestyle_ppi_complete_d}","#{map_y_column(history_ppi_complete_y)}","#{history_ppi_complete_d}","#{map_y_column(meds_ppi_complete_y)}","#{meds_ppi_complete_d}","#{map_y_column(family_ppi_complete_y)}","#{family_ppi_complete_d}","#{map_y_column(access_ppi_complete_y)}","#{access_ppi_complete_d}","#{map_y_column(copemay_complete_y)}","#{copemay_complete_d}","#{map_y_column(copejune_complete_y)}","#{copejune_complete_d}","#{map_y_column(copejuly_complete_y)}","#{copejuly_complete_d}"),
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
        :data => %(record_id,pmi_id,healthpro_y,healthpro_status_complete,consent,consent_d,ehr_consent,ehr_consent_d,withdrawn_y,withdrawal_d,wq_participant_status,pm_date,wq_paired_site,wq_paired_org,health_pro_email,health_pro_phone,health_pro_login_phone,gror_consent,gror_consent_d,core_participant_d,deactivation_status,deactivation_date,required_ppi_complete_y,completed_surveys,basics_ppi_complete_y,basics_ppi_complete_d,health_ppi_complete_y,health_ppi_complete_d,lifestyle_ppi_complete_y,lifestyle_ppi_complete_d,history_ppi_complete_y,history_ppi_complete_d,meds_ppi_complete_y,meds_ppi_complete_d,family_ppi_complete_y,family_ppi_complete_d,access_ppi_complete_y,access_ppi_complete_d,copemay_complete_y,copemay_complete_d,copejune_complete_y,copejune_complete_d,copejuly_complete_y,copejuly_complete_d
"#{record_id}","#{pmi_id}","1","2","#{consent}","#{consent_d}","#{ehr_consent}","#{ehr_consent_d}","#{map_withdrawn_y(withdrawn_y)}","#{withdrawal_d}","#{wq_participant_status}","#{pm_date}","#{wq_paired_site}","#{wq_paired_org}","#{health_pro_email}","#{health_pro_phone}","#{health_pro_login_phone}","#{gror_consent}","#{gror_consent_d}","#{core_participant_d}","#{map_deactivation_status(deactivation_status)}","#{deactivation_date}","#{map_required_ppi_complete_y(required_ppi_complete_y)}","#{completed_surveys}","#{map_y_column(basics_ppi_complete_y)}","#{basics_ppi_complete_d}","#{map_y_column(health_ppi_complete_y)}","#{health_ppi_complete_d}","#{map_y_column(lifestyle_ppi_complete_y)}","#{lifestyle_ppi_complete_d}","#{map_y_column(history_ppi_complete_y)}","#{history_ppi_complete_d}","#{map_y_column(meds_ppi_complete_y)}","#{meds_ppi_complete_d}","#{map_y_column(family_ppi_complete_y)}","#{family_ppi_complete_d}","#{map_y_column(access_ppi_complete_y)}","#{access_ppi_complete_d}","#{map_y_column(copemay_complete_y)}","#{copemay_complete_d}","#{map_y_column(copejune_complete_y)}","#{copejune_complete_d}","#{map_y_column(copejuly_complete_y)}","#{copejuly_complete_d}"),
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

    def map_withdrawn_y(withdrawn_y)
      mapped_withdrawn = case withdrawn_y
      when HealthPro::HEALTH_PRO_API_WITHDRAWAL_STATUS_NOT_WITHDRAWN
        '0'
      when HealthPro::HEALTH_PRO_API_WITHDRAWAL_STATUS_NO_USE
        '1'
      end
    end

    def map_deactivation_status(deactivation_status)
      mapped_deactivation_status = case deactivation_status
      when HealthPro::HEALTH_PRO_API_DEACTIVATION_STATUS_NOT_SUSPENDED
        '0'
      when HealthPro::HEALTH_PRO_API_DEACTIVATION_STATUS_NO_CONTACT
        '1'
      end
    end

    def map_required_ppi_complete_y(required_ppi_complete_y)
      mapped_required_ppi_complete_y = case required_ppi_complete_y
      when '0', '1', '2'
        '0'
      when '3'
        '1'
      end
    end

    def map_y_column(y_column)
      mapped_y_column = case y_column
      when 'UNSET', 'SUBMITTED_NO_CONSENT', 'SUBMITTED_NOT_SURE','SUBMITTED_INVALID'
        '0'
      when 'SUBMITTED'
        '1'
      end
    end
end