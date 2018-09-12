class CreatePatientsRaces < ActiveRecord::Migration[5.1]
  def change
    create_table :patients_races do |t|
      t.integer :patient_id,   null: false
      t.integer :race_id,   null: false
      t.timestamps
    end
  end
end