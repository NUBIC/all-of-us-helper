require 'redcap_api'
class MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_match, only: [:accept, :decline]

  def accept
    authorize @match
    redcap_api = initialize_redcap_api
    if @match.accept!(redcap_api, match_params)
      flash[:success] = 'You have successfully made a match.'
    else
      flash[:alert] = 'Failed to make a match.'
    end
  end

  def decline
    authorize @match
    if @match.decline!
      flash[:success] = 'You have successfully declined a match.'
    else
      flash[:alert] = 'Failed to decline a match.'
    end
  end

  private
    def match_params
      params.require(:match).permit(:gender, :nmhc_mrn)
    end

    def load_match
      @match = Match.find(params[:id])
    end
end