class ApiLog < ActiveRecord::Base
  def self.create_api_log(url, payload, response, error, system)
    ApiLog.transaction(requires_new: true) do
      ApiLog.create!(
                    url: url,
                    payload: payload,
                    response: response,
                    error: error,
                    system: system
                    )
      end
  end
end