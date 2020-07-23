require 'health_pro_api'
namespace :health_pro_api do
  desc "Rotate service account key"
  task(rotate_service_account_key: :environment) do |t, args|
    begin
      health_pro_api = HealthProApi.new
      health_pro_api.create_service_account_key
      health_pro_api.rotate_service_account_key
      health_pro_api.delete_project_service_account_key
      health_pro_api.archive_service_account_key
    rescue => error
      handle_error(t, error)
    end
  end

  # RAILS_ENV=production bundle exec rake health_pro_api:import_api["?"]
  desc "Import API"
  task :import_api, [:pmi_id] => [:environment] do |t, args|
    batch_health_pro = BatchHealthPro.new
    batch_health_pro.batch_type = BatchHealthPro::BATCH_TYPE_HEALTH_PRO_API
    batch_health_pro.health_pro_file = nil
    batch_health_pro.created_user = 'mjg994'
    batch_health_pro.save!
    options = {}
    options[:update_previously_matched] = true
    if args[:pmi_id].present?
      pmi_id = args[:pmi_id]
      pmi_id.gsub!('P','')
      pmi_id = pmi_id.to_i
      options[:participantId] = pmi_id
    end
    batch_health_pro.import_api(options)
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