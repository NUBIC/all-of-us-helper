class AddPairedSiteAndPairedOrganizationToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :paired_site, :string
    add_column :patients, :paired_organization, :string
  end
end
