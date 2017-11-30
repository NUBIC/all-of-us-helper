class PatientsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_patient, only: [:show]
  helper_method :sort_column, :sort_direction

  def index
    # authorize Patient
    params[:page]||= 1
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction
    @patients = Patient.search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  def show
    # authorize @patient
  end

  private
    def patient_params
      params.require(:patient).permit(:record_id, :first_name, :last_name, :email)
    end

    def load_patient
      @patient = Patient.find(params[:id])
    end

    def sort_column
      ['record_id', 'first_name', 'email', 'last_name'].include?(params[:sort]) ? params[:sort] : 'last_name'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end
end