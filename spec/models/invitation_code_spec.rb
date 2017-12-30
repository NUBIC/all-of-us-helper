require 'rails_helper'
require 'active_support'

RSpec.describe InvitationCode, type: :model do
  it { should have_one :invitation_code_assignment }
  it { should validate_presence_of :code }
  it { should validate_uniqueness_of :code }

  before(:each) do
    @invitation_code_1 = FactoryBot.create(:invitation_code, code: '1A')
    @invitation_code_2 = FactoryBot.create(:invitation_code, code: '2B')
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

  it 'can get an unassigned invitation code', focus: false do
    @invitation_code_3 = FactoryBot.create(:invitation_code, code: '3C', assignment_status: InvitationCode::ASSIGNMENT_STATUS_ASSIGNED)
    invitation_code = InvitationCode.get_unassigned_invitation_code
    expect([@invitation_code_1, @invitation_code_2]).to include(invitation_code)
  end

  it 'returns nil if no unassigned invitation code are available', focus: false do
    [@invitation_code_1, @invitation_code_2].each do |invitation_code|
      invitation_code.assignment_status = InvitationCode::ASSIGNMENT_STATUS_ASSIGNED
      invitation_code.save!
    end
    invitation_code = InvitationCode.get_unassigned_invitation_code
    expect(invitation_code).to be_nil
  end
end