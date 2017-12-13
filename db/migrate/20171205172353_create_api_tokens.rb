class CreateApiTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :api_tokens do |t|
      t.string  :api_token_type,  null: false
      t.string  :token,           null: false
      t.timestamps                null: false
    end
  end
end