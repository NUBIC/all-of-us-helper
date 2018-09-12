class PatientEmpiMatch < ApplicationRecord
  has_paper_trail
  belongs_to :patient
  belongs_to :empi_match
end