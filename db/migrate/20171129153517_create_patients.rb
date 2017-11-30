class CreatePatients < ActiveRecord::Migration[5.1]
  def change
    create_table :patients do |t|
      t.string  :record_id,  null: false
      t.string  :first_name,  null: false
      t.string  :last_name,  null: false
      t.string  :email,  null: false
      t.timestamps null: false
    end
  end
end