class InvitationCodesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_invitation_code, only: [:show]
  helper_method :sort_column, :sort_direction

  def index
    # authorize InvitationCode
    params[:page]||= 1
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction
    @invitation_codes = InvitationCode.search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def show
    # authorize @invitation_code
  end

  private
    def patient_params
      params.require(:invitation_code).permit(:code)
    end

    def load_invitation_code
      @invitation_code = InvitationCode.find(params[:id])
    end

    def sort_column
      ['code'].include?(params[:sort]) ? params[:sort] : 'code'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end
end