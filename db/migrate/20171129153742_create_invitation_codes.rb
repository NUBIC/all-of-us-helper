class CreateInvitationCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :invitation_codes do |t|
      t.string  :code,  null: false
      t.string  :assignment_status,  null: false
      t.timestamps null: false
    end
  end
end
