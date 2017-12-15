class Settings < ActiveRecord::Migration[5.1]
  def change
    create_table :settings do |t|
      t.boolean  :auto_assign_invitation_codes, null: false
      t.timestamps                              null: false
    end
  end
end
