class AddParticipantStatusToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :participant_status, :string
  end
end
