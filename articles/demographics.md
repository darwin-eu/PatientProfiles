# Adding patient demographics

## Introduction

The OMOP CDM is a person-centric model. The person table contains
records that uniquely identify each individual along with some of their
demographic information. Below we create a mock CDM reference which, as
is standard, has a person table which contains fields which indicate an
individual’s date of birth, gender, race, and ethnicity. Each of these,
except for date of birth, are represented by a concept ID (and as the
person table contains one record per person these fields are treated as
time-invariant).

``` r
library(PatientProfiles)
library(duckdb)
library(dplyr)

cdm <- mockPatientProfiles(numberIndividuals = 10000, source = "duckdb")

cdm$person |>
  dplyr::glimpse()
```

    ## Rows: ??
    ## Columns: 5
    ## Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
    ## $ person_id            <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15…
    ## $ gender_concept_id    <int> 8532, 8532, 8507, 8532, 8532, 8507, 8532, 8532, 8…
    ## $ year_of_birth        <int> 1940, 1952, 1958, 1906, 1950, 1917, 1967, 1972, 1…
    ## $ race_concept_id      <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
    ## $ ethnicity_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…

As well as the person table, every CDM reference will include an
observation period table. This table contains spans of times during
which an individual is considered to being under observation.
Individuals can have multiple observation periods, but they cannot
overlap.

``` r
cdm$observation_period |>
  dplyr::glimpse()
```

    ## Rows: ??
    ## Columns: 5
    ## Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
    ## $ person_id                     <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1…
    ## $ observation_period_start_date <date> 1940-01-01, 1952-01-01, 1958-01-01, 190…
    ## $ observation_period_end_date   <date> 1969-04-09, 1977-04-26, 2000-12-04, 193…
    ## $ period_type_concept_id        <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
    ## $ observation_period_id         <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1…

When performing analyses we will often be interested in working with the
person and observation period tables to identify individuals’
characteristics on some date of interest. PatientProfiles provides a
number of functions that can help us do this.

## Adding characteristics to OMOP CDM tables

Let’s say we’re working with the condition occurrence table.

``` r
cdm$condition_occurrence |>
  glimpse()
```

    ## Rows: ??
    ## Columns: 6
    ## Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
    ## $ person_id                 <int> 2284, 3335, 9438, 6762, 9433, 9393, 6360, 36…
    ## $ condition_start_date      <date> 1918-10-05, 1934-12-06, 1945-12-27, 1944-09…
    ## $ condition_end_date        <date> 1925-01-30, 1954-09-30, 1947-08-23, 1947-08…
    ## $ condition_occurrence_id   <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1…
    ## $ condition_concept_id      <int> 1, 2, 2, 7, 6, 9, 8, 3, 10, 5, 3, 2, 5, 5, 3…
    ## $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…

This table contains diagnoses of individuals and we might, for example,
want to identify their age on their date of diagnosis. This involves
linking back to the person table which contains their date of birth
(split across three different columns). PatientProfiles provides a
simple function for this.
[`addAge()`](https://darwin-eu.github.io/PatientProfiles/reference/addAge.md)
will add a new column to the table containing each patient’s age
relative to the specified index date.

``` r
cdm$condition_occurrence <- cdm$condition_occurrence |>
  addAge(indexDate = "condition_start_date")

cdm$condition_occurrence |>
  glimpse()
```

    ## Rows: ??
    ## Columns: 7
    ## Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
    ## $ person_id                 <int> 74, 266, 318, 410, 427, 434, 450, 457, 468, …
    ## $ condition_start_date      <date> 1969-08-01, 1936-01-11, 1952-08-18, 1957-01…
    ## $ condition_end_date        <date> 1978-06-27, 1959-01-10, 1967-10-03, 1957-09…
    ## $ condition_occurrence_id   <int> 21, 81, 88, 105, 109, 117, 32, 41, 36, 82, 7…
    ## $ condition_concept_id      <int> 2, 1, 1, 8, 10, 3, 3, 9, 1, 1, 5, 2, 6, 3, 7…
    ## $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ age                       <int> 1, 9, 21, 23, 29, 26, 7, 15, 8, 6, 14, 26, 2…

As well as calculating age, we can also create age groups at the same
time. Here we create three age groups: those aged 0 to 17, those 18 to
65, and those 66 or older.

``` r
cdm$condition_occurrence <- cdm$condition_occurrence |>
  addAge(
    indexDate = "condition_start_date",
    ageGroup = list(
      "0 to 17" = c(0, 17),
      "18 to 65" = c(18, 65),
      ">= 66" = c(66, Inf)
    )
  )

cdm$condition_occurrence |>
  glimpse()
```

    ## Rows: ??
    ## Columns: 8
    ## Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
    ## $ person_id                 <int> 74, 266, 318, 410, 427, 434, 450, 457, 468, …
    ## $ condition_start_date      <date> 1969-08-01, 1936-01-11, 1952-08-18, 1957-01…
    ## $ condition_end_date        <date> 1978-06-27, 1959-01-10, 1967-10-03, 1957-09…
    ## $ condition_occurrence_id   <int> 21, 81, 88, 105, 109, 117, 32, 41, 36, 82, 7…
    ## $ condition_concept_id      <int> 2, 1, 1, 8, 10, 3, 3, 9, 1, 1, 5, 2, 6, 3, 7…
    ## $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ age                       <int> 1, 9, 21, 23, 29, 26, 7, 15, 8, 6, 14, 26, 2…
    ## $ age_group                 <chr> "0 to 17", "0 to 17", "18 to 65", "18 to 65"…

By default, when adding age the new column will have been called “age”
and will have been calculated using all available information on date of
birth contained in the person. We can though also alter these defaults.
Here, for example, we impose that month of birth is January and day of
birth is the 1st for all individuals.

``` r
cdm$condition_occurrence <- cdm$condition_occurrence |>
  addAge(
    indexDate = "condition_start_date",
    ageName = "age_from_year_of_birth",
    ageMissingMonth = 1,
    ageMissingDay = 1,
    ageImposeMonth = TRUE,
    ageImposeDay = TRUE
  )

cdm$condition_occurrence |>
  glimpse()
```

    ## Rows: ??
    ## Columns: 9
    ## Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
    ## $ person_id                 <int> 74, 266, 318, 410, 427, 434, 450, 457, 468, …
    ## $ condition_start_date      <date> 1969-08-01, 1936-01-11, 1952-08-18, 1957-01…
    ## $ condition_end_date        <date> 1978-06-27, 1959-01-10, 1967-10-03, 1957-09…
    ## $ condition_occurrence_id   <int> 21, 81, 88, 105, 109, 117, 32, 41, 36, 82, 7…
    ## $ condition_concept_id      <int> 2, 1, 1, 8, 10, 3, 3, 9, 1, 1, 5, 2, 6, 3, 7…
    ## $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ age                       <int> 1, 9, 21, 23, 29, 26, 7, 15, 8, 6, 14, 26, 2…
    ## $ age_group                 <chr> "0 to 17", "0 to 17", "18 to 65", "18 to 65"…
    ## $ age_from_year_of_birth    <int> 1, 9, 21, 23, 29, 26, 7, 15, 8, 6, 14, 26, 2…

As well as age at diagnosis, we might also want identify patients’ sex.
PatientProfiles provides the
[`addSex()`](https://darwin-eu.github.io/PatientProfiles/reference/addSex.md)
function that will add this for us. Because this is treated as
time-invariant, we will not have to specify any index variable.

``` r
cdm$condition_occurrence <- cdm$condition_occurrence |>
  addSex()

cdm$condition_occurrence |>
  glimpse()
```

    ## Rows: ??
    ## Columns: 10
    ## Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
    ## $ person_id                 <int> 74, 266, 318, 410, 427, 434, 450, 457, 468, …
    ## $ condition_start_date      <date> 1969-08-01, 1936-01-11, 1952-08-18, 1957-01…
    ## $ condition_end_date        <date> 1978-06-27, 1959-01-10, 1967-10-03, 1957-09…
    ## $ condition_occurrence_id   <int> 21, 81, 88, 105, 109, 117, 32, 41, 36, 82, 7…
    ## $ condition_concept_id      <int> 2, 1, 1, 8, 10, 3, 3, 9, 1, 1, 5, 2, 6, 3, 7…
    ## $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ age                       <int> 1, 9, 21, 23, 29, 26, 7, 15, 8, 6, 14, 26, 2…
    ## $ age_group                 <chr> "0 to 17", "0 to 17", "18 to 65", "18 to 65"…
    ## $ age_from_year_of_birth    <int> 1, 9, 21, 23, 29, 26, 7, 15, 8, 6, 14, 26, 2…
    ## $ sex                       <chr> "Female", "Male", "Female", "Female", "Male"…

Similarly, we could also identify whether an individual was in
observation at the time of their diagnosis (i.e. had an observation
period that overlaps with their diagnosis date), as well as identifying
how much prior observation time they had on this date and how much they
have following it.

``` r
cdm$condition_occurrence <- cdm$condition_occurrence |>
  addInObservation(indexDate = "condition_start_date") |>
  addPriorObservation(indexDate = "condition_start_date") |>
  addFutureObservation(indexDate = "condition_start_date")

cdm$condition_occurrence |>
  glimpse()
```

    ## Rows: ??
    ## Columns: 13
    ## Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
    ## $ person_id                 <int> 74, 266, 318, 410, 427, 434, 450, 457, 468, …
    ## $ condition_start_date      <date> 1969-08-01, 1936-01-11, 1952-08-18, 1957-01…
    ## $ condition_end_date        <date> 1978-06-27, 1959-01-10, 1967-10-03, 1957-09…
    ## $ condition_occurrence_id   <int> 21, 81, 88, 105, 109, 117, 32, 41, 36, 82, 7…
    ## $ condition_concept_id      <int> 2, 1, 1, 8, 10, 3, 3, 9, 1, 1, 5, 2, 6, 3, 7…
    ## $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ age                       <int> 1, 9, 21, 23, 29, 26, 7, 15, 8, 6, 14, 26, 2…
    ## $ age_group                 <chr> "0 to 17", "0 to 17", "18 to 65", "18 to 65"…
    ## $ age_from_year_of_birth    <int> 1, 9, 21, 23, 29, 26, 7, 15, 8, 6, 14, 26, 2…
    ## $ sex                       <chr> "Female", "Male", "Female", "Female", "Male"…
    ## $ in_observation            <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
    ## $ prior_observation         <int> 578, 3297, 7900, 8409, 10879, 9565, 2697, 57…
    ## $ future_observation        <int> 14672, 10185, 12460, 1601, 2901, 4798, 9016,…

For these functions which work with information from the observation
table, it is important to note that the results will be based on the
observation period during which the index date falls within. Moreover,
if a patient is not under observation at the specified date,
[`addPriorObservation()`](https://darwin-eu.github.io/PatientProfiles/reference/addPriorObservation.md)
and
[`addFutureObservation()`](https://darwin-eu.github.io/PatientProfiles/reference/addFutureObservation.md)
functions will return NA.

When checking whether someone is in observation the default is that we
are checking whether someone was in observation on the index date. We
could though expand this and consider a window of time around this date.
For example here we add a variable indicating whether someone was in
observation from 180 days before the index date to 30 days following it.

``` r
cdm$condition_occurrence |>
  addInObservation(
    indexDate = "condition_start_date",
    window = c(-180, 30)
  ) |>
  glimpse()
```

    ## Rows: ??
    ## Columns: 13
    ## Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
    ## $ person_id                 <int> 74, 266, 318, 410, 427, 434, 450, 457, 468, …
    ## $ condition_start_date      <date> 1969-08-01, 1936-01-11, 1952-08-18, 1957-01…
    ## $ condition_end_date        <date> 1978-06-27, 1959-01-10, 1967-10-03, 1957-09…
    ## $ condition_occurrence_id   <int> 21, 81, 88, 105, 109, 117, 32, 41, 36, 82, 7…
    ## $ condition_concept_id      <int> 2, 1, 1, 8, 10, 3, 3, 9, 1, 1, 5, 2, 6, 3, 7…
    ## $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ age                       <int> 1, 9, 21, 23, 29, 26, 7, 15, 8, 6, 14, 26, 2…
    ## $ age_group                 <chr> "0 to 17", "0 to 17", "18 to 65", "18 to 65"…
    ## $ age_from_year_of_birth    <int> 1, 9, 21, 23, 29, 26, 7, 15, 8, 6, 14, 26, 2…
    ## $ sex                       <chr> "Female", "Male", "Female", "Female", "Male"…
    ## $ prior_observation         <int> 578, 3297, 7900, 8409, 10879, 9565, 2697, 57…
    ## $ future_observation        <int> 14672, 10185, 12460, 1601, 2901, 4798, 9016,…
    ## $ in_observation            <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…

We can also specify a window and require that an individual is present
for only some days within it. Here we add a variable indicating whether
the individual was in observation at least a year in the future,

``` r
cdm$condition_occurrence |>
  addInObservation(
    indexDate = "condition_start_date",
    window = c(365, Inf),
    completeInterval = FALSE
  ) |>
  glimpse()
```

    ## Rows: ??
    ## Columns: 13
    ## Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
    ## $ person_id                 <int> 74, 266, 318, 410, 427, 434, 450, 457, 468, …
    ## $ condition_start_date      <date> 1969-08-01, 1936-01-11, 1952-08-18, 1957-01…
    ## $ condition_end_date        <date> 1978-06-27, 1959-01-10, 1967-10-03, 1957-09…
    ## $ condition_occurrence_id   <int> 21, 81, 88, 105, 109, 117, 32, 41, 36, 82, 7…
    ## $ condition_concept_id      <int> 2, 1, 1, 8, 10, 3, 3, 9, 1, 1, 5, 2, 6, 3, 7…
    ## $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ age                       <int> 1, 9, 21, 23, 29, 26, 7, 15, 8, 6, 14, 26, 2…
    ## $ age_group                 <chr> "0 to 17", "0 to 17", "18 to 65", "18 to 65"…
    ## $ age_from_year_of_birth    <int> 1, 9, 21, 23, 29, 26, 7, 15, 8, 6, 14, 26, 2…
    ## $ sex                       <chr> "Female", "Male", "Female", "Female", "Male"…
    ## $ prior_observation         <int> 578, 3297, 7900, 8409, 10879, 9565, 2697, 57…
    ## $ future_observation        <int> 14672, 10185, 12460, 1601, 2901, 4798, 9016,…
    ## $ in_observation            <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…

## Adding characteristics to a cohort tables

The above functions can be used on both standard OMOP CDM tables and
cohort tables. Note as the default index date in the functions is
“cohort_start_date” we can now omit this.

``` r
cdm$cohort1 |>
  glimpse()
```

    ## Rows: ??
    ## Columns: 4
    ## Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
    ## $ cohort_definition_id <int> 1, 1, 1, 1, 2, 1, 3, 2, 2, 2, 1, 3, 3, 1, 3, 2, 3…
    ## $ subject_id           <int> 5853, 1622, 8574, 6414, 7299, 4793, 6541, 1029, 5…
    ## $ cohort_start_date    <date> 1964-06-05, 1927-03-08, 1955-08-04, 1963-06-12, …
    ## $ cohort_end_date      <date> 1964-12-11, 1934-04-21, 1958-05-01, 1983-11-26, …

``` r
cdm$cohort1 <- cdm$cohort1 |>
  addAge(ageGroup = list(
    "0 to 17" = c(0, 17),
    "18 to 65" = c(18, 65),
    ">= 66" = c(66, Inf)
  )) |>
  addSex() |>
  addInObservation() |>
  addPriorObservation() |>
  addFutureObservation()

cdm$cohort1 |>
  glimpse()
```

    ## Rows: ??
    ## Columns: 10
    ## Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
    ## $ cohort_definition_id <int> 1, 1, 1, 1, 2, 1, 3, 2, 2, 2, 1, 3, 3, 1, 3, 2, 3…
    ## $ subject_id           <int> 5853, 1622, 8574, 6414, 7299, 4793, 6541, 1029, 5…
    ## $ cohort_start_date    <date> 1964-06-05, 1927-03-08, 1955-08-04, 1963-06-12, …
    ## $ cohort_end_date      <date> 1964-12-11, 1934-04-21, 1958-05-01, 1983-11-26, …
    ## $ age                  <int> 37, 1, 20, 26, 5, 17, 21, 19, 8, 31, 5, 25, 14, 3…
    ## $ age_group            <chr> "18 to 65", "0 to 17", "18 to 65", "18 to 65", "0…
    ## $ sex                  <chr> "Male", "Female", "Male", "Female", "Male", "Fema…
    ## $ in_observation       <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
    ## $ prior_observation    <int> 13670, 431, 7520, 9658, 2104, 6497, 7790, 7273, 2…
    ## $ future_observation   <int> 2816, 7157, 3670, 7600, 9355, 1273, 6135, 8189, 4…

## Getting multiple characteristics at once

The above functions, which are chained together, each fetch the related
information one by one. In the cases where we are interested in adding
multiple characteristics, we can add these all at the same time using
the more general
[`addDemographics()`](https://darwin-eu.github.io/PatientProfiles/reference/addDemographics.md)
functions. This will be more efficient that adding characteristics as it
requires fewer joins between our table of interest and the person and
observation period tables.

``` r
cdm$cohort2 |>
  glimpse()
```

    ## Rows: ??
    ## Columns: 4
    ## Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
    ## $ cohort_definition_id <int> 3, 3, 1, 3, 1, 1, 2, 3, 3, 1, 2, 1, 2, 2, 1, 1, 3…
    ## $ subject_id           <int> 6688, 3035, 5292, 1351, 8144, 699, 8733, 1007, 68…
    ## $ cohort_start_date    <date> 1999-06-28, 1977-03-24, 1931-10-19, 1993-07-08, …
    ## $ cohort_end_date      <date> 2019-08-31, 1988-06-17, 1937-06-27, 2003-11-19, …

``` r
tictoc::tic()
cdm$cohort2 |>
  addAge(ageGroup = list(
    "0 to 17" = c(0, 17),
    "18 to 65" = c(18, 65),
    ">= 66" = c(66, Inf)
  )) |>
  addSex() |>
  addInObservation() |>
  addPriorObservation() |>
  addFutureObservation()
```

    ## # Source:   table<og_030_1771938140> [?? x 10]
    ## # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
    ##    cohort_definition_id subject_id cohort_start_date cohort_end_date   age
    ##                   <int>      <int> <date>            <date>          <int>
    ##  1                    3       6688 1999-06-28        2019-08-31         27
    ##  2                    3       3035 1977-03-24        1988-06-17         12
    ##  3                    1       5292 1931-10-19        1937-06-27         22
    ##  4                    3       1351 1993-07-08        2003-11-19         20
    ##  5                    1       8144 1956-10-23        1958-02-13         33
    ##  6                    1        699 1961-10-27        1964-11-25         15
    ##  7                    2       8733 1913-07-26        1916-03-16          9
    ##  8                    3       1007 1949-06-16        1950-08-09          6
    ##  9                    3       6848 1950-08-18        1951-03-01          4
    ## 10                    1       7464 1954-05-28        1954-07-23         46
    ## # ℹ more rows
    ## # ℹ 5 more variables: age_group <chr>, sex <chr>, in_observation <int>,
    ## #   prior_observation <int>, future_observation <int>

``` r
tictoc::toc()
```

    ## 1.613 sec elapsed

``` r
tictoc::tic()
cdm$cohort2 |>
  addDemographics(
    age = TRUE,
    ageName = "age",
    ageGroup = list(
      "0 to 17" = c(0, 17),
      "18 to 65" = c(18, 65),
      ">= 66" = c(66, Inf)
    ),
    sex = TRUE,
    sexName = "sex",
    priorObservation = TRUE,
    priorObservationName = "prior_observation",
    futureObservation = FALSE,
  ) |>
  glimpse()
```

    ## Rows: ??
    ## Columns: 8
    ## Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
    ## $ cohort_definition_id <int> 2, 3, 2, 3, 3, 2, 3, 2, 3, 3, 2, 1, 2, 3, 2, 3, 2…
    ## $ subject_id           <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15…
    ## $ cohort_start_date    <date> 1940-11-29, 1963-05-30, 1993-09-04, 1923-10-12, …
    ## $ cohort_end_date      <date> 1959-10-09, 1977-03-31, 1995-07-27, 1926-04-27, …
    ## $ age                  <int> 0, 11, 35, 17, 4, 6, 22, 20, 12, 12, 14, 25, 2, 2…
    ## $ age_group            <chr> "0 to 17", "0 to 17", "18 to 65", "0 to 17", "0 t…
    ## $ sex                  <chr> "Female", "Female", "Male", "Female", "Female", "…
    ## $ prior_observation    <int> 333, 4167, 13030, 6493, 1641, 2378, 8088, 7594, 4…

``` r
tictoc::toc()
```

    ## 0.636 sec elapsed

In our small mock dataset we see a small improvement in performance, but
this difference will become much more noticeable when working with real
data that will typically be far larger.
