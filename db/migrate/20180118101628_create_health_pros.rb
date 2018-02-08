class CreateHealthPros < ActiveRecord::Migration[5.1]
  def change
    create_table :health_pros do |t|
      t.integer :batch_health_pro_id, null: false
      t.string  :status, null: false
      t.string  :pmi_id,  null: true
      t.string  :biobank_id,  null: true
      t.string  :last_name,  null: true
      t.string  :first_name,  null: true
      t.string  :date_of_birth,  null: true
      t.string  :language,  null: true
      t.string  :general_consent_status,  null: true
      t.string  :general_consent_date,  null: true
      t.string  :ehr_consent_status,  null: true
      t.string  :ehr_consent_date,  null: true
      t.string  :cabor_consent_status,  null: true
      t.string  :cabor_consent_date,  null: true
      t.string  :withdrawal_status,  null: true
      t.string  :withdrawal_date,  null: true
      t.string  :street_address,  null: true
      t.string  :city,  null: true
      t.string  :state,  null: true
      t.string  :zip,  null: true
      t.string  :email,  null: true
      t.string  :phone,  null: true
      t.string  :sex,  null: true
      t.string  :gender_identity,  null: true
      #slash race_ethnicity=race/ethnicity
      t.string  :race_ethnicity,  null: true
      t.string  :education,  null: true
      t.string  :required_ppi_surveys_complete,  null: true
      t.string  :completed_surveys,  null: true
      t.string  :basics_ppi_survey_complete,  null: true
      t.string  :basics_ppi_survey_completion_date,  null: true
      t.string  :health_ppi_survey_complete,  null: true
      t.string  :health_ppi_survey_completion_date,  null: true
      t.string  :lifestyle_ppi_survey_complete,  null: true
      t.string  :lifestyle_ppi_survey_completion_date,  null: true
      t.string  :hist_ppi_survey_complete,  null: true
      t.string  :hist_ppi_survey_completion_date,  null: true
      t.string  :meds_ppi_survey_complete,  null: true
      t.string  :meds_ppi_survey_completion_date,  null: true
      t.string  :family_ppi_survey_complete,  null: true
      t.string  :family_ppi_survey_completion_date,  null: true
      t.string  :access_ppi_survey_complete,  null: true
      t.string  :access_ppi_survey_completion_date,  null: true
      t.string  :physical_measurements_status,  null: true
      t.string  :physical_measurements_completion_date,  null: true
      t.string  :physical_measurements_location,  null: true
      t.string  :samples_for_dna_received,  null: true
      t.string  :biospecimens,  null: true
      #number eight=8
      t.string  :eight_ml_sst_collected,  null: true
      #number eight=8
      t.string  :eight_ml_sst_collection_date,  null: true
      #number eight=8
      t.string  :eight_ml_pst_collected,  null: true
      #number eight=8
      t.string  :eight_ml_pst_collection_date,  null: true
      #number four=4
      #dash na_hep=na-hep
      t.string  :four_ml_na_hep_collected,  null: true
      #number four=4
      #dash na_hep=na-hep
      t.string  :four_ml_na_hep_collection_date,  null: true
      #number four=4
      t.string  :four_ml_edta_collected,  null: true
      #number four=4
      t.string  :four_ml_edta_collection_date,  null: true
      #number first=1st
      t.string  :first_10_ml_edta_collected,  null: true
      #number first=1st
      t.string  :first_10_ml_edta_collection_date,  null: true
      #number second=2nd
      t.string  :second_10_ml_edta_collected,  null: true
      t.string  :second_10_ml_edta_collection_date,  null: true
      t.string  :urine_10_ml_collected,  null: true
      t.string  :urine_10_ml_collection_date,  null: true
      t.string  :saliva_collected,  null: true
      t.string  :saliva_collection_date,  null: true
      t.string  :biospecimens_location,  null: true
    end
  end
end
