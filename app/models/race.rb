class Race <  ApplicationRecord
  has_and_belongs_to_many :patients

  RACE_AMERICAN_INDIAN_ALASKA_NATIVE = 'American Indian/Alaska Native'
  RACE_ASIAN = 'Asian'
  RACE_BLACK_AFRICAN_AMERICAN = 'Black/African American'
  RACE_NATIVE_HAWAIIAN_OTHER_PACIFIC_ISLANDER = 'Native Hawaiian/Other Pacific Islander'
  RACE_WHITE = 'White'
  RACE_UNKNOWN_OR_NOT_REPORTED = 'Unknown or Not Reported'
  RACES = [RACE_AMERICAN_INDIAN_ALASKA_NATIVE, RACE_ASIAN, RACE_BLACK_AFRICAN_AMERICAN, RACE_NATIVE_HAWAIIAN_OTHER_PACIFIC_ISLANDER, RACE_WHITE, RACE_UNKNOWN_OR_NOT_REPORTED]
end