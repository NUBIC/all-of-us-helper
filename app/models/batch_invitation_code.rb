require 'csv'
class BatchInvitationCode < ApplicationRecord
  has_paper_trail
  mount_uploader :invitation_code_file, InvitationCodeFileUploader
  has_many :invitation_codes
  validates_associated :invitation_codes
  validates_presence_of :invitation_code_file
  validates_size_of :invitation_code_file, maximum: 10.megabytes, message: 'must be less than 10MB'

  after_destroy :remove_invitation_code_file!

  def import
    begin
      invitation_codes_from_file = CSV.new(File.open(invitation_code_file.current_path), headers: true, col_sep: ",", return_headers: false,  quote_char: "\"")
      codes = invitation_codes_from_file.map{ |invitation_code_from_file| invitation_code_from_file.to_hash['invitation_code'] }
      code_counts = Hash[codes.group_by(&:itself).map {|k,v| [k, v.size] }]

      if code_counts.values.uniq.compact != [1]
        errors.add(:base, 'Duplicate codes within invitation code file.')
      end

      if errors.empty?
        codes.each do |code|
          invitation_codes.build(code: code)
        end

        save
      else
        false
      end
    rescue Exception => e
      errors.add(:base, 'Un-handled error uploading invitation code file.')
      Rails.logger.info(e.class)
      Rails.logger.info(e.message)
      Rails.logger.info(e.backtrace.join("\n"))
      false
    end
  end
end