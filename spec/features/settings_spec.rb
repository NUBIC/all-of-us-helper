require 'rails_helper'
RSpec.feature 'Settings', type: :feature do
  before(:each) do
    Setting.create!(auto_assign_invitation_codes: true)
    @harold_user = FactoryGirl.create(:user, username: 'hbaines')
    Role.setup
    @harold_user.roles << Role.where(name: Role::ROLE_ALL_OF_US_HELPER_USER).first
    @harold_user.save!
    login_as(@harold_user, scope: :user)
    visit root_path
  end

  scenario 'Updating settings', js: true, focus: false do
    click_link('Settings')
    expect(page.has_checked_field?('Auto-assign Invitation Codes?')).to be_truthy
    uncheck('Auto-assign Invitation Codes?')
    click_button('Save')
    sleep(1)
    expect(page.has_checked_field?('Auto-assign Invitation Codes?')).to be_falsy
  end
end