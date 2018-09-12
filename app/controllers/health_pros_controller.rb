class HealthProsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_health_pro, only: :update

  def update
    authorize @health_pro
    if @health_pro.update_attributes(health_pro_params)
      flash[:success] = 'Healthpro were successfully updated.'
    else
      flash[:alert] = 'Failed to update heatlpro.'
    end
  end

  private
    def health_pro_params
      params.require(:health_pro).permit(:id, :status)
    end

    def load_health_pro
      @health_pro = HealthPro.find(params[:id])
    end
end