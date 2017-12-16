require 'rails_helper'
RSpec.feature 'Invitation Codes', type: :feature do
  before(:each) do
    Setting.create!(auto_assign_invitation_codes: true)
    @invitation_code_1 = FactoryGirl.create(:invitation_code, code: '1A')
    @invitation_code_2 = FactoryGirl.create(:invitation_code, code: '2B')
    @harold_user = FactoryGirl.create(:user, username: 'hbaines')
    Role.setup
    @harold_user.roles << Role.where(name: Role::ROLE_ALL_OF_US_HELPER_USER).first
    @harold_user.save!
    login_as(@harold_user, scope: :user)
    visit root_path
  end

  scenario 'Visiting invitation codes and sorting', js: true, focus: false do
    click_link('Invitation Codes')
    sleep(1)
    match_invitation_code_row(@invitation_code_1, 0)
    match_invitation_code_row(@invitation_code_2, 1)

    click_link('Code')
    sleep(1)
    match_invitation_code_row(@invitation_code_2, 0)
    match_invitation_code_row(@invitation_code_1, 1)

    @invitation_code_1.assignment_status = InvitationCode::ASSIGNMENT_STATUS_ASSIGNED
    @invitation_code_1.save!
    click_link('Invitation Codes')
    select('all', from: 'Assignment Status')
    click_button('Search')
    sleep(1)
    match_invitation_code_row(@invitation_code_1, 0)
    match_invitation_code_row(@invitation_code_2, 1)

    click_link('Assignment Status')
    sleep(1)
    match_invitation_code_row(@invitation_code_1, 0)
    match_invitation_code_row(@invitation_code_2, 1)

    click_link('Assignment Status')
    sleep(1)
    match_invitation_code_row(@invitation_code_2, 0)
    match_invitation_code_row(@invitation_code_1, 1)
  end

  scenario 'Visiting patients and searching', js: true, focus: false do
    click_link('Invitation Codes')
    sleep(1)
    match_invitation_code_row(@invitation_code_1, 0)
    match_invitation_code_row(@invitation_code_2, 1)

    fill_in 'Search', with: @invitation_code_2.code
    click_button('Search')
    sleep(1)
    match_invitation_code_row(@invitation_code_2, 0)
    not_match_invitation_code(@invitation_code_1)

    click_link('Invitation Codes')
    select('all', from: 'Assignment Status')
    click_button('Search')
    sleep(1)
    match_invitation_code_row(@invitation_code_1, 0)
    match_invitation_code_row(@invitation_code_2, 1)

    click_link('Invitation Codes')
    select(InvitationCode::ASSIGNMENT_STATUS_UNASSIGNED, from: 'Assignment Status')
    click_button('Search')
    sleep(1)
    match_invitation_code_row(@invitation_code_1, 0)
    match_invitation_code_row(@invitation_code_2, 1)

    @invitation_code_1.assignment_status = InvitationCode::ASSIGNMENT_STATUS_ASSIGNED
    @invitation_code_1.save!

    click_link('Invitation Codes')
    select(InvitationCode::ASSIGNMENT_STATUS_ASSIGNED, from: 'Assignment Status')
    click_button('Search')
    sleep(1)
    match_invitation_code_row(@invitation_code_1, 0)
    not_match_invitation_code(@invitation_code_2)

    click_link('Invitation Codes')
    select(InvitationCode::ASSIGNMENT_STATUS_UNASSIGNED, from: 'Assignment Status')
    click_button('Search')
    sleep(1)
    match_invitation_code_row(@invitation_code_2, 0)
    not_match_invitation_code(@invitation_code_1)
  end

  scenario "Visiting a invitation codes's show page", js: true, focus: false do
    visit invitation_code_path(@invitation_code_1)
    sleep(1)
    expect(page).to have_css('#invitation-code-show .code', text: @invitation_code_1.code)
    expect(page).to have_css('#invitation-code-show .assignment_status', text: @invitation_code_1.assignment_status)
  end
end

def match_invitation_code_row(invitation_code, index)
  expect(all('.invitation_code')[index].find('.code')).to have_content(invitation_code[:code])
  expect(all('.invitation_code')[index].find('.assignment_status')).to have_content(invitation_code[:assignment_status])
end

def not_match_invitation_code(invitation_code)
  expect(page).to_not have_content(invitation_code[:code])
end