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
    ## $ person_id            <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15…
    ## $ gender_concept_id    <int> 8532, 8532, 8507, 8507, 8532, 8532, 8532, 8532, 8…
    ## $ year_of_birth        <int> 1917, 1967, 1972, 1973, 1923, 1940, 1963, 1915, 1…
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
    ## $ person_id                     <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1…
    ## $ observation_period_start_date <date> 1917-01-01, 1967-01-01, 1972-01-01, 197…
    ## $ observation_period_end_date   <date> 1970-02-12, 2010-10-30, 1999-05-26, 201…
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
    ## $ person_id                 <int> 3186, 8841, 7373, 6377, 3290, 2953, 3082, 81…
    ## $ condition_start_date      <date> 1936-03-31, 1927-11-20, 1934-01-15, 1931-08…
    ## $ condition_end_date        <date> 1947-11-17, 1935-07-22, 1948-06-29, 1933-06…
    ## $ condition_occurrence_id   <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1…
    ## $ condition_concept_id      <int> 375671, 40481087, 4294548, 4156265, 4048171,…
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
    ## $ person_id                 <int> 3186, 8841, 7373, 6377, 3290, 2953, 3082, 81…
    ## $ condition_start_date      <date> 1936-03-31, 1927-11-20, 1934-01-15, 1931-08…
    ## $ condition_end_date        <date> 1947-11-17, 1935-07-22, 1948-06-29, 1933-06…
    ## $ condition_occurrence_id   <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1…
    ## $ condition_concept_id      <int> 375671, 40481087, 4294548, 4156265, 4048171,…
    ## $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ age                       <dbl> 29, 13, 6, 20, 25, 0, 12, 9, 4, 11, 31, 7, 3…

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
    ## $ person_id                 <int> 3186, 8841, 7373, 6377, 3290, 2953, 3082, 81…
    ## $ condition_start_date      <date> 1936-03-31, 1927-11-20, 1934-01-15, 1931-08…
    ## $ condition_end_date        <date> 1947-11-17, 1935-07-22, 1948-06-29, 1933-06…
    ## $ condition_occurrence_id   <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1…
    ## $ condition_concept_id      <int> 375671, 40481087, 4294548, 4156265, 4048171,…
    ## $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ age                       <dbl> 29, 13, 6, 20, 25, 0, 12, 9, 4, 11, 31, 7, 3…
    ## $ age_group                 <chr> "18 to 65", "0 to 17", "0 to 17", "18 to 65"…

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
    ## $ person_id                 <int> 3186, 8841, 7373, 6377, 3290, 2953, 3082, 81…
    ## $ condition_start_date      <date> 1936-03-31, 1927-11-20, 1934-01-15, 1931-08…
    ## $ condition_end_date        <date> 1947-11-17, 1935-07-22, 1948-06-29, 1933-06…
    ## $ condition_occurrence_id   <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1…
    ## $ condition_concept_id      <int> 375671, 40481087, 4294548, 4156265, 4048171,…
    ## $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ age                       <dbl> 29, 13, 6, 20, 25, 0, 12, 9, 4, 11, 31, 7, 3…
    ## $ age_group                 <chr> "18 to 65", "0 to 17", "0 to 17", "18 to 65"…
    ## $ age_from_year_of_birth    <dbl> 29, 13, 6, 20, 25, 0, 12, 9, 4, 11, 31, 7, 3…

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
    ## $ person_id                 <int> 3186, 8841, 7373, 6377, 3290, 2953, 3082, 81…
    ## $ condition_start_date      <date> 1936-03-31, 1927-11-20, 1934-01-15, 1931-08…
    ## $ condition_end_date        <date> 1947-11-17, 1935-07-22, 1948-06-29, 1933-06…
    ## $ condition_occurrence_id   <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1…
    ## $ condition_concept_id      <int> 375671, 40481087, 4294548, 4156265, 4048171,…
    ## $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ age                       <dbl> 29, 13, 6, 20, 25, 0, 12, 9, 4, 11, 31, 7, 3…
    ## $ age_group                 <chr> "18 to 65", "0 to 17", "0 to 17", "18 to 65"…
    ## $ age_from_year_of_birth    <dbl> 29, 13, 6, 20, 25, 0, 12, 9, 4, 11, 31, 7, 3…
    ## $ sex                       <chr> "Male", "Female", "Male", "Male", "Female", …

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
    ## $ person_id                 <int> 3186, 8841, 7373, 6377, 3290, 2953, 3082, 81…
    ## $ condition_start_date      <date> 1936-03-31, 1927-11-20, 1934-01-15, 1931-08…
    ## $ condition_end_date        <date> 1947-11-17, 1935-07-22, 1948-06-29, 1933-06…
    ## $ condition_occurrence_id   <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1…
    ## $ condition_concept_id      <int> 375671, 40481087, 4294548, 4156265, 4048171,…
    ## $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ age                       <dbl> 29, 13, 6, 20, 25, 0, 12, 9, 4, 11, 31, 7, 3…
    ## $ age_group                 <chr> "18 to 65", "0 to 17", "0 to 17", "18 to 65"…
    ## $ age_from_year_of_birth    <dbl> 29, 13, 6, 20, 25, 0, 12, 9, 4, 11, 31, 7, 3…
    ## $ sex                       <chr> "Male", "Female", "Male", "Male", "Female", …
    ## $ in_observation            <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
    ## $ prior_observation         <dbl> 10682, 5071, 2206, 7527, 9300, 140, 4681, 34…
    ## $ future_observation        <dbl> 5907, 2948, 5544, 878, 626, 13317, 7394, 608…

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
    ## $ person_id                 <int> 3186, 8841, 7373, 6377, 3290, 2953, 3082, 81…
    ## $ condition_start_date      <date> 1936-03-31, 1927-11-20, 1934-01-15, 1931-08…
    ## $ condition_end_date        <date> 1947-11-17, 1935-07-22, 1948-06-29, 1933-06…
    ## $ condition_occurrence_id   <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1…
    ## $ condition_concept_id      <int> 375671, 40481087, 4294548, 4156265, 4048171,…
    ## $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ age                       <dbl> 29, 13, 6, 20, 25, 0, 12, 9, 4, 11, 31, 7, 3…
    ## $ age_group                 <chr> "18 to 65", "0 to 17", "0 to 17", "18 to 65"…
    ## $ age_from_year_of_birth    <dbl> 29, 13, 6, 20, 25, 0, 12, 9, 4, 11, 31, 7, 3…
    ## $ sex                       <chr> "Male", "Female", "Male", "Male", "Female", …
    ## $ in_observation            <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
    ## $ prior_observation         <dbl> 10682, 5071, 2206, 7527, 9300, 140, 4681, 34…
    ## $ future_observation        <dbl> 5907, 2948, 5544, 878, 626, 13317, 7394, 608…

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
    ## $ person_id                 <int> 3186, 8841, 7373, 6377, 3290, 2953, 3082, 81…
    ## $ condition_start_date      <date> 1936-03-31, 1927-11-20, 1934-01-15, 1931-08…
    ## $ condition_end_date        <date> 1947-11-17, 1935-07-22, 1948-06-29, 1933-06…
    ## $ condition_occurrence_id   <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1…
    ## $ condition_concept_id      <int> 375671, 40481087, 4294548, 4156265, 4048171,…
    ## $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ age                       <dbl> 29, 13, 6, 20, 25, 0, 12, 9, 4, 11, 31, 7, 3…
    ## $ age_group                 <chr> "18 to 65", "0 to 17", "0 to 17", "18 to 65"…
    ## $ age_from_year_of_birth    <dbl> 29, 13, 6, 20, 25, 0, 12, 9, 4, 11, 31, 7, 3…
    ## $ sex                       <chr> "Male", "Female", "Male", "Male", "Female", …
    ## $ in_observation            <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
    ## $ prior_observation         <dbl> 10682, 5071, 2206, 7527, 9300, 140, 4681, 34…
    ## $ future_observation        <dbl> 5907, 2948, 5544, 878, 626, 13317, 7394, 608…

## Adding characteristics to a cohort tables

The above functions can be used on both standard OMOP CDM tables and
cohort tables. The cohort tables used below are assumed to have been
created and validated by a dedicated OMOP cohort-generation package,
such as `CohortConstructor` or `CDMConnector`. PatientProfiles adds
characteristics to these tables but does not create or modify cohort
definitions. Note that, as the default index date in the functions is
`cohort_start_date`, we can now omit this argument.

``` r

cdm$cohort1 |>
  glimpse()
```

    ## Rows: ??
    ## Columns: 4
    ## $ cohort_definition_id <int> 3, 2, 1, 3, 2, 1, 2, 3, 1, 2, 2, 2, 2, 2, 2, 1, 1…
    ## $ subject_id           <int> 2772, 2645, 3475, 7933, 686, 3869, 5507, 8558, 46…
    ## $ cohort_start_date    <date> 2014-10-01, 1974-07-02, 1979-09-14, 1982-10-11, …
    ## $ cohort_end_date      <date> 2014-11-03, 1988-05-04, 1981-09-13, 1984-08-26, …

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
    ## $ cohort_definition_id <int> 3, 2, 1, 3, 2, 1, 2, 3, 1, 2, 2, 2, 2, 2, 2, 1, 1…
    ## $ subject_id           <int> 2772, 2645, 3475, 7933, 686, 3869, 5507, 8558, 46…
    ## $ cohort_start_date    <date> 2014-10-01, 1974-07-02, 1979-09-14, 1982-10-11, …
    ## $ cohort_end_date      <date> 2014-11-03, 1988-05-04, 1981-09-13, 1984-08-26, …
    ## $ age                  <dbl> 46, 19, 26, 9, 32, 1, 10, 16, 2, 4, 32, 18, 9, 8,…
    ## $ age_group            <chr> "18 to 65", "18 to 65", "18 to 65", "0 to 17", "1…
    ## $ sex                  <chr> "Female", "Male", "Female", "Male", "Female", "Fe…
    ## $ in_observation       <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
    ## $ prior_observation    <dbl> 17075, 7122, 9752, 3570, 11722, 608, 3855, 5891, …
    ## $ future_observation   <dbl> 2074, 6712, 1076, 3007, 1187, 10894, 1937, 8267, …

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
    ## $ cohort_definition_id <int> 2, 2, 3, 1, 2, 2, 3, 1, 3, 3, 1, 3, 3, 3, 2, 2, 2…
    ## $ subject_id           <int> 8662, 2717, 8247, 5986, 3617, 9198, 4496, 8051, 9…
    ## $ cohort_start_date    <date> 1934-11-29, 1923-03-12, 1974-05-27, 1998-10-11, …
    ## $ cohort_end_date      <date> 1947-06-07, 1930-04-27, 1978-11-17, 1999-05-06, …

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

    ## # A query:  ?? x 10
    ## # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1022-azure:R 4.6.1/:memory:]
    ##    cohort_definition_id subject_id cohort_start_date cohort_end_date   age
    ##                   <int>      <int> <date>            <date>          <dbl>
    ##  1                    2       8662 1934-11-29        1947-06-07          4
    ##  2                    2       2717 1923-03-12        1930-04-27         12
    ##  3                    3       8247 1974-05-27        1978-11-17         24
    ##  4                    1       5986 1998-10-11        1999-05-06         51
    ##  5                    2       3617 1938-08-23        1940-06-03         27
    ##  6                    2       9198 1956-10-20        1964-09-23         11
    ##  7                    3       4496 1932-03-12        1932-05-08         24
    ##  8                    1       8051 2001-05-17        2007-06-12         23
    ##  9                    3       9591 1922-09-05        1925-09-18         18
    ## 10                    3       3776 1931-11-04        1945-12-17         19
    ## # ℹ more rows
    ## # ℹ 5 more variables: age_group <chr>, sex <chr>, in_observation <dbl>,
    ## #   prior_observation <dbl>, future_observation <dbl>

``` r

tictoc::toc()
```

    ## 1.729 sec elapsed

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
    ## $ cohort_definition_id <int> 3, 2, 1, 1, 3, 1, 1, 1, 1, 3, 1, 1, 1, 3, 1, 2, 2…
    ## $ subject_id           <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15…
    ## $ cohort_start_date    <date> 1941-03-28, 2003-06-11, 1984-11-12, 1997-01-17, …
    ## $ cohort_end_date      <date> 1963-06-07, 2009-07-15, 1991-03-17, 2005-11-15, …
    ## $ age                  <dbl> 24, 36, 12, 24, 25, 33, 0, 0, 14, 40, 19, 14, 41,…
    ## $ age_group            <chr> "18 to 65", "18 to 65", "0 to 17", "18 to 65", "1…
    ## $ sex                  <chr> "Female", "Female", "Male", "Male", "Female", "Fe…
    ## $ prior_observation    <dbl> 8852, 13310, 4699, 8782, 9209, 12167, 259, 130, 5…

``` r

tictoc::toc()
```

    ## 0.627 sec elapsed

In our small mock dataset we see a small improvement in performance, but
this difference will become much more noticeable when working with real
data that will typically be far larger.
