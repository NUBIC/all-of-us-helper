class Match <  ApplicationRecord
  has_paper_trail
  belongs_to :health_pro
  belongs_to :patient
  STATUS_PENDING        = 'pending'
  STATUS_ACCEPTED       = 'accepted'
  STATUS_DECLINED       = 'declined'
  STATUSES = [STATUS_PENDING, STATUS_ACCEPTED, STATUS_DECLINED]
  after_initialize :set_defaults

  validates_presence_of :patient_id

  scope :by_status, ->(status) do
    if status.present?
     where(status: status)
    end
  end

  def decline!(redcap_api)
    declined = nil
    begin
      Match.transaction do
        redcap_decline = redcap_api.decline(patient.record_id)
        raise "Error declining record_id  #{health_pro.pmi_id} to record_id #{patient.record_id}." if redcap_decline[:error].present?
        self.status = Match::STATUS_DECLINED
        save!
        if !health_pro.pending_matches?
          health_pro.status = HealthPro::STATUS_DECLINED
          health_pro.save!
        end
      end
      declined = true
    rescue Exception => e
      ExceptionNotifier.notify_exception(e)
      declined = false
      Rails.logger.info(e.class)
      Rails.logger.info(e.message)
      Rails.logger.info(e.backtrace.join("\n"))
    end
    declined
  end

  def accept!(redcap_api, match_params)
    accepted = nil
    begin
      self.status = Match::STATUS_ACCEPTED
      patient.pmi_id = health_pro.pmi_id
      patient.birth_date = Date.parse(health_pro.date_of_birth)
      patient.general_consent_status = health_pro.general_consent_status
      patient.general_consent_date = health_pro.general_consent_date
      patient.ehr_consent_status = health_pro.ehr_consent_status
      patient.ehr_consent_date = health_pro.ehr_consent_date
      patient.withdrawal_status = health_pro.withdrawal_status
      patient.withdrawal_date = health_pro.withdrawal_date
      patient.biospecimens_location = health_pro.biospecimens_location
      patient.participant_status = health_pro.participant_status

      if match_params[:empi_match_id].present?
        empi_match = EmpiMatch.find(match_params[:empi_match_id])
        patient.gender =  empi_match.gender
        patient.nmhc_mrn = empi_match.nmhc_mrn
        patient.ethnicity = empi_match.ethnicity if empi_match.ethnicity
        empi_match.empi_race_matches.each do |empi_race_match|
          patient.races << empi_race_match.race
        end
        patient.build_patient_empi_match(empi_match: empi_match)
      end

      patient.gender ||=  health_pro.sex_to_patient_gender
      health_pro.status = HealthPro::STATUS_MATCHED

      Match.transaction do
        redcap_match = redcap_api.match(patient.record_id, health_pro.pmi_id, health_pro.general_consent_status, health_pro.general_consent_date, health_pro.ehr_consent_status, health_pro.ehr_consent_date, health_pro.withdrawal_status, health_pro.withdrawal_date)
        raise "Error assigning pmi_id #{health_pro.pmi_id} to record_id #{patient.record_id}." if redcap_match[:error].present?
        save!
        health_pro.save!
        patient.set_registration_status
        patient.save!
      end
      accepted = true
    rescue Exception => e
      ExceptionNotifier.notify_exception(e)
      accepted = false
      Rails.logger.info(e.class)
      Rails.logger.info(e.message)
      Rails.logger.info(e.backtrace.join("\n"))
    end
    accepted
  end

  def assign_invitation_code(redcap_api, invitation_code=nil)
    invitation_code_assignment = nil
    if invitation_code.blank?
      invitation_code = InvitationCode.get_unassigned_invitation_code
    end

    begin
      Patient.transaction do
        redcap_patient_invitation_code = redcap_api.assign_invitation_code(record_id, invitation_code.code)
        raise "Error assigning invitation code #{invitation_code.code} to record_id #{record_id}." if redcap_patient_invitation_code[:error].present?
        invitation_code_assignment = invitation_code_assignments.build(invitation_code: invitation_code)
        save!
      end
    rescue Exception => e
      invitation_code_assignment = nil
      Rails.logger.info(e.class)
      Rails.logger.info(e.message)
      Rails.logger.info(e.backtrace.join("\n"))
    end
    invitation_code_assignment
  end

  def reject!
    self.status = Match::STATUS_REJECTED
    save!
  end

  private
    def set_defaults
      if self.new_record? && self.status.blank?
        self.status = Match::STATUS_PENDING
      end
    end
end