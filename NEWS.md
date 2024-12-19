
# PatientProfiles 1.2.3

* Bug fix to correct NA columns when not in observation by @catalamarti

# PatientProfiles 1.2.2

* Update links and codecoverage by @catalamarti
* Distinct individuals in addObservationPeriodId() by @martaalcalde
* Remove dependencies on visOmopResults and magrittr @catalamarti

# PatientProfiles 1.2.1

* edge case where no concept in concept table by @edward-burn
* update assertions in addDeath functions by @catalamarti
* increase test coverage by @catalamarti
* add internal compute to addInObservation by @edward-burn
* conceptIntersect inObservation argument by @edward-burn

# PatientProfiles 1.2.0

* `addObservationPeriodId()` is a new function that adds the number of 
  observation period that an observation is in.
  
* Add `density` estimate to `summariseResult()`

# PatientProfiles 1.1.1

* `addCohortName` overwrites if there already exists a `cohort_name` column 
  #680 and #682.

* Correct nan and Inf for missing values #674

* Fix #670 #671

# PatientProfiles 1.1.0

* addConceptIntersect now includes records with missing end date under the 
  assumption that end date is equal to start date.
  
* add* functions have a new argument called `name` to decide if we want a 
  resultant temp table (`name = NULL`) or have a permanent table with a certain 
  name. Additional functions are provided, e.g. addDemographicsQuery, where the 
  result is not computed.

# PatientProfiles 1.0.0

* Stable release of package
