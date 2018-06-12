class CreateEmpiMatches < ActiveRecord::Migration[5.1]
  def change
    create_table :empi_matches do |t|
      t.integer :health_pro_id,   null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date   :birth_date, null: false
      t.string :address, null: true
      t.string :gender,   null: true
      t.string :nmhc_mrn,   null: false
      t.string :ethnicity,   null: true
      t.timestamps
    end
  end
end
