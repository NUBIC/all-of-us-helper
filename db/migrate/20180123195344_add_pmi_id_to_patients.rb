class AddPmiIdToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :pmi_id, :string
  end
end