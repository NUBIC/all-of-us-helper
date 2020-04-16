class CreatePatientHealthProApiMigrations < ActiveRecord::Migration[5.1]
  def change
    create_table :patient_health_pro_api_migrations do |t|
      t.string "record_id", null: false
      t.string "first_name", null: false
      t.string "last_name", null: false
      t.string "email"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "pmi_id"
      t.string "gender"
      t.string "nmhc_mrn"
      t.string "registration_status"
      t.string "general_consent_status"
      t.string "general_consent_date"
      t.string "ehr_consent_status"
      t.string "ehr_consent_date"
      t.string "withdrawal_status"
      t.string "withdrawal_date"
      t.string "biospecimens_location"
      t.string "uuid"
      t.date "birth_date"
      t.string "ethnicity"
      t.string "participant_status"
      t.datetime "deleted_at"
      t.string "physical_measurements_completion_date"
      t.string "paired_site"
      t.string "paired_organization"
      t.string "health_pro_email"
      t.string "health_pro_login_phone"
      t.string "phone_1"
      t.boolean "health_pro_api_migrated"
    end
  end
end