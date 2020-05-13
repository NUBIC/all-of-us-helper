class AddHealthProApiFieldsToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :core_participant_date, :string
    add_column :patients, :deactivation_status, :string
    add_column :patients, :deactivation_date, :string
    add_column :patients, :required_ppi_surveys_complete, :string
    add_column :patients, :completed_surveys, :string
    add_column :patients, :basics_ppi_survey_complete, :string
    add_column :patients, :basics_ppi_survey_completion_date, :string
    add_column :patients, :health_ppi_survey_complete, :string
    add_column :patients, :health_ppi_survey_completion_date, :string
    add_column :patients, :lifestyle_ppi_survey_complete, :string
    add_column :patients, :lifestyle_ppi_survey_completion_date, :string
    add_column :patients, :hist_ppi_survey_complete, :string
    add_column :patients, :hist_ppi_survey_completion_date, :string
    add_column :patients, :meds_ppi_survey_complete, :string
    add_column :patients, :meds_ppi_survey_completion_date, :string
    add_column :patients, :family_ppi_survey_complete, :string
    add_column :patients, :family_ppi_survey_completion_date, :string
    add_column :patients, :access_ppi_survey_complete, :string
    add_column :patients, :access_ppi_survey_completion_date, :string
  end
end