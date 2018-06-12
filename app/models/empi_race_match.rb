class EmpiRaceMatch <  ApplicationRecord
  has_paper_trail
  belongs_to :empi_match
  belongs_to :race
end