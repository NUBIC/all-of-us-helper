class AddColumnsToHealthPros < ActiveRecord::Migration[5.1]
  def change
    add_column :health_pros, :participant_status, :string
    add_column :health_pros, :paired_site, :string
    add_column :health_pros, :paired_organization, :string
  end
end
