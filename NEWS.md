# PatientProfiles 1.4.5

* Add new estimates count_0, count_negative, count_positive, count_not_positive, count_not_negative + percentages by @catalamarti in #825
* Restrict count and percentage to binary variables by @catalamarti in #836
* Limit x values of density estimation to .005 and .995 percentiles of the distribution by @ablack3 in #820
* Improve summariseResult examples by @catalamarti in #827
* Add message when no result is provided in summariseResult by @catalamarti in #826
* Add new estimates count_person and count_subject by @catalamarti in #828
* Fix warning when table is no cdm_table in summariseResult by @catalamarti in #835
* Standard deviation is corrected to numeric for all variables by @catalamarti in #834

# PatientProfiles 1.4.4

* fix edge case for not present domains by @catalamarti in #815
* additional compute in intersect by @edward-burn in #817

# PatientProfiles 1.4.3

* validate concept set names to be appropiate by @catalamarti in #806
* explicit message for order by @catalamarti in #807
* allowDuplicated documentation by @catalamarti in #805
* Support local datasets by @catalamarti in #810
* Deprecate mockDisconnect by @catalamarti in #811

# PatientProfiles 1.4.2

* Allow NA values with density estimate by @catalamarti in #795

# PatientProfiles 1.4.1

* Fix pass type in expression by @edward-burn in #794

# PatientProfiles 1.4.0

* Fix readme lifecycle badge by @catalamarti in #778
* create new function `addConceptName` by @catalamarti in #783
* Support visit domain and drop non supported concepts in `addConceptIntersect` by @catalamarti in #784
* Collect in SummariseResult if median is asked in a sql server by @catalamarti in #789
* arrange strata in summariseResult by @catalamarti in #790
* Improve performance of .addIntersect by @catalamarti in #788

# PatientProfiles 1.3.1

* Validate cohort using class by @catalamarti in #773
* Use case_when in addCategories by @catalamarti in #774
* Fix binary counts in db by @catalamarti in #775

# PatientProfiles 1.3.0

* Changed addCategories by @KimLopezGuell in #734
* conceptSet allows conceptSetExpression by @catalamarti in #743
* account for integer64 counts by @catalamarti in #745
* add inObservation argument in addTable... by @catalamarti in #749
* addConceptIntersectField by @catalamarti in #747
* validate targetCohortId with og by @catalamarti in #750
* create filterInObservation by @catalamarti in #744
* create filterCohortId by @catalamarti in #748
* add benchmarkPatientProfiles by @catalamarti in #752
* Update addIntersect.R by @catalamarti in #758
* Reduce addDemographics computing time by @catalamarti in #759
* Reduce addIntersect computing time by @catalamarti in #761 #762 #764 #763
* preserve field type and add allowDuplicates arg by @catalamarti in #765
* Add `weights` argument to `summariseResult`  by @nmercadeb in #733
* Increase test coverage by @catalamarti in #768

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
