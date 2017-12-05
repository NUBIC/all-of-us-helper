require 'rails_helper'
require 'active_support'

RSpec.describe InvitationCodeAssignment, type: :model do
  it { should belong_to :patient }
  it { should belong_to :invitation_code }

  it { should validate_presence_of :invitation_code_id }

  before(:each) do
    @patient_1 = FactoryGirl.create(:patient, record_id: '1', first_name: 'Little', last_name: 'My', email: 'little.my@moomin.com')
    @patient_2 = FactoryGirl.create(:patient, record_id: '2', first_name: 'The', last_name: 'Groke', email: 'the.groke@moomin.com')
    @invitation_code_1 = FactoryGirl.create(:invitation_code, code: '1A')
    @invitation_code_2 = FactoryGirl.create(:invitation_code, code: '2B')
  end

  it "defaults active to true for a new record that does not provide an active", focus: false do
    expect(InvitationCodeAssignment.new.active).to eq(true)
  end

  it "leaves active intact for a new record that provides active", focus: false do
    expect(InvitationCodeAssignment.new(active: false).active).to eq(false)
  end

  it 'sets the assignment status of its invitation code upon creation', focus: false do
    expect(@invitation_code_1.assignment_status).to eq(InvitationCode::ASSIGNMENT_STATUS_UNASSIGNED)
    invitation_code_assignment = InvitationCodeAssignment.create(invitation_code: @invitation_code_1, patient: @patient_1)
    expect(@invitation_code_1.assignment_status).to eq(InvitationCode::ASSIGNMENT_STATUS_ASSIGNED)
  end

  it "inactivates a patient's other assignments upon creation", focus: false do
    invitation_code_assignment_1 = InvitationCodeAssignment.create(invitation_code: @invitation_code_1, patient: @patient_1)
    expect(invitation_code_assignment_1.active).to eq(true)
    invitation_code_assignment_2 = InvitationCodeAssignment.create(invitation_code: @invitation_code_2, patient: @patient_1)
    invitation_code_assignment_1.reload
    expect(invitation_code_assignment_1.active).to eq(false)
  end
end