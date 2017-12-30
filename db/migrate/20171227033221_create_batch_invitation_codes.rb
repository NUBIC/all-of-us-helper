class CreateBatchInvitationCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :batch_invitation_codes do |t|
      t.string    :invitation_code_file,  null: true
      t.timestamps
    end
  end
end
