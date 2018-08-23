class ChangePatientsEmailNullable < ActiveRecord::Migration[5.1]
  def change
    change_column_null :patients, :email, true
  end
end
