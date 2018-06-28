class Nickname < ActiveRecord::Base
  has_many :other_names, class_name: 'Nickname',  foreign_key: "nickname_id"
  belongs_to :master_nickname, class_name: 'Nickname', optional: true

  scope :for, ->(name) do
    where(["nickname_id IN (SELECT id FROM nicknames WHERE name = LOWER(?))", name])
  end
end