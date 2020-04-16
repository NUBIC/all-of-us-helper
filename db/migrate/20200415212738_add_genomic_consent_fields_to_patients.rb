class AddGenomicConsentFieldsToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :genomic_consent_status, :string
    add_column :patients, :genomic_consent_status_date, :string
  end
end
