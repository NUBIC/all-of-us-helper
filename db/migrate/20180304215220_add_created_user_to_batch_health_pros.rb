class AddCreatedUserToBatchHealthPros < ActiveRecord::Migration[5.1]
  def change
    add_column :batch_health_pros, :created_user, :string
  end
end
