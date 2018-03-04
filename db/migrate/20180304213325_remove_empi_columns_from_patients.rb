class RemoveEmpiColumnsFromPatients < ActiveRecord::Migration[5.1]
  def change
    remove_column :patients, :nmh_mrn
    remove_column :patients, :nmff_mrn
    remove_column :patients, :lfh_mrn
  end
end