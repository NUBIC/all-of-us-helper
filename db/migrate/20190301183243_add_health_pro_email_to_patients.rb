class AddHealthProEmailToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :health_pro_email, :string
  end
end
