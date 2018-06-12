class CreateEmpiRaceMatches < ActiveRecord::Migration[5.1]
  def change
    create_table :empi_race_matches do |t|
      t.integer :empi_match_id,   null: false
      t.integer :race_id,   null: false
      t.timestamps
    end
  end
end
