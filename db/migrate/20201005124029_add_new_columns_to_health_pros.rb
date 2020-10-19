class AddNewColumnsToHealthPros < ActiveRecord::Migration[5.1]
  def change
    add_column :health_pros, :consent_cohort, :string
    add_column :health_pros, :program_update, :string
    add_column :health_pros, :date_of_program_update, :string
    add_column :health_pros, :ehr_expiration_status, :string
    add_column :health_pros, :date_of_ehr_expiration, :string
    add_column :health_pros, :date_of_first_primary_consent, :string
    add_column :health_pros, :date_of_first_ehr_consent, :string
    add_column :health_pros, :retention_eligible, :string
    add_column :health_pros, :date_of_retention_eligibility, :string
    add_column :health_pros, :deceased, :string
    add_column :health_pros, :date_of_death, :string
    add_column :health_pros, :date_of_approval, :string
  end
end


