require 'rails_helper'
describe BatchInvitationCodesController, type: :request do
  before(:each) do
    Setting.create!(auto_assign_invitation_codes: true)
    @harold_user = FactoryBot.create(:user, username: 'hbaines')
  end

  describe 'regular user without a role' do
    before(:each) do
      sign_in @harold_user
    end

    it 'should deny access to initiate a new batch invitation code', focus: false do
      get new_batch_invitation_code_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to create a batch invitation code ', focus: false do
      post batch_invitation_codes_url, params: { batch_invitation_code: { invitation_code_file: 'Moomin' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end

  describe "regular user with a 'All of Us Helper User' role" do
    before(:each) do
      Role.setup
      @harold_user.roles << Role.where(name: Role::ROLE_ALL_OF_US_HELPER_USER).first
      @harold_user.save!
      sign_in @harold_user
    end

    it 'should allow access to initiate a new batch invitation code', focus: false do
      get new_batch_invitation_code_url
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to create a batch invitation code ', focus: false do
      allow_any_instance_of(BatchInvitationCode).to receive(:valid?).and_return(true)
      allow_any_instance_of(BatchInvitationCode).to receive(:import).and_return(true)
      post batch_invitation_codes_url, params: { batch_invitation_code: { invitation_code_file: 'Moomin' } }
      expect(response).to have_http_status(:found)
      expect(flash[:success]).to eq('You have successfully uploaded invitation codes.')
    end
  end
end