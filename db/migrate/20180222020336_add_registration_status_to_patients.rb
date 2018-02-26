class AddRegistrationStatusToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :registration_status, :string
  end
end
