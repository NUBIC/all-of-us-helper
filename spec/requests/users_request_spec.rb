require 'rails_helper'
describe UsersController, type: :request do
  before(:each) do
    Setting.create!(auto_assign_invitation_codes: true)
    @harold_user = FactoryGirl.create(:user, username: 'hbaines', email: 'hbaines@whitesox.com')
    @paul_user = FactoryGirl.create(:user, username: 'pkonerko', email: 'pkonerko@whitesox.com')
  end

  describe 'regular user without a role' do
    before(:each) do
      sign_in @harold_user
    end

    it 'should deny access to show a user', focus: false do
      get user_url(@harold_user)
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

    it 'should allow access to show a user', focus: false do
      get user_url(@harold_user)
      expect(response).to have_http_status(:success)
    end

    it 'should deny access to show a user', focus: false do
      get user_url(@paul_user)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end
  end
end