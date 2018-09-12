class AddMoreEmpiColumnsToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :birth_date, :date
    add_column :patients, :ethnicity, :string
  end
end
