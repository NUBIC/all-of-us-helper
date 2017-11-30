class CreateInvitationCodeAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :invitation_code_assignments do |t|
      t.integer :patient_id, null: false
      t.integer :invitation_code_id, null: false
      t.boolean :active, null: false
      t.timestamps null: false
    end
  end
end