class AddHealthProApiFieldsToHealthPros3 < ActiveRecord::Migration[5.1]
  def change
    add_column :health_pros, :cope_nov_ppi_survey_complete, :string
    add_column :health_pros, :cope_nov_ppi_survey_completion_date, :string
    add_column :health_pros, :retention_status, :string
    add_column :health_pros, :ehr_data_transfer, :string
    add_column :health_pros, :most_recent_ehr_receipt, :string
    add_column :health_pros, :saliva_collection, :string
    add_column :health_pros, :cope_dec_ppi_survey_complete, :string
    add_column :health_pros, :cope_dec_ppi_survey_completion_date, :string
  end
end
