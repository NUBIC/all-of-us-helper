class AddNewFirstDateColumnsToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :date_of_first_primary_consent, :string
    add_column :patients, :date_of_first_ehr_consent, :string
  end
end
