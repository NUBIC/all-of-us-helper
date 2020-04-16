class AddOtherHealthProPhoneToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :health_pro_phone, :string
  end
end
