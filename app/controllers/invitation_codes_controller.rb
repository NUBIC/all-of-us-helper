class InvitationCodesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_invitation_code, only: [:show]
  helper_method :sort_column, :sort_direction

  def index
    params[:page]||= 1
    params[:assignment_status]||= InvitationCode::ASSIGNMENT_STATUS_UNASSIGNED
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction
    @invitation_codes = InvitationCode.search_across_fields(params[:search], options).by_assignment_status(params[:assignment_status]).paginate(per_page: 10, page: params[:page])
  end

  def show
  end

  private
    def invitation_code_params
      params.require(:invitation_code).permit(:code)
    end

    def load_invitation_code
      @invitation_code = InvitationCode.find(params[:id])
    end

    def sort_column
      ['code', 'assignment_status'].include?(params[:sort]) ? params[:sort] : 'code'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end
end