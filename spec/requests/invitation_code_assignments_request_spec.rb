require 'rails_helper'
describe InvitationCodeAssignmentsController, type: :request do
  before(:each) do
    Setting.create!(auto_assign_invitation_codes: true)
    @patient_1 = FactoryGirl.create(:patient, record_id: '1', first_name: 'Little', last_name: 'My', email: 'little.my@moomin.com')
    @patient_2 = FactoryGirl.create(:patient, record_id: '2', first_name: 'The', last_name: 'Groke', email: 'the.groke@moomin.com')
    @invitation_code_1 = FactoryGirl.create(:invitation_code, code: '1A')
    @invitation_code_2 = FactoryGirl.create(:invitation_code, code: '2B')
    FactoryGirl.create(:api_token, api_token_type: ApiToken::API_TOKEN_TYPE_REDCAP, token: 'foo')
    @api_token = ApiToken.where(api_token_type: ApiToken::API_TOKEN_TYPE_REDCAP).first
    @harold_user = FactoryGirl.create(:user, username: 'hbaines')
  end

  describe 'regular user without a role' do
    before(:each) do
      sign_in @harold_user
    end

    it 'should deny access to create an invitation code assignment ', focus: false do
      post patient_invitation_code_assignments_url(patient_id: @patient_1.id), params: { invitation_code_assignment: {  } }
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

    it 'should allow access to create an invitation code assignment ', focus: false do
      allow_any_instance_of(RedcapApi).to receive(:assign_invitation_code).and_return({ resposne: { "count"=> 1}, error: nil })
      post patient_invitation_code_assignments_url(patient_id: @patient_1.id), params: { invitation_code_assignment: {  } }
      expect(response).to redirect_to(patient_url(@patient_1))
    end
  end
end