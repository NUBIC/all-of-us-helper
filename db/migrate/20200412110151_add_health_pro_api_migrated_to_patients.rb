class AddHealthProApiMigratedToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :health_pro_api_migrated, :boolean
  end
end
