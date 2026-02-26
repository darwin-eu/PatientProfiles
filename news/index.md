# Changelog

## PatientProfiles 1.5.0

CRAN release: 2026-02-24

- Fix tests for dplyr 1.2.0 by
  [@catalamarti](https://github.com/catalamarti) in
  [\#842](https://github.com/darwin-eu/PatientProfiles/issues/842)
- add ageUnit to age functions by
  [@catalamarti](https://github.com/catalamarti) in
  [\#840](https://github.com/darwin-eu/PatientProfiles/issues/840)
- addCohortIntersectField by
  [@catalamarti](https://github.com/catalamarti) in
  [\#843](https://github.com/darwin-eu/PatientProfiles/issues/843)
- addBirthDay function by [@catalamarti](https://github.com/catalamarti)
  in [\#841](https://github.com/darwin-eu/PatientProfiles/issues/841)

## PatientProfiles 1.4.5

CRAN release: 2026-01-21

- Add new estimates count_0, count_negative, count_positive,
  count_not_positive, count_not_negative + percentages by
  [@catalamarti](https://github.com/catalamarti) in
  [\#825](https://github.com/darwin-eu/PatientProfiles/issues/825)
- Restrict count and percentage to binary variables by
  [@catalamarti](https://github.com/catalamarti) in
  [\#836](https://github.com/darwin-eu/PatientProfiles/issues/836)
- Limit x values of density estimation to .005 and .995 percentiles of
  the distribution by [@ablack3](https://github.com/ablack3) in
  [\#820](https://github.com/darwin-eu/PatientProfiles/issues/820)
- Improve summariseResult examples by
  [@catalamarti](https://github.com/catalamarti) in
  [\#827](https://github.com/darwin-eu/PatientProfiles/issues/827)
- Add message when no result is provided in summariseResult by
  [@catalamarti](https://github.com/catalamarti) in
  [\#826](https://github.com/darwin-eu/PatientProfiles/issues/826)
- Add new estimates count_person and count_subject by
  [@catalamarti](https://github.com/catalamarti) in
  [\#828](https://github.com/darwin-eu/PatientProfiles/issues/828)
- Fix warning when table is no cdm_table in summariseResult by
  [@catalamarti](https://github.com/catalamarti) in
  [\#835](https://github.com/darwin-eu/PatientProfiles/issues/835)
- Standard deviation is corrected to numeric for all variables by
  [@catalamarti](https://github.com/catalamarti) in
  [\#834](https://github.com/darwin-eu/PatientProfiles/issues/834)

## PatientProfiles 1.4.4

CRAN release: 2025-10-29

- fix edge case for not present domains by
  [@catalamarti](https://github.com/catalamarti) in
  [\#815](https://github.com/darwin-eu/PatientProfiles/issues/815)
- additional compute in intersect by
  [@edward-burn](https://github.com/edward-burn) in
  [\#817](https://github.com/darwin-eu/PatientProfiles/issues/817)

## PatientProfiles 1.4.3

CRAN release: 2025-10-01

- validate concept set names to be appropiate by
  [@catalamarti](https://github.com/catalamarti) in
  [\#806](https://github.com/darwin-eu/PatientProfiles/issues/806)
- explicit message for order by
  [@catalamarti](https://github.com/catalamarti) in
  [\#807](https://github.com/darwin-eu/PatientProfiles/issues/807)
- allowDuplicated documentation by
  [@catalamarti](https://github.com/catalamarti) in
  [\#805](https://github.com/darwin-eu/PatientProfiles/issues/805)
- Support local datasets by
  [@catalamarti](https://github.com/catalamarti) in
  [\#810](https://github.com/darwin-eu/PatientProfiles/issues/810)
- Deprecate mockDisconnect by
  [@catalamarti](https://github.com/catalamarti) in
  [\#811](https://github.com/darwin-eu/PatientProfiles/issues/811)

## PatientProfiles 1.4.2

CRAN release: 2025-07-09

- Allow NA values with density estimate by
  [@catalamarti](https://github.com/catalamarti) in
  [\#795](https://github.com/darwin-eu/PatientProfiles/issues/795)

## PatientProfiles 1.4.1

CRAN release: 2025-06-27

- Fix pass type in expression by
  [@edward-burn](https://github.com/edward-burn) in
  [\#794](https://github.com/darwin-eu/PatientProfiles/issues/794)

## PatientProfiles 1.4.0

CRAN release: 2025-05-30

- Fix readme lifecycle badge by
  [@catalamarti](https://github.com/catalamarti) in
  [\#778](https://github.com/darwin-eu/PatientProfiles/issues/778)
- create new function `addConceptName` by
  [@catalamarti](https://github.com/catalamarti) in
  [\#783](https://github.com/darwin-eu/PatientProfiles/issues/783)
- Support visit domain and drop non supported concepts in
  `addConceptIntersect` by
  [@catalamarti](https://github.com/catalamarti) in
  [\#784](https://github.com/darwin-eu/PatientProfiles/issues/784)
- Collect in SummariseResult if median is asked in a sql server by
  [@catalamarti](https://github.com/catalamarti) in
  [\#789](https://github.com/darwin-eu/PatientProfiles/issues/789)
- arrange strata in summariseResult by
  [@catalamarti](https://github.com/catalamarti) in
  [\#790](https://github.com/darwin-eu/PatientProfiles/issues/790)
- Improve performance of .addIntersect by
  [@catalamarti](https://github.com/catalamarti) in
  [\#788](https://github.com/darwin-eu/PatientProfiles/issues/788)

## PatientProfiles 1.3.1

CRAN release: 2025-03-05

- Validate cohort using class by
  [@catalamarti](https://github.com/catalamarti) in
  [\#773](https://github.com/darwin-eu/PatientProfiles/issues/773)
- Use case_when in addCategories by
  [@catalamarti](https://github.com/catalamarti) in
  [\#774](https://github.com/darwin-eu/PatientProfiles/issues/774)
- Fix binary counts in db by
  [@catalamarti](https://github.com/catalamarti) in
  [\#775](https://github.com/darwin-eu/PatientProfiles/issues/775)

## PatientProfiles 1.3.0

CRAN release: 2025-02-26

- Changed addCategories by
  [@KimLopezGuell](https://github.com/KimLopezGuell) in
  [\#734](https://github.com/darwin-eu/PatientProfiles/issues/734)
- conceptSet allows conceptSetExpression by
  [@catalamarti](https://github.com/catalamarti) in
  [\#743](https://github.com/darwin-eu/PatientProfiles/issues/743)
- account for integer64 counts by
  [@catalamarti](https://github.com/catalamarti) in
  [\#745](https://github.com/darwin-eu/PatientProfiles/issues/745)
- add inObservation argument in addTable… by
  [@catalamarti](https://github.com/catalamarti) in
  [\#749](https://github.com/darwin-eu/PatientProfiles/issues/749)
- addConceptIntersectField by
  [@catalamarti](https://github.com/catalamarti) in
  [\#747](https://github.com/darwin-eu/PatientProfiles/issues/747)
- validate targetCohortId with og by
  [@catalamarti](https://github.com/catalamarti) in
  [\#750](https://github.com/darwin-eu/PatientProfiles/issues/750)
- create filterInObservation by
  [@catalamarti](https://github.com/catalamarti) in
  [\#744](https://github.com/darwin-eu/PatientProfiles/issues/744)
- create filterCohortId by
  [@catalamarti](https://github.com/catalamarti) in
  [\#748](https://github.com/darwin-eu/PatientProfiles/issues/748)
- add benchmarkPatientProfiles by
  [@catalamarti](https://github.com/catalamarti) in
  [\#752](https://github.com/darwin-eu/PatientProfiles/issues/752)
- Update addIntersect.R by
  [@catalamarti](https://github.com/catalamarti) in
  [\#758](https://github.com/darwin-eu/PatientProfiles/issues/758)
- Reduce addDemographics computing time by
  [@catalamarti](https://github.com/catalamarti) in
  [\#759](https://github.com/darwin-eu/PatientProfiles/issues/759)
- Reduce addIntersect computing time by
  [@catalamarti](https://github.com/catalamarti) in
  [\#761](https://github.com/darwin-eu/PatientProfiles/issues/761)
  [\#762](https://github.com/darwin-eu/PatientProfiles/issues/762)
  [\#764](https://github.com/darwin-eu/PatientProfiles/issues/764)
  [\#763](https://github.com/darwin-eu/PatientProfiles/issues/763)
- preserve field type and add allowDuplicates arg by
  [@catalamarti](https://github.com/catalamarti) in
  [\#765](https://github.com/darwin-eu/PatientProfiles/issues/765)
- Add `weights` argument to `summariseResult` by
  [@nmercadeb](https://github.com/nmercadeb) in
  [\#733](https://github.com/darwin-eu/PatientProfiles/issues/733)
- Increase test coverage by
  [@catalamarti](https://github.com/catalamarti) in
  [\#768](https://github.com/darwin-eu/PatientProfiles/issues/768)

## PatientProfiles 1.2.3

CRAN release: 2024-12-12

- Bug fix to correct NA columns when not in observation by
  [@catalamarti](https://github.com/catalamarti)

## PatientProfiles 1.2.2

CRAN release: 2024-11-28

- Update links and codecoverage by
  [@catalamarti](https://github.com/catalamarti)
- Distinct individuals in addObservationPeriodId() by
  [@martaalcalde](https://github.com/martaalcalde)
- Remove dependencies on visOmopResults and magrittr
  [@catalamarti](https://github.com/catalamarti)

## PatientProfiles 1.2.1

CRAN release: 2024-10-25

- edge case where no concept in concept table by
  [@edward-burn](https://github.com/edward-burn)
- update assertions in addDeath functions by
  [@catalamarti](https://github.com/catalamarti)
- increase test coverage by
  [@catalamarti](https://github.com/catalamarti)
- add internal compute to addInObservation by
  [@edward-burn](https://github.com/edward-burn)
- conceptIntersect inObservation argument by
  [@edward-burn](https://github.com/edward-burn)

## PatientProfiles 1.2.0

CRAN release: 2024-09-11

- [`addObservationPeriodId()`](https://darwin-eu.github.io/PatientProfiles/reference/addObservationPeriodId.md)
  is a new function that adds the number of observation period that an
  observation is in.

- Add `density` estimate to
  [`summariseResult()`](https://darwin-eu.github.io/PatientProfiles/reference/summariseResult.md)

## PatientProfiles 1.1.1

CRAN release: 2024-07-28

- `addCohortName` overwrites if there already exists a `cohort_name`
  column
  [\#680](https://github.com/darwin-eu/PatientProfiles/issues/680) and
  [\#682](https://github.com/darwin-eu/PatientProfiles/issues/682).

- Correct nan and Inf for missing values
  [\#674](https://github.com/darwin-eu/PatientProfiles/issues/674)

- Fix [\#670](https://github.com/darwin-eu/PatientProfiles/issues/670)
  [\#671](https://github.com/darwin-eu/PatientProfiles/issues/671)

## PatientProfiles 1.1.0

CRAN release: 2024-06-11

- addConceptIntersect now includes records with missing end date under
  the assumption that end date is equal to start date.

- add\* functions have a new argument called `name` to decide if we want
  a resultant temp table (`name = NULL`) or have a permanent table with
  a certain name. Additional functions are provided,
  e.g. addDemographicsQuery, where the result is not computed.

## PatientProfiles 1.0.0

CRAN release: 2024-05-16

- Stable release of package
