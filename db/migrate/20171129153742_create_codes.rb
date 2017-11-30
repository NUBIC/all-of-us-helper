class CreateCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :codes do |t|
      t.string  :code,  null: false
      t.timestamps null: false
    end
  end
end
