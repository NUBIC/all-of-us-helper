class AddBatchInvitationCodeIntoInvitationCodes < ActiveRecord::Migration[5.1]
  def change
    add_column :invitation_codes, :batch_invitation_code_id, :integer
  end
end
