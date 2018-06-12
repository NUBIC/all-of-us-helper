class EmpiMatch <  ApplicationRecord
  has_paper_trail
  belongs_to :health_pro
  has_many :empi_race_matches
end