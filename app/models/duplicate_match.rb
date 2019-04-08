class DuplicateMatch <  ApplicationRecord
  has_paper_trail
  belongs_to :health_pro
  belongs_to :patient
end