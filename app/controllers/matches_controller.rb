require 'redcap_api'
class MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_match, only: :accept

  def accept
    authorize @match
    redcap_api = initialize_redcap_api
    if @match.accept!(redcap_api)
      flash[:success] = 'You have successfully made a match.'
    else
      flash[:alert] = 'Failed to make a match.'
    end
  end

  private
    def load_match
      @match = Match.find(params[:id])
    end
end