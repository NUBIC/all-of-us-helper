class AddHealthProApiFieldsToHealthPros < ActiveRecord::Migration[5.1]
  def change
    add_column :health_pros, :middle_name, :string
    add_column :health_pros, :age_range, :string
    add_column :health_pros, :patient_status, :string
    add_column :health_pros, :core_participant_date, :string
    add_column :health_pros, :participant_origination, :string
    add_column :health_pros, :deactivation_status, :string
    add_column :health_pros, :deactivation_date, :string
  end
end