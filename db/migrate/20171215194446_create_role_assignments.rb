class CreateRoleAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :role_assignments do |t|
      t.integer :role_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end
  end
end
