class AddHealthProApiFieldsToHealthPros2 < ActiveRecord::Migration[5.1]
  def change
    add_column :health_pros, :consent_for_genomics_ror, :string
    add_column :health_pros, :consent_for_genomics_ror_date, :string
  end
end