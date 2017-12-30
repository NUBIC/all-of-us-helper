require 'rails_helper'
describe PatientsController, type: :request do
  before(:each) do
    Setting.create!(auto_assign_invitation_codes: true)
    @patient_1 = FactoryBot.create(:patient, record_id: '1', first_name: 'Little', last_name: 'My', email: 'little.my@moomin.com')
    @patient_2 = FactoryBot.create(:patient, record_id: '2', first_name: 'The', last_name: 'Groke', email: 'the.groke@moomin.com')
    @invitation_code_1 = FactoryBot.create(:invitation_code, code: '1A')
    @invitation_code_2 = FactoryBot.create(:invitation_code, code: '2B')
    FactoryBot.create(:api_token, api_token_type: ApiToken::API_TOKEN_TYPE_REDCAP, token: 'foo')
    @api_token = ApiToken.where(api_token_type: ApiToken::API_TOKEN_TYPE_REDCAP).first
    @harold_user = FactoryBot.create(:user, username: 'hbaines')
  end

  describe 'regular user without a role' do
    before(:each) do
      sign_in @harold_user
    end

    it 'should deny access to index of patients', focus: false do
      get patients_url
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to show a patient', focus: false do
      get patient_url(@patient_1)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(ApplicationController::UNAUTHORIZED_MESSAGE)
    end

    it 'should deny access to the record_id resource of a patient', focus: false do
      get record_id_url(@patient_1.record_id)
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

    it 'should allow access to index of patients', focus: false do
      get patients_url
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to show a patient', focus: false do
      get patient_url(@patient_1)
      expect(response).to have_http_status(:success)
    end

    it 'should allow access to the record_id resource of a patient', focus: false do
      get record_id_url(@patient_1.record_id)
      expect(response).to redirect_to(patient_url(@patient_1))
    end
  end
end