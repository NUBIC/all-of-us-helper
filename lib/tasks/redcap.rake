require 'redcap_api'
namespace :redcap do
  desc 'Assign invitation codes'
  task(assign_invitation_codes: :environment) do  |t, args|
    begin
      setting = Setting.first
      if setting.auto_assign_invitation_codes
        api_token = ApiToken.where(api_token_type: ApiToken::API_TOKEN_TYPE_REDCAP).first
        raise 'No RedCAP API token is setup.' if api_token.blank?
        redcap_api = RedcapApi.new(api_token.token)

        pending_invitation_code_assignments = redcap_api.pending_invitation_code_assignments
        if pending_invitation_code_assignments[:error].blank? && pending_invitation_code_assignments[:response].any?
          pending_invitation_code_assignments[:response].each do |pending_invitation_code_assignment|
            record_id = pending_invitation_code_assignment['record_id']
            redcap_patient = redcap_api.patient(record_id)
            if redcap_patient[:error].blank? && redcap_patient[:response].present?
              patient = Patient.create_or_update!(redcap_patient[:response].slice('record_id', 'first_name', 'last_name', 'email'))
              patient.assign_invitation_code(redcap_api)
              raise "Error assigning invitation code to record_id #{record_id}." if patient.errors.any?
            end
          end
        end
      end
    rescue => error
      handle_error(t, error)
    end
  end

  desc "Synch patients."
  task(synch_patients: :environment) do  |t, args|
    redcap_api = RedcapApi.initialize_redcap_api
    patients = redcap_api.patients
    if patients[:error].blank? && patients[:response].any?
      patients[:response].each do |patient|
        patient = patient.slice('record_id', 'first_name', 'last_name', 'email')
        patient['first_name'].strip!
        patient['last_name'].strip!
        @patient = Patient.where(record_id: patient['record_id']).first
        if @patient.blank?
          if patient['first_name'].present? && patient['last_name'].present?
            @patient = Patient.create!(patient)
          end
        else
          @patient.first_name = patient['first_name']
          @patient.last_name = patient['last_name']
          @patient.email = patient['email']
          @patient.save!
        end
      end
    end
  end

  desc "Synch deleted patients."
  task(synch_deleted_patients: :environment) do  |t, args|
    redcap_api = RedcapApi.initialize_redcap_api
    patients = redcap_api.patients

    record_ids = patients[:response].map { |patient| patient['record_id']  }
    Patient.where('record_id != pmi_id OR pmi_id IS NULL').each do |patient|
      puts patient.record_id
      if !record_ids.include?(patient.record_id)
        if patient.matched?
          patient.pmi_id = nil
        end
        patient.soft_delete!
      end
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