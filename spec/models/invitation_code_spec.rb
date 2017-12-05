require 'rails_helper'
require 'active_support'

RSpec.describe InvitationCode, type: :model do
  it { should have_one :invitation_code_assignment }

  before(:each) do
    @invitation_code_1 = FactoryGirl.create(:invitation_code, code: '1A')
    @invitation_code_2 = FactoryGirl.create(:invitation_code, code: '2B')
  end

  it 'can search across fields (by code)', focus: false do
    expect(InvitationCode.search_across_fields('1')).to match_array([@invitation_code_1])
  end

  it 'can search across fields (by code) case insensitively', focus: false do
    expect(InvitationCode.search_across_fields('1a')).to match_array([@invitation_code_1])
  end

  it 'can search across fields (and sort ascending/descending by a passed in column code)', focus: false do
    expect(InvitationCode.search_across_fields(nil, { sort_column: 'code', sort_direction: 'asc' })).to eq([@invitation_code_1, @invitation_code_2])
    expect(InvitationCode.search_across_fields(nil, { sort_column: 'code', sort_direction: 'desc' })).to eq([@invitation_code_2, @invitation_code_1])
  end

  it "defaults assignment status to 'Unassigned' for a new record that does not provide an assignment status", focus: false do
    expect(InvitationCode.new.assignment_status).to eq(InvitationCode::ASSIGNMENT_STATUS_UNASSIGNED)
  end

  it "leaves assignment status intact for a new record that provides an assignment status", focus: false do
    expect(InvitationCode.new(assignment_status: InvitationCode::ASSIGNMENT_STATUS_ASSIGNED).assignment_status).to eq(InvitationCode::ASSIGNMENT_STATUS_ASSIGNED)
  end

  it 'can search for invitation codes by assignment status', focus: false do
    @invitation_code_1.assignment_status = InvitationCode::ASSIGNMENT_STATUS_UNASSIGNED
    @invitation_code_1.save!
    @invitation_code_2.assignment_status = InvitationCode::ASSIGNMENT_STATUS_ASSIGNED
    @invitation_code_2.save!

    expect(InvitationCode.by_assignment_status(InvitationCode::ASSIGNMENT_STATUS_UNASSIGNED)).to match_array([@invitation_code_1])
    expect(InvitationCode.by_assignment_status(InvitationCode::ASSIGNMENT_STATUS_ASSIGNED)).to match_array([@invitation_code_2])
  end
end