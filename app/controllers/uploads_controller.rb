class UploadsController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize Patient
  end
end