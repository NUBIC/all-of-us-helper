class AddEmpiColumnsToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :gender, :string
    add_column :patients, :nmhc_mrn, :string
    add_column :patients, :nmh_mrn, :string
    add_column :patients, :nmff_mrn, :string
    add_column :patients, :lfh_mrn, :string
  end
end