class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_setting, only: [:edit, :update]

  def edit
    authorize @settings
  end

  def update
    authorize @settings
    if @settings.update_attributes(settings_params)
      flash[:success] = 'Settings were successfully updated.'
      redirect_to edit_settings_url
    else
      flash[:alert] = 'Failed to update settings.'
      render :edit
    end
  end

  private
    def settings_params
      params.require(:setting).permit(:auto_assign_invitation_codes)
    end

    def load_setting
      @settings = Setting.first
    end
end