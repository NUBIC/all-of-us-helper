require 'rest_client'
class StudyTrackerApi
  SEARCH_TYPE_IDENTIFIERS = 'identifiers'
  SEARCH_TYPE_DEMOGRAPHICS = 'demographics'
  SEARCH_TYPES = [SEARCH_TYPE_IDENTIFIERS, SEARCH_TYPE_DEMOGRAPHICS]

  def initialize
    if Rails.env.development? || Rails.env.test?
      @verify_ssl = Rails.configuration.custom.app_config['study_tracker'][Rails.env]['verify_ssl'] || true
    else
      @verify_ssl = true
    end
  end

  def empi_lookup(options)
    options = { 'study_id' => 'STU00204480', 'proxy_user' => 'jho502', 'search_type' => StudyTrackerApi::SEARCH_TYPE_DEMOGRAPHICS }.merge(options)
    # url = Rails.configuration.custom.app_config['study_tracker'][Rails.env]['empi_lookup'] + '?' + options.to_query
    url = Rails.configuration.custom.app_config['study_tracker'][Rails.env]['empi_lookup'] + '?' + URI.encode_www_form(options)
    api_response = study_tracker_api_request_wrapper(url: url, method: :get, parse_response: true)
    { response: api_response[:response], error: api_response[:error] }
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
            user: 'api_user',
            password: 'test',
            accept: 'json',
            verify_ssl: @verify_ssl,
            headers: {
              content_type: 'application/json; charset=utf-8'
            }
          )
        else
           response = RestClient::Request.execute(
            method: options[:method],
            url: options[:url],
            payload: "'#{options[:payload]}'",
            content_type:  'application/json',
            accept: 'json',
            verify_ssl: @verify_ssl,
            headers: {
              content_type: 'application/json; charset=utf-8'
            }
          )
        end
        response = JSON.parse(response) if options[:parse_response]
      rescue Exception => e
        error = e
        Rails.logger.info(e.class)
        Rails.logger.info(e.message)
        Rails.logger.info(e.backtrace.join("\n"))
      end
      { response: response, error: error }
    end
end