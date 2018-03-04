# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180304215220) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_tokens", force: :cascade do |t|
    t.string "api_token_type", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "batch_health_pros", force: :cascade do |t|
    t.string "health_pro_file"
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "created_user"
  end

  create_table "batch_invitation_codes", force: :cascade do |t|
    t.string "invitation_code_file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "delayed_reference_id"
    t.string "delayed_reference_type"
    t.index ["delayed_reference_id"], name: "delayed_jobs_delayed_reference_id"
    t.index ["delayed_reference_type"], name: "delayed_jobs_delayed_reference_type"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
    t.index ["queue"], name: "delayed_jobs_queue"
  end

  create_table "health_pros", force: :cascade do |t|
    t.integer "batch_health_pro_id", null: false
    t.string "status", null: false
    t.string "pmi_id"
    t.string "biobank_id"
    t.string "last_name"
    t.string "first_name"
    t.string "date_of_birth"
    t.string "language"
    t.string "general_consent_status"
    t.string "general_consent_date"
    t.string "ehr_consent_status"
    t.string "ehr_consent_date"
    t.string "cabor_consent_status"
    t.string "cabor_consent_date"
    t.string "withdrawal_status"
    t.string "withdrawal_date"
    t.string "street_address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "email"
    t.string "phone"
    t.string "sex"
    t.string "gender_identity"
    t.string "race_ethnicity"
    t.string "education"
    t.string "required_ppi_surveys_complete"
    t.string "completed_surveys"
    t.string "basics_ppi_survey_complete"
    t.string "basics_ppi_survey_completion_date"
    t.string "health_ppi_survey_complete"
    t.string "health_ppi_survey_completion_date"
    t.string "lifestyle_ppi_survey_complete"
    t.string "lifestyle_ppi_survey_completion_date"
    t.string "hist_ppi_survey_complete"
    t.string "hist_ppi_survey_completion_date"
    t.string "meds_ppi_survey_complete"
    t.string "meds_ppi_survey_completion_date"
    t.string "family_ppi_survey_complete"
    t.string "family_ppi_survey_completion_date"
    t.string "access_ppi_survey_complete"
    t.string "access_ppi_survey_completion_date"
    t.string "physical_measurements_status"
    t.string "physical_measurements_completion_date"
    t.string "physical_measurements_location"
    t.string "samples_for_dna_received"
    t.string "biospecimens"
    t.string "eight_ml_sst_collected"
    t.string "eight_ml_sst_collection_date"
    t.string "eight_ml_pst_collected"
    t.string "eight_ml_pst_collection_date"
    t.string "four_ml_na_hep_collected"
    t.string "four_ml_na_hep_collection_date"
    t.string "four_ml_edta_collected"
    t.string "four_ml_edta_collection_date"
    t.string "first_10_ml_edta_collected"
    t.string "first_10_ml_edta_collection_date"
    t.string "second_10_ml_edta_collected"
    t.string "second_10_ml_edta_collection_date"
    t.string "urine_10_ml_collected"
    t.string "urine_10_ml_collection_date"
    t.string "saliva_collected"
    t.string "saliva_collection_date"
    t.string "biospecimens_location"
  end

  create_table "invitation_code_assignments", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "invitation_code_id", null: false
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invitation_codes", force: :cascade do |t|
    t.string "code", null: false
    t.string "assignment_status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "batch_invitation_code_id"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "health_pro_id", null: false
    t.integer "patient_id", null: false
    t.string "status", null: false
  end

  create_table "patients", force: :cascade do |t|
    t.string "record_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
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
  end

  create_table "patients_races", id: :bigint, default: -> { "nextval('patient_races_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "race_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "races", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "role_assignments", force: :cascade do |t|
    t.integer "role_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.boolean "auto_assign_invitation_codes", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "username", null: false
    t.boolean "system_administrator"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
