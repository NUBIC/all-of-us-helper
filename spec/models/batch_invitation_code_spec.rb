require 'rails_helper'
require 'active_support'

RSpec.describe BatchInvitationCode, type: :model do
  it { should have_many :invitation_codes }
  it { should validate_presence_of :invitation_code_file }

  it 'can import an invitation code file', focus: false do
    expect(InvitationCode.count).to eq(0)
    batch_invitation_code = BatchInvitationCode.new(invitation_code_file: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/test_invitation_code_file.csv'))))
    batch_invitation_code.import
    expect(InvitationCode.count).to eq(5)
    invitation_codes = CSV.new(File.open('spec/fixtures/files/test_invitation_code_file.csv'), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")

    invitation_codes.sort_by { |invitation_code| invitation_code['invitation_code'] }.each_with_index do |invitation_code, i|
      expect(InvitationCode.where(code: invitation_code['invitation_code']).count).to eq(1)
    end
  end

  it 'can validate duplicate invitation codes within a file', focus: false do
    expect(InvitationCode.count).to eq(0)
    batch_invitation_code = BatchInvitationCode.new(invitation_code_file: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/test_invitation_code_file_duplicates.csv'))))
    batch_invitation_code.import
    expect(InvitationCode.count).to eq(0)
    expect(batch_invitation_code.errors).to match_array(["Duplicate codes within invitation code file."])
  end

  it 'can validate the re-reimport of a file', focus: false do
    expect(InvitationCode.count).to eq(0)
    batch_invitation_code = BatchInvitationCode.new(invitation_code_file: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/test_invitation_code_file.csv'))))
    batch_invitation_code.import
    expect(InvitationCode.count).to eq(5)
    batch_invitation_code = BatchInvitationCode.new(invitation_code_file: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/test_invitation_code_file.csv'))))
    batch_invitation_code.import
    expect(InvitationCode.count).to eq(5)
    expect(batch_invitation_code.errors).to match_array(["Invitation codes is invalid"])
  end
end