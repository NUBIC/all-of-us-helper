class CreatePatientEmpiMatches < ActiveRecord::Migration[5.1]
  def change
    create_table :patient_empi_matches do |t|
      t.integer :patient_id,   null: false
      t.integer :empi_match_id,   null: false
    end
  end
end