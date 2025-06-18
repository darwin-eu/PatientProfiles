
# PatientProfiles <img src="man/figures/logo.png" align="right" height="200"/>

[![CRAN
status](https://www.r-pkg.org/badges/version/PatientProfiles)](https://CRAN.R-project.org/package=PatientProfiles)
[![R-CMD-check](https://github.com/darwin-eu/PatientProfiles/workflows/R-CMD-check/badge.svg)](https://github.com/darwin-eu/PatientProfiles/actions)
[![Lifecycle:stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![metacran
downloads](https://cranlogs.r-pkg.org/badges/PatientProfiles)](https://cran.r-project.org/package=PatientProfiles)
[![metacran
downloads](https://cranlogs.r-pkg.org/badges/grand-total/PatientProfiles)](https://cran.r-project.org/package=PatientProfiles)

## Package overview

PatientProfiles contains functions for adding characteristics to OMOP
CDM tables containing patient level data (e.g. condition occurrence,
drug exposure, and so on) and OMOP CDM cohort tables. The
characteristics that can be added include an individual´s sex, age, and
days of prior observation Time varying characteristics, such as age, can
be estimated relative to any date in the corresponding table. In
addition, PatientProfiles also provides functionality for identifying
intersections between a cohort table and OMOP CDM tables containing
patient level data or other cohort tables.

## Package installation

You can install the latest version of PatientProfiles like so:

``` r
install.packages("PatientProfiles")
```

## Citation

``` r
citation("PatientProfiles")
#> To cite package 'PatientProfiles' in publications use:
#> 
#>   Catala M, Guo Y, Du M, Lopez-Guell K, Burn E, Mercade-Besora N
#>   (????). _PatientProfiles: Identify Characteristics of Patients in the
#>   OMOP Common Data Model_. R package version 1.3.1,
#>   <https://darwin-eu.github.io/PatientProfiles/>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {PatientProfiles: Identify Characteristics of Patients in the OMOP Common Data Model},
#>     author = {Marti Catala and Yuchen Guo and Mike Du and Kim Lopez-Guell and Edward Burn and Nuria Mercade-Besora},
#>     note = {R package version 1.3.1},
#>     url = {https://darwin-eu.github.io/PatientProfiles/},
#>   }
```

## Example usage

### Create a reference to data in the OMOP CDM format

The PatientProfiles package is designed to work with data in the OMOP
CDM format, so our first step is to create a reference to the data using
the CDMConnector package.

``` r
library(CDMConnector)
library(PatientProfiles)
library(dplyr)
```

Creating a connection to a Postgres database would for example look
like:

``` r
con <- DBI::dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("CDM5_POSTGRESQL_DBNAME"),
  host = Sys.getenv("CDM5_POSTGRESQL_HOST"),
  user = Sys.getenv("CDM5_POSTGRESQL_USER"),
  password = Sys.getenv("CDM5_POSTGRESQL_PASSWORD")
)

cdm <- cdmFromCon(
  con,
  cdmSchema = Sys.getenv("CDM5_POSTGRESQL_CDM_SCHEMA"),
  writeSchema = Sys.getenv("CDM5_POSTGRESQL_RESULT_SCHEMA")
)
```

To see how you would create a reference to your database please consult
the CDMConnector package
[documentation](https://darwin-eu.github.io/CDMConnector/articles/a04_DBI_connection_examples.html).
For this example though we’ll work with simulated data, and we’ll
generate an example cdm reference like so:

``` r
cdm <- mockPatientProfiles(numberIndividuals = 1000)
```

### Adding individuals´ characteristics

#### Adding characteristics to patient-level data

Say we wanted to get individuals´sex and age at condition start date for
records in the condition occurrence table. We can use the `addAge` and
`addSex` functions to do this:

``` r
cdm$condition_occurrence |>
  glimpse()
#> Rows: ??
#> Columns: 6
#> Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ person_id                 <int> 156, 458, 327, 609, 621, 173, 549, 381, 578,…
#> $ condition_start_date      <date> 1955-09-02, 1942-08-31, 1995-07-25, 1981-07…
#> $ condition_end_date        <date> 1965-08-19, 1953-11-24, 1998-09-22, 1987-04…
#> $ condition_occurrence_id   <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1…
#> $ condition_concept_id      <int> 2, 9, 5, 5, 3, 3, 4, 1, 9, 9, 9, 3, 10, 8, 4…
#> $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…

cdm$condition_occurrence <- cdm$condition_occurrence |>
  addAge(indexDate = "condition_start_date") |>
  addSex()

cdm$condition_occurrence |>
  glimpse()
#> Rows: ??
#> Columns: 8
#> Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ person_id                 <int> 156, 621, 173, 381, 557, 963, 653, 998, 719,…
#> $ condition_start_date      <date> 1955-09-02, 1969-04-08, 1970-04-30, 1981-01…
#> $ condition_end_date        <date> 1965-08-19, 1972-10-10, 1971-01-03, 1983-02…
#> $ condition_occurrence_id   <int> 1, 5, 6, 8, 13, 14, 15, 19, 20, 22, 23, 24, …
#> $ condition_concept_id      <int> 2, 3, 3, 1, 10, 8, 4, 10, 8, 10, 9, 1, 6, 8,…
#> $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ age                       <int> 3, 6, 5, 19, 21, 11, 30, 9, 21, 7, 13, 5, 2,…
#> $ sex                       <chr> "Female", "Female", "Female", "Female", "Mal…
```

We could, for example, then limit our data to only males aged between 18
and 65

``` r
cdm$condition_occurrence |>
  filter(age >= 18 & age <= 65) |>
  filter(sex == "Male")
#> # Source:   SQL [?? x 8]
#> # Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#>    person_id condition_start_date condition_end_date condition_occurrence_id
#>        <int> <date>               <date>                               <int>
#>  1       557 1944-07-25           1952-04-19                              13
#>  2       351 1983-06-01           1994-12-31                              27
#>  3       194 2000-03-09           2000-09-29                              29
#>  4       199 1980-10-21           1982-04-19                              42
#>  5       833 1985-11-19           1989-08-19                              45
#>  6       444 1968-07-28           1968-10-27                              49
#>  7       131 1975-12-15           1977-06-01                              60
#>  8       345 1963-03-31           1964-08-23                              70
#>  9       273 1994-05-07           1996-06-21                              71
#> 10       495 1993-08-14           1998-04-26                              85
#> # ℹ more rows
#> # ℹ 4 more variables: condition_concept_id <int>,
#> #   condition_type_concept_id <int>, age <int>, sex <chr>
```

#### Adding characteristics of a cohort

As with other tables in the OMOP CDM, we can work in a similar way with
cohort tables. For example, say we have the below cohort table

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 3, 1, 1, 1, 1, 3, 2, 2, 2, 2, 1, 3, 1, 3, 1, 3, 2…
#> $ subject_id           <int> 306, 387, 912, 870, 878, 45, 833, 149, 110, 616, …
#> $ cohort_start_date    <date> 1930-04-19, 1989-05-12, 1973-08-21, 1915-07-03, …
#> $ cohort_end_date      <date> 1942-01-05, 1998-01-16, 1977-03-13, 1929-02-26, …
```

We can add age, age groups, sex, and days of prior observation to a
cohort like so

``` r
cdm$cohort1 <- cdm$cohort1 |>
  addAge(
    indexDate = "cohort_start_date",
    ageGroup = list(c(0, 18), c(19, 65), c(66, 100))
  ) |>
  addSex() |>
  addPriorObservation()

cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 8
#> Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 1, 1, 3, 2, 2, 1, 1, 3, 2, 2, 2, 3, 3, 1, 3, 1, 1…
#> $ subject_id           <int> 387, 878, 45, 149, 616, 875, 508, 581, 268, 579, …
#> $ cohort_start_date    <date> 1989-05-12, 1972-03-14, 1957-09-03, 1937-05-06, …
#> $ cohort_end_date      <date> 1998-01-16, 1979-09-21, 1959-02-08, 1942-05-13, …
#> $ age                  <int> 22, 7, 8, 5, 31, 20, 9, 21, 22, 9, 7, 10, 18, 8, …
#> $ age_group            <chr> "19 to 65", "0 to 18", "0 to 18", "0 to 18", "19 …
#> $ sex                  <chr> "Male", "Female", "Male", "Female", "Male", "Male…
#> $ prior_observation    <int> 8167, 2629, 3167, 1952, 11535, 7502, 3411, 7839, …
```

We could use this information to subset the cohort. For example limiting
to those with at least 365 days of prior observation available before
their cohort start date like so

``` r
cdm$cohort1 |>
  filter(prior_observation >= 365)
#> # Source:   SQL [?? x 8]
#> # Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date   age
#>                   <int>      <int> <date>            <date>          <int>
#>  1                    1        387 1989-05-12        1998-01-16         22
#>  2                    1        878 1972-03-14        1979-09-21          7
#>  3                    3         45 1957-09-03        1959-02-08          8
#>  4                    2        149 1937-05-06        1942-05-13          5
#>  5                    2        616 1970-08-01        1974-02-04         31
#>  6                    1        875 1990-07-17        1993-06-17         20
#>  7                    1        508 1939-05-05        1952-11-20          9
#>  8                    3        581 1989-06-18        1994-05-29         21
#>  9                    2        268 1944-10-25        1952-11-04         22
#> 10                    2        579 1939-01-29        1962-07-06          9
#> # ℹ more rows
#> # ℹ 3 more variables: age_group <chr>, sex <chr>, prior_observation <int>
```

### Cohort intersections

#### Detect the presence of another cohort in a certain window

We can use `addCohortIntersectFlag` to add a flag for the presence (or
not) of a cohort in a certain window.

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 2, 2, 2, 3, 2, 2, 2, 1, 1, 1
#> $ subject_id           <int> 5, 2, 1, 7, 10, 4, 8, 3, 6, 9
#> $ cohort_start_date    <date> 1968-12-04, 1938-06-13, 1906-07-16, 1945-11-11, 1…
#> $ cohort_end_date      <date> 1968-12-27, 1948-07-14, 1907-02-09, 1946-08-25, 1…

cdm$cohort1 <- cdm$cohort1 |>
  addCohortIntersectFlag(
    targetCohortTable = "cohort2",
    window = c(-Inf, -1)
  )

cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 7
#> Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 2, 2, 1, 2, 2, 3, 2, 2, 1, 1
#> $ subject_id           <int> 5, 4, 6, 2, 1, 7, 10, 8, 3, 9
#> $ cohort_start_date    <date> 1968-12-04, 1926-12-18, 1966-04-26, 1938-06-13, 1…
#> $ cohort_end_date      <date> 1968-12-27, 1939-10-18, 1985-01-13, 1948-07-14, 1…
#> $ cohort_3_minf_to_m1  <dbl> 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
#> $ cohort_1_minf_to_m1  <dbl> 0, 1, 1, 0, 0, 0, 0, 0, 0, 0
#> $ cohort_2_minf_to_m1  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
```

#### Count appearances of a certain cohort in a certain window

If we wanted the number of appearances, we could instead use the
`addCohortIntersectCount` function

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 2, 3, 3, 3, 3, 1, 3, 1, 1, 2
#> $ subject_id           <int> 2, 3, 7, 10, 1, 5, 8, 6, 4, 9
#> $ cohort_start_date    <date> 2015-12-01, 1987-07-03, 1953-10-15, 1968-10-21, 1…
#> $ cohort_end_date      <date> 2019-03-15, 2002-10-16, 1957-02-19, 1979-11-29, 1…

cdm$cohort1 <- cdm$cohort1 |>
  addCohortIntersectCount(
    targetCohortTable = "cohort2",
    targetCohortId = 1,
    window = list("short_term" = c(1, 30), "mid_term" = c(31, 180))
  )

cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 6
#> Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 1, 2, 2, 3, 3, 3, 3, 1, 3, 1
#> $ subject_id           <int> 4, 9, 2, 3, 7, 10, 1, 5, 8, 6
#> $ cohort_start_date    <date> 1953-04-13, 1977-10-03, 2015-12-01, 1987-07-03, 1…
#> $ cohort_end_date      <date> 1974-09-21, 1981-04-22, 2019-03-15, 2002-10-16, 1…
#> $ cohort_1_mid_term    <dbl> 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
#> $ cohort_1_short_term  <dbl> 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
```

#### Add a column with the first/last event in a certain window

Say we wanted the date at which an individual was in another cohort then
we can use the `addCohortIntersectDate` function. As there might be
multiple records for the other cohort, we can also choose the first or
the last appearance in that cohort.

First occurrence:

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 2, 3, 1, 3, 1, 3, 1, 3, 2, 1
#> $ subject_id           <int> 5, 4, 9, 7, 2, 8, 3, 1, 10, 6
#> $ cohort_start_date    <date> 1941-08-04, 1945-09-24, 1937-10-13, 1929-07-16, 1…
#> $ cohort_end_date      <date> 1942-06-25, 1981-02-18, 1937-11-05, 1929-11-22, 1…

cdm$cohort1 <- cdm$cohort1 |>
  addCohortIntersectDate(
    targetCohortTable = "cohort2",
    targetCohortId = 1,
    order = "first",
    window = c(-Inf, Inf)
  )

cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 1, 3, 2, 3, 1, 3, 1, 3, 2, 1
#> $ subject_id           <int> 2, 8, 5, 4, 9, 7, 3, 1, 10, 6
#> $ cohort_start_date    <date> 1956-05-06, 1973-09-24, 1941-08-04, 1945-09-24, 1…
#> $ cohort_end_date      <date> 1986-02-01, 1980-04-14, 1942-06-25, 1981-02-18, 1…
#> $ cohort_1_minf_to_inf <date> 1979-06-01, 1966-08-16, NA, NA, NA, NA, NA, NA, …
```

Last occurrence:

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 3, 3, 2, 2, 1, 2, 2, 3, 3, 2
#> $ subject_id           <int> 2, 6, 4, 8, 10, 9, 1, 5, 3, 7
#> $ cohort_start_date    <date> 1944-08-01, 1947-06-17, 1904-03-09, 1957-03-05, 2…
#> $ cohort_end_date      <date> 1946-08-20, 1951-02-15, 1927-06-28, 1962-09-09, 2…

cdm$cohort1 <- cdm$cohort1 |>
  addCohortIntersectDate(
    targetCohortTable = "cohort2",
    targetCohortId = 1,
    order = "last",
    window = c(-Inf, Inf)
  )

cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 3, 2, 3, 3, 3, 2, 1, 2, 2, 2
#> $ subject_id           <int> 6, 4, 5, 3, 2, 8, 10, 9, 1, 7
#> $ cohort_start_date    <date> 1947-06-17, 1904-03-09, 1913-06-09, 1924-09-15, 1…
#> $ cohort_end_date      <date> 1951-02-15, 1927-06-28, 1920-06-29, 1930-01-23, 1…
#> $ cohort_1_minf_to_inf <date> 1936-02-23, 1906-08-30, 1930-05-25, 1935-04-03, …
```

#### Add the number of days instead of the date

Instead of returning a date, we could return the days to the
intersection by using `addCohortIntersectDays`

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 1, 2, 1, 2, 2, 1, 3, 3, 1, 3
#> $ subject_id           <int> 5, 9, 10, 3, 4, 1, 2, 8, 7, 6
#> $ cohort_start_date    <date> 1908-03-05, 1904-07-25, 1956-01-18, 2012-03-18, 1…
#> $ cohort_end_date      <date> 1909-07-11, 1908-01-27, 1969-04-26, 2013-12-06, 1…

cdm$cohort1 <- cdm$cohort1 |>
  addCohortIntersectDays(
    targetCohortTable = "cohort2",
    targetCohortId = 1,
    order = "last",
    window = c(-Inf, Inf)
  )

cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 1, 2, 2, 2, 1, 1, 3, 3, 1, 3
#> $ subject_id           <int> 5, 9, 3, 4, 10, 1, 2, 8, 7, 6
#> $ cohort_start_date    <date> 1908-03-05, 1904-07-25, 2012-03-18, 1907-03-23, 1…
#> $ cohort_end_date      <date> 1909-07-11, 1908-01-27, 2013-12-06, 1916-10-25, 1…
#> $ cohort_1_minf_to_inf <dbl> 964, 937, -7714, 5191, NA, NA, NA, NA, NA, NA
```

#### Combine multiple cohort intersects

If we want to combine multiple cohort intersects we can concatenate the
operations using the `pipe` operator:

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 2, 3, 2, 1, 3, 2, 2, 3, 3, 2
#> $ subject_id           <int> 9, 2, 7, 8, 1, 3, 5, 6, 4, 10
#> $ cohort_start_date    <date> 1976-04-06, 1950-11-24, 2010-05-13, 1949-09-30, 1…
#> $ cohort_end_date      <date> 1992-07-18, 1955-08-08, 2010-09-07, 1957-09-29, 2…

cdm$cohort1 <- cdm$cohort1 |>
  addCohortIntersectDate(
    targetCohortTable = "cohort2",
    targetCohortId = 1,
    order = "last",
    window = c(-Inf, Inf)
  ) |>
  addCohortIntersectCount(
    targetCohortTable = "cohort2",
    targetCohortId = 1,
    window = c(-Inf, Inf)
  )

cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> Database: DuckDB v1.2.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 2, 3, 1, 3, 2, 3, 2, 2, 3, 2
#> $ subject_id           <int> 9, 2, 8, 1, 5, 6, 7, 3, 4, 10
#> $ cohort_start_date    <date> 1976-04-06, 1950-11-24, 1949-09-30, 1996-03-01, 1…
#> $ cohort_end_date      <date> 1992-07-18, 1955-08-08, 1957-09-29, 2013-06-08, 2…
#> $ cohort_1_minf_to_inf <dbl> 1, 1, 1, 1, 1, 1, 0, 0, 0, 0
```

``` r
mockDisconnect(cdm)
```
