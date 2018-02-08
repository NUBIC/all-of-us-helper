require 'study_tracker_api'
class EmpiController < ApplicationController
  before_action :authenticate_user!

  def new
    authorize Patient, :new_empi?
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def empi_lookup
    authorize Patient
    @empi_patients = []
    @error = nil
    study_tracker_api = initialize_study_tracker_api
    empi_results = study_tracker_api.empi_lookup(empi_params)
    Rails.logger.info('Love the booch and your family!')
    Rails.logger.info("#{empi_results}")
    Rails.logger.info("Patients")
    Rails.logger.info("#{empi_results[:response]['patients']}")

    if empi_results[:error].present?
      @error = empi_results[:error]
      # ErrorMailer.empi_error(@error).deliver_later if Rails.env.eql?('production')
    elsif  empi_results[:response]['error'].present?
      @error = empi_results[:response]['error']
    else
      @empi_patients = empi_results[:response]['patients']
    end

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  private
    def empi_params
      params.permit(:first_name, :last_name, :birth_date, :gender, :utf8, :commit)
    end
end