class CreateApiErrors < ActiveRecord::Migration[5.1]
  def change
    create_table :api_errors do |t|
      t.string    :system,           null: false
      t.string    :api_operation,    null: false
      t.text      :error,            null: false
      t.timestamps
    end
  end
end
