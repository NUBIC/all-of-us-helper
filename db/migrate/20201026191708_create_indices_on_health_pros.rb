class CreateIndicesOnHealthPros < ActiveRecord::Migration[5.1]
  def change
    add_index(:health_pros, [:batch_health_pro_id], name: 'idx_health_pros_batch_health_pro_id')
    add_index(:health_pros, [:pmi_id], name: 'idx_health_pros_pmi_id')

  end
end
