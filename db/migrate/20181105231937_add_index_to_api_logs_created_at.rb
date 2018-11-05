class AddIndexToApiLogsCreatedAt < ActiveRecord::Migration[5.1]
  def change
    add_index :api_logs, :created_at
  end
end
