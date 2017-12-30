class BatchInvitationCodesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_batch_invitation_code, only: [:update]

  def new
    authorize BatchInvitationCode
    @batch_invitation_code = BatchInvitationCode.new()
  end

  def create
    authorize BatchInvitationCode

    add_file_uload('invitation_code_file')

    @batch_invitation_code = BatchInvitationCode.new(batch_invitation_code_params)

    remove_file_uload('invitation_code_file')

    if @batch_invitation_code.valid? && @batch_invitation_code.import
      flash[:success] = 'You have successfully uploaded invitation codes.'
      redirect_to invitation_codes_url() and return
    else
      flash.now[:alert] = 'Failed to upload invitation codes.'
      render action: 'new'
    end
  end

  private
    def batch_invitation_code_params
      params.require(:batch_invitation_code).permit(:invitation_code_file, :invitation_code_file_cache)
    end

    def add_file_uload(file)
      if !params[:batch_invitation_code]["#{file}_cache".to_sym].blank? && params[:batch_invitation_code][file.to_sym].blank?
        params[:batch_invitation_code][file.to_sym] = params[:batch_invitation_code]["#{file}_cache".to_sym]
      end
    end

    def remove_file_uload(file)
      if params[:batch_invitation_code]["#{file}_cache".to_sym].blank? && params[:batch_invitation_code][file.to_sym].blank?
        @batch_invitation_code[file.to_sym] = nil
      end
    end

    def load_batch_invitation_code
      @batch_invitation_code = BatchInvitationCode.find(:id)
    end
end