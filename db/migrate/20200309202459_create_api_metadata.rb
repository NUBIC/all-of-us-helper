class CreateApiMetadata < ActiveRecord::Migration[5.1]
  def change
    create_table :api_metadata do |t|
      t.string    :system,           null: false
      t.string    :api_operation,    null: false
      t.datetime  :last_called_at,   null: false
      t.timestamps
    end
  end
end
