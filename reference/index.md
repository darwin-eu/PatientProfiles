# Package index

### Add individual patient characteristics

Add patient characteristics to a table in the OMOP Common Data Model

- [`addAge()`](https://darwin-eu.github.io/PatientProfiles/reference/addAge.md)
  : Compute the age of the individuals at a certain date
- [`addSex()`](https://darwin-eu.github.io/PatientProfiles/reference/addSex.md)
  : Compute the sex of the individuals
- [`addDateOfBirth()`](https://darwin-eu.github.io/PatientProfiles/reference/addDateOfBirth.md)
  : Add a column with the individual birth date
- [`addPriorObservation()`](https://darwin-eu.github.io/PatientProfiles/reference/addPriorObservation.md)
  : Compute the number of days of prior observation in the current
  observation period at a certain date
- [`addFutureObservation()`](https://darwin-eu.github.io/PatientProfiles/reference/addFutureObservation.md)
  : Compute the number of days till the end of the observation period at
  a certain date
- [`addInObservation()`](https://darwin-eu.github.io/PatientProfiles/reference/addInObservation.md)
  : Indicate if a certain record is within the observation period
- [`addBirthday()`](https://darwin-eu.github.io/PatientProfiles/reference/addBirthday.md)
  **\[experimental\]** : Add the birth day of an individual to a table

### Add multiple individual patient characteristics

Add a set of patient characteristics to a table in the OMOP Common Data
Model

- [`addDemographics()`](https://darwin-eu.github.io/PatientProfiles/reference/addDemographics.md)
  : Compute demographic characteristics at a certain date

### Add death information

Add patient death information to a table in the OMOP Common Data Model

- [`addDeathDate()`](https://darwin-eu.github.io/PatientProfiles/reference/addDeathDate.md)
  :

  Add date of death for individuals. Only death within the same
  observation period than `indexDate` will be observed.

- [`addDeathDays()`](https://darwin-eu.github.io/PatientProfiles/reference/addDeathDays.md)
  :

  Add days to death for individuals. Only death within the same
  observation period than `indexDate` will be observed.

- [`addDeathFlag()`](https://darwin-eu.github.io/PatientProfiles/reference/addDeathFlag.md)
  :

  Add flag for death for individuals. Only death within the same
  observation period than `indexDate` will be observed.

### Add a value from a cohort intersection

Add a variable indicating the intersection between a table in the OMOP
Common Data Model and a cohort table.

- [`addCohortIntersectCount()`](https://darwin-eu.github.io/PatientProfiles/reference/addCohortIntersectCount.md)
  : It creates columns to indicate number of occurrences of intersection
  with a cohort
- [`addCohortIntersectDate()`](https://darwin-eu.github.io/PatientProfiles/reference/addCohortIntersectDate.md)
  : Date of cohorts that are present in a certain window
- [`addCohortIntersectDays()`](https://darwin-eu.github.io/PatientProfiles/reference/addCohortIntersectDays.md)
  : It creates columns to indicate the number of days between the
  current table and a target cohort
- [`addCohortIntersectField()`](https://darwin-eu.github.io/PatientProfiles/reference/addCohortIntersectField.md)
  : It creates a column with the field of a desired intersection
- [`addCohortIntersectFlag()`](https://darwin-eu.github.io/PatientProfiles/reference/addCohortIntersectFlag.md)
  : It creates columns to indicate the presence of cohorts

### Add a value from a concept intersection

Add a variable indicating the intersection between a table in the OMOP
Common Data Model and a concept.

- [`addConceptIntersectCount()`](https://darwin-eu.github.io/PatientProfiles/reference/addConceptIntersectCount.md)
  : It creates column to indicate the count overlap information between
  a table and a concept
- [`addConceptIntersectDate()`](https://darwin-eu.github.io/PatientProfiles/reference/addConceptIntersectDate.md)
  : It creates column to indicate the date overlap information between a
  table and a concept
- [`addConceptIntersectDays()`](https://darwin-eu.github.io/PatientProfiles/reference/addConceptIntersectDays.md)
  : It creates column to indicate the days of difference from an index
  date to a concept
- [`addConceptIntersectField()`](https://darwin-eu.github.io/PatientProfiles/reference/addConceptIntersectField.md)
  : It adds a custom column (field) from the intersection with a certain
  table subsetted by concept id. In general it is used to add the first
  value of a certain measurement.
- [`addConceptIntersectFlag()`](https://darwin-eu.github.io/PatientProfiles/reference/addConceptIntersectFlag.md)
  : It creates column to indicate the flag overlap information between a
  table and a concept

### Add a value from an omop standard table intersection

Add a variable indicating the intersection between a table in the OMOP
Common Data Model and a standard omop table.

- [`addTableIntersectCount()`](https://darwin-eu.github.io/PatientProfiles/reference/addTableIntersectCount.md)
  : Compute number of intersect with an omop table.
- [`addTableIntersectDate()`](https://darwin-eu.github.io/PatientProfiles/reference/addTableIntersectDate.md)
  : Compute date of intersect with an omop table.
- [`addTableIntersectDays()`](https://darwin-eu.github.io/PatientProfiles/reference/addTableIntersectDays.md)
  : Compute time to intersect with an omop table.
- [`addTableIntersectField()`](https://darwin-eu.github.io/PatientProfiles/reference/addTableIntersectField.md)
  : Intersecting the cohort with columns of an OMOP table of user's
  choice. It will add an extra column to the cohort, indicating the
  intersected entries with the target columns in a window of the user's
  choice.
- [`addTableIntersectFlag()`](https://darwin-eu.github.io/PatientProfiles/reference/addTableIntersectFlag.md)
  : Compute a flag intersect with an omop table.

### Query functions

These functions add the same information than their analogous add\*
function but, the result is not computed into a table.

- [`addAgeQuery()`](https://darwin-eu.github.io/PatientProfiles/reference/addAgeQuery.md)
  : Query to add the age of the individuals at a certain date
- [`addBirthdayQuery()`](https://darwin-eu.github.io/PatientProfiles/reference/addBirthdayQuery.md)
  **\[experimental\]** : Add the birth day of an individual to a table
- [`addDateOfBirthQuery()`](https://darwin-eu.github.io/PatientProfiles/reference/addDateOfBirthQuery.md)
  : Query to add a column with the individual birth date
- [`addDemographicsQuery()`](https://darwin-eu.github.io/PatientProfiles/reference/addDemographicsQuery.md)
  : Query to add demographic characteristics at a certain date
- [`addFutureObservationQuery()`](https://darwin-eu.github.io/PatientProfiles/reference/addFutureObservationQuery.md)
  : Query to add the number of days till the end of the observation
  period at a certain date
- [`addInObservationQuery()`](https://darwin-eu.github.io/PatientProfiles/reference/addInObservationQuery.md)
  : Query to add a new column to indicate if a certain record is within
  the observation period
- [`addObservationPeriodIdQuery()`](https://darwin-eu.github.io/PatientProfiles/reference/addObservationPeriodIdQuery.md)
  : Add the ordinal number of the observation period associated that a
  given date is in. Result is not computed, only query is added.
- [`addPriorObservationQuery()`](https://darwin-eu.github.io/PatientProfiles/reference/addPriorObservationQuery.md)
  : Query to add the number of days of prior observation in the current
  observation period at a certain date
- [`addSexQuery()`](https://darwin-eu.github.io/PatientProfiles/reference/addSexQuery.md)
  : Query to add the sex of the individuals

### Summarise patient characteristics

Function that allow the user to summarise patient characteristics
(characteristics must be added priot the use of the function)

- [`summariseResult()`](https://darwin-eu.github.io/PatientProfiles/reference/summariseResult.md)
  : Summarise variables using a set of estimate functions. The output
  will be a formatted summarised_result object.

### Suppress counts of a summarised_result object

Function that allow the user to suppress counts and estimates for a
certain minCellCount

- [`reexports`](https://darwin-eu.github.io/PatientProfiles/reference/reexports.md)
  [`suppress`](https://darwin-eu.github.io/PatientProfiles/reference/reexports.md)
  [`settings`](https://darwin-eu.github.io/PatientProfiles/reference/reexports.md)
  : Objects exported from other packages

### Create a mock database with OMOP CDM format data

Function that allow the user to create new OMOP CDM mock data

- [`mockDisconnect()`](https://darwin-eu.github.io/PatientProfiles/reference/mockDisconnect.md)
  : Deprecated
- [`mockPatientProfiles()`](https://darwin-eu.github.io/PatientProfiles/reference/mockPatientProfiles.md)
  : It creates a mock database for testing PatientProfiles package

### Other functions

Helper functions

- [`benchmarkPatientProfiles()`](https://darwin-eu.github.io/PatientProfiles/reference/benchmarkPatientProfiles.md)
  : Benchmark intersections and demographics functions for a certain
  source (cdm).

- [`addCohortName()`](https://darwin-eu.github.io/PatientProfiles/reference/addCohortName.md)
  : Add cohort name for each cohort_definition_id

- [`addConceptName()`](https://darwin-eu.github.io/PatientProfiles/reference/addConceptName.md)
  : Add concept name for each concept_id

- [`addCdmName()`](https://darwin-eu.github.io/PatientProfiles/reference/addCdmName.md)
  : Add cdm name

- [`addCategories()`](https://darwin-eu.github.io/PatientProfiles/reference/addCategories.md)
  : Categorize a numeric variable

- [`addObservationPeriodId()`](https://darwin-eu.github.io/PatientProfiles/reference/addObservationPeriodId.md)
  : Add the ordinal number of the observation period associated that a
  given date is in.

- [`filterCohortId()`](https://darwin-eu.github.io/PatientProfiles/reference/filterCohortId.md)
  : Filter a cohort according to cohort_definition_id column, the result
  is not computed into a table. only a query is added. Used usually as
  internal functions of other packages.

- [`filterInObservation()`](https://darwin-eu.github.io/PatientProfiles/reference/filterInObservation.md)
  :

  Filter the rows of a `cdm_table` to the ones in observation that
  `indexDate` is in observation.

- [`variableTypes()`](https://darwin-eu.github.io/PatientProfiles/reference/variableTypes.md)
  : Classify the variables between 5 types: "numeric", "categorical",
  "logical", "date", "integer", or NA.

- [`availableEstimates()`](https://darwin-eu.github.io/PatientProfiles/reference/availableEstimates.md)
  : Show the available estimates that can be used for the different
  variable_type supported.

- [`startDateColumn()`](https://darwin-eu.github.io/PatientProfiles/reference/startDateColumn.md)
  : Get the name of the start date column for a certain table in the cdm

- [`endDateColumn()`](https://darwin-eu.github.io/PatientProfiles/reference/endDateColumn.md)
  : Get the name of the end date column for a certain table in the cdm

- [`sourceConceptIdColumn()`](https://darwin-eu.github.io/PatientProfiles/reference/sourceConceptIdColumn.md)
  : Get the name of the source concept_id column for a certain table in
  the cdm

- [`standardConceptIdColumn()`](https://darwin-eu.github.io/PatientProfiles/reference/standardConceptIdColumn.md)
  : Get the name of the standard concept_id column for a certain table
  in the cdm
