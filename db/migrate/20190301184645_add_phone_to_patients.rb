class AddPhoneToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :phone_1, :string
  end
end
