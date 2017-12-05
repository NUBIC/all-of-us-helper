require 'rails_helper'
RSpec.feature 'Patients', type: :feature do
  before(:each) do
    @patient_1 = FactoryGirl.create(:patient, record_id: '1', first_name: 'Little', last_name: 'My', email: 'little.my@moomin.com')
    @patient_2 = FactoryGirl.create(:patient, record_id: '2', first_name: 'The', last_name: 'Groke', email: 'the.groke@moomin.com')
    @invitation_code_1 = FactoryGirl.create(:invitation_code, code: '1A')
    @invitation_code_2 = FactoryGirl.create(:invitation_code, code: '2B')
    @harold_user = FactoryGirl.create(:user, username: 'hbaines')
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
  end

  scenario "Assigning a patient an invitation code", js: true, focus: false do
    click_link('Patients')
    sleep(1)
    all("#patient_#{@patient_1.id} a.new-invitation-code-assignment-link", text: 'Assign Code')[0].click
    select(@invitation_code_1.code, from: 'Invitation Code:')
    click_button('Save')
    sleep(1)
    expect(all("#patient_#{@patient_1.id} .invitation_code")[0]).to have_content(@invitation_code_1.code)
  end

  scenario "Assigning a patient an invitation code with validation", js: true, focus: false do
    click_link('Patients')
    sleep(1)
    all("#patient_#{@patient_1.id} a.new-invitation-code-assignment-link", text: 'Assign Code')[0].click
    click_button('Save')
    sleep(1)

    expect(page).to have_css('.invitation_code_id .field_with_errors')
    within(".invitation_code_id .error") do
      expect(page).to have_content("can't be blank")
    end
  end
end

def match_patient_row(patient, index)
  expect(all('.patient')[index].find('.last_name')).to have_content(patient[:last_name])
end

def not_match_patient(patient)
  expect(page).to_not have_content(patient[:last_name])
end