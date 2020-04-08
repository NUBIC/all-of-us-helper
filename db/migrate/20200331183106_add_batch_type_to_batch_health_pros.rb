class AddBatchTypeToBatchHealthPros < ActiveRecord::Migration[5.1]
  def change
    add_column :batch_health_pros, :batch_type, :string
  end
end
