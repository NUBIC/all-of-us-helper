class CreateNicknames < ActiveRecord::Migration[5.1]
  def change
    create_table :nicknames do |t|
      t.string :name,             null: false
      t.integer :nickname_id,     null: true
      t.timestamps
    end
  end
end