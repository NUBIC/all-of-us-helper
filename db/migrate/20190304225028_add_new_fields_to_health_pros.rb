class AddNewFieldsToHealthPros < ActiveRecord::Migration[5.1]
  def change
    add_column :health_pros, :two_ml_edta_collected, :string
    add_column :health_pros, :two_ml_edta_collected_date, :string
    add_column :health_pros, :urine_90_ml_collected, :string
    add_column :health_pros, :urine_90_ml_collection_date, :string
    add_column :health_pros, :cell_free_dna_collected, :string
    add_column :health_pros, :cell_free_dna_collected_date, :string
    add_column :health_pros, :paxgene_rna_collected, :string
    add_column :health_pros, :paxgene_rna_collected_date, :string
    add_column :health_pros, :withdrawal_reason, :string
    add_column :health_pros, :language_of_general_consent, :string
    add_column :health_pros, :dv_only_ehr_sharing_status, :string
    add_column :health_pros, :dv_only_ehr_sharing_date, :string
    add_column :health_pros, :login_phone, :string
  end
end
