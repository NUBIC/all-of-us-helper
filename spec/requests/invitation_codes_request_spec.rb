require 'rails_helper'
describe InvitationCodesController, type: :request do
  before(:each) do
    Setting.create!(auto_assign_invitation_codes: true)
    @invitation_code_1 = FactoryBot.create(:invitation_code, code: '1A')
    @invitation_code_2 = FactoryBot.create(:invitation_code, code: '2B')
    @harold_user = FactoryBot.create(:user, username: 'hbaines')
  end

  describe 'regular user without a role' do
    before(:each) do
      sign_in @harold_user
    end

    it 'should deny access to index of invitation codes', focus: false do
      get invitation_codes_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to show an invitation code', focus: false do
      get invitation_code_url(@invitation_code_1)
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

    it 'should allow access to index of invitation codes', focus: false do
      get invitation_codes_url
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to show an invitation code', focus: false do
      get invitation_code_url(@invitation_code_1)
      expect(response).to have_http_status(:success)
    end
  end
end