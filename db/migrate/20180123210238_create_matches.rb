class CreateMatches < ActiveRecord::Migration[5.1]
  def change
    create_table :matches do |t|
      t.integer :health_pro_id,   null: false
      t.integer :patient_id,      null: false
      t.string :status,           null: false
      t.timestamps
    end
  end
end
