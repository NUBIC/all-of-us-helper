class AddStreetAddress2ToHealthPros < ActiveRecord::Migration[5.1]
  def change
    add_column :health_pros, :street_address2, :string
  end
end
