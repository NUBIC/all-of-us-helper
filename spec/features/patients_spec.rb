require 'rails_helper'
RSpec.feature 'Patients', type: :feature do
  before(:each) do
    Setting.create!(auto_assign_invitation_codes: true)
    @patient_1 = FactoryBot.create(:patient, record_id: '1', first_name: 'Little', last_name: 'My', email: 'little.my@moomin.com')
    @patient_2 = FactoryBot.create(:patient, record_id: '2', first_name: 'The', last_name: 'Groke', email: 'the.groke@moomin.com')
    @invitation_code_1 = FactoryBot.create(:invitation_code, code: '1A')
    @invitation_code_2 = FactoryBot.create(:invitation_code, code: '2B')
    FactoryBot.create(:api_token, api_token_type: ApiToken::API_TOKEN_TYPE_REDCAP, token: 'foo')
    @api_token = ApiToken.where(api_token_type: ApiToken::API_TOKEN_TYPE_REDCAP).first
    @harold_user = FactoryBot.create(:user, username: 'hbaines')
    Role.setup
    @harold_user.roles << Role.where(name: Role::ROLE_ALL_OF_US_HELPER_USER).first
    @harold_user.save!
    login_as(@harold_user, scope: :user)
    visit root_path
  end

  scenario 'Visiting patients and sorting', js: true, focus: false do
    click_link('Patients')
    sleep(1)
    match_patient_row(@patient_2, 0)
    match_patient_row(@patient_1, 1)

    click_link('Last Name')
    sleep(1)
    match_patient_row(@patient_1, 0)
    match_patient_row(@patient_2, 1)

    click_link('First Name')
    sleep(1)
    match_patient_row(@patient_1, 0)
    match_patient_row(@patient_2, 1)

    click_link('First Name')
    sleep(1)
    match_patient_row(@patient_2, 0)
    match_patient_row(@patient_1, 1)

    click_link('Record')
    sleep(1)
    match_patient_row(@patient_1, 0)
    match_patient_row(@patient_2, 1)

    click_link('Record')
    sleep(1)
    match_patient_row(@patient_2, 0)
    match_patient_row(@patient_1, 1)

    click_link('Email')
    sleep(1)
    match_patient_row(@patient_1, 0)
    match_patient_row(@patient_2, 1)

    click_link('Email')
    sleep(1)
    match_patient_row(@patient_2, 0)
    match_patient_row(@patient_1, 1)
  end

  scenario 'Visiting patients and searching', js: true, focus: false do
    click_link('Patients')
    sleep(1)
    match_patient_row(@patient_2, 0)
    match_patient_row(@patient_1, 1)

    fill_in 'Search', with: @patient_2.first_name
    click_button('Search')
    sleep(1)
    match_patient_row(@patient_2, 0)
    not_match_patient(@patient_1)

    click_link('Patients')
    sleep(1)
    match_patient_row(@patient_2, 0)
    match_patient_row(@patient_1, 1)

    fill_in 'Search', with: @patient_1.last_name
    click_button('Search')
    sleep(1)
    match_patient_row(@patient_1, 0)
    not_match_patient(@patient_2)

    click_link('Patients')
    sleep(1)
    match_patient_row(@patient_2, 0)
    match_patient_row(@patient_1, 1)

    fill_in 'Search', with: @patient_2.record_id
    click_button('Search')
    sleep(1)
    match_patient_row(@patient_2, 0)
    not_match_patient(@patient_1)

    click_link('Patients')
    sleep(1)
    match_patient_row(@patient_2, 0)
    match_patient_row(@patient_1, 1)

    fill_in 'Search', with: @patient_1.email
    click_button('Search')
    sleep(1)
    match_patient_row(@patient_1, 0)
    not_match_patient(@patient_2)
  end

  scenario "Visiting a patient's show page", js: true, focus: false do
    visit patient_path(@patient_1)
    sleep(1)
    expect(page).to have_css('#patient-show .record_id', text: @patient_1.record_id)
    expect(page).to have_css('#patient-show .first_name', text: @patient_1.first_name)
    expect(page).to have_css('#patient-show .last_name', text: @patient_1.last_name)
    expect(page).to have_css('#patient-show .email', text: @patient_1.email)
    expect(page).to have_css('#patient-show .invitation_code', text: nil)
  end

  scenario "Visiting a patient's show page and assigning an invitation code", js: true, focus: false do
    visit patient_path(@patient_1)
    sleep(1)
    expect(page).to have_css('#patient-show .record_id', text: @patient_1.record_id)
    expect(page).to have_css('#patient-show .first_name', text: @patient_1.first_name)
    expect(page).to have_css('#patient-show .last_name', text: @patient_1.last_name)
    expect(page).to have_css('#patient-show .email', text: @patient_1.email)
    expect(@patient_1.invitation_code).to be_nil
    expect(page).to have_css('#patient-show .invitation_code', text: nil)
    @patient_1.invitation_code_assignments.is_inactive.order('created_at DESC').each do |invitation_code_assignment|
      expect(find("#invitation_code_assignment_#{invitation_code_assignment.id} .date")).to have_content(invitation_code_assignment.created_at.to_s(:date_time12))
      expect(find("#invitation_code_assignment_#{invitation_code_assignment.id} .code")).to have_content(invitation_code_assignment.invitation_code.code)
    end

    allow_any_instance_of(RedcapApi).to receive(:assign_invitation_code).and_return({ resposne: { "count"=> 1}, error: nil })
    accept_confirm do
      click_button('Assign New Invitation Code')
    end
    sleep(1)

    expect(page).to have_css('#patient-show .record_id', text: @patient_1.record_id)
    expect(page).to have_css('#patient-show .first_name', text: @patient_1.first_name)
    expect(page).to have_css('#patient-show .last_name', text: @patient_1.last_name)
    expect(page).to have_css('#patient-show .email', text: @patient_1.email)
    expect(@patient_1.invitation_code).to_not be_nil
    expect(page).to have_css('#patient-show .invitation_code', text: @patient_1.invitation_code)
    @patient_1.invitation_code_assignments.is_inactive.order('created_at DESC').each do |invitation_code_assignment|
      expect(find("#invitation_code_assignment_#{invitation_code_assignment.id} .date")).to have_content(invitation_code_assignment.created_at.to_s(:date_time12))
      expect(find("#invitation_code_assignment_#{invitation_code_assignment.id} .code")).to have_content(invitation_code_assignment.invitation_code.code)
    end

    accept_confirm do
      click_button('Assign New Invitation Code')
    end
    sleep(1)
    @patient_1.invitation_code_assignments.is_inactive.order('created_at DESC').each do |invitation_code_assignment|
      expect(find("#invitation_code_assignment_#{invitation_code_assignment.id} .date")).to have_content(invitation_code_assignment.created_at.to_s(:date_time12))
      expect(find("#invitation_code_assignment_#{invitation_code_assignment.id} .code")).to have_content(invitation_code_assignment.invitation_code.code)
    end
  end

  scenario "Look up patient by REDCap 'record_id' and create the patient if not yet created", js: true, focus: false do
    record_id = '3'
    first_name = 'Stinky'
    last_name = 'Moomin'
    email = 'stinky.moomin@moomin.com'
    allow_any_instance_of(RedcapApi).to receive(:patient).with(record_id).and_return(patient_response(record_id, first_name, last_name, email))
    visit record_id_path(record_id)
    sleep(1)
    patient = Patient.where(record_id: record_id).first
    expect(current_path).to eq(patient_path(patient))
    expect(page).to have_css('#patient-show .record_id', text: record_id)
    expect(page).to have_css('#patient-show .first_name', text: first_name)
    expect(page).to have_css('#patient-show .last_name', text: last_name)
    expect(page).to have_css('#patient-show .email', text: email)
  end

  scenario "Look up patient by REDCap 'record_id' and do not recreate the patient if already created", js: true, focus: false do
    expect(Patient.where(record_id: @patient_1.record_id).count).to eq(1)
    visit record_id_path(@patient_1.record_id)
    sleep(1)
    expect(current_path).to eq(patient_path(@patient_1))
    expect(page).to have_css('#patient-show .record_id', text: @patient_1.record_id)
    expect(page).to have_css('#patient-show .first_name', text: @patient_1.first_name)
    expect(page).to have_css('#patient-show .last_name', text: @patient_1.last_name)
    expect(page).to have_css('#patient-show .email', text: @patient_1.email)
    expect(Patient.where(record_id: @patient_1.record_id).count).to eq(1)
  end

  scenario "Look up patient by REDCap 'record_id' and redirect to the home page and display an error if REDCap throws an error", js: true, focus: false do
    record_id = '3'
    first_name = 'Stinky'
    last_name = 'Moomin'
    email = 'stinky.moomin@moomin.com'
    allow_any_instance_of(RedcapApi).to receive(:patient).with(record_id).and_return({ response: nil, error: 'kaboom' })
    visit record_id_path(record_id)
    sleep(1)
    expect(current_path).to eq(root_path)
    expect(page).to have_css('#flash .alert', text: PatientsController::PATIENT_CONTROLLER_SHOW_REDCAP_ERROR)
  end
end

def match_patient_row(patient, index)
  expect(all('.patient')[index].find('.last_name')).to have_content(patient[:last_name])
end

def not_match_patient(patient)
  expect(page).to_not have_content(patient[:last_name])
end

def patient_response(record_id, first_name, last_name, email)
response = <<END_OF_STRING
[{"record_id":"#{record_id}","first_name":"#{first_name}","last_name":"#{last_name}","email":"#{email}","phone_1":"(312) 925-3268","phone1_type":"1","referralsource":"1","other_referral":"","preferred_contact":"1","preferred_time___1":"1","preferred_time___2":"0","preferred_time___3":"0","preferred_time___4":"0","preferred_time_oth":"","how_to_join_complete":"2"}]
END_OF_STRING
  response = JSON.parse(response)
  response = response.first
  { response: response, error: nil }
end