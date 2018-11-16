class CreatePatientFeatures < ActiveRecord::Migration[5.1]
  def change
    create_table :patient_features do |t|
      t.integer :patient_id,   null: false
      t.string :feature, null: false
      t.boolean :enabled, null: false
      t.timestamps
    end
  end
end
