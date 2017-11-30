require 'rails_helper'
RSpec.feature 'Patients', type: :feature do
  before(:each) do
    @patient_1 = FactoryGirl.create(:patient, record_id: '1', first_name: 'Little', last_name: 'My', email: 'little.my@moomin.com')
    @patient_2 = FactoryGirl.create(:patient, record_id: '2', first_name: 'The', last_name: 'Groke', email: 'the.groke@moomin.com')
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
end

def match_patient_row(patient, index)
  expect(all('.patient')[index].find('.last_name')).to have_content(patient[:last_name])
end

def not_match_patient(patient)
  expect(page).to_not have_content(patient[:last_name])
end