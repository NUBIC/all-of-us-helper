class AddHealthProColumnsToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :general_consent_status, :string
    add_column :patients, :general_consent_date, :string

    add_column :patients, :ehr_consent_status, :string
    add_column :patients, :ehr_consent_date, :string

    add_column :patients, :withdrawal_status, :string
    add_column :patients, :withdrawal_date, :string

    add_column :patients, :biospecimens_location, :string
  end
end