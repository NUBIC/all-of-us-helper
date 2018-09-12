class AddUuidToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :uuid, :string
  end
end
