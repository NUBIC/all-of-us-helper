class PatientFeature <  ApplicationRecord
  FEATURE_NO_NMHC_MRN = 'No NMHC MRN'
  FEATURES = [FEATURE_NO_NMHC_MRN]
  belongs_to :patient
  validates_presence_of :patient_id
end