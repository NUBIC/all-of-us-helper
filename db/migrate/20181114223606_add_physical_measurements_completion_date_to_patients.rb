class AddPhysicalMeasurementsCompletionDateToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :physical_measurements_completion_date, :string
  end
end
