class CreateBatchHealthPros < ActiveRecord::Migration[5.1]
  def change
    create_table :batch_health_pros do |t|
      t.string :health_pro_file, null: true
      t.string :status, null: false
      t.timestamps
    end
  end
end
