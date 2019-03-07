class AddHealthProPhoneToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :health_pro_login_phone, :string
  end
end
