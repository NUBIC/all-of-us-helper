class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_setting, only: [:edit, :update]

  def edit
  end

  def update
    if @setting.update_attributes(setting_params)
      flash[:success] = 'Settings were successfully updated.'
      redirect_to edit_setting_url(@setting)
    else
      flash[:alert] = 'Failed to update settings.'
      render :edit
    end
  end

  private
    def setting_params
      params.require(:setting).permit(:auto_assign_invitation_codes)
    end

    def load_setting
      @setting = Setting.find(params[:id])
    end
end