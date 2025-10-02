
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
#>   Català M, Guo Y, Du M, Lopez-Guell K, Burn E, Mercade-Besora N
#>   (????). _PatientProfiles: Identify Characteristics of Patients in the
#>   OMOP Common Data Model_. R package version 1.4.3,
#>   <https://darwin-eu.github.io/PatientProfiles/>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {PatientProfiles: Identify Characteristics of Patients in the OMOP Common Data Model},
#>     author = {Martí Català and Yuchen Guo and Mike Du and Kim Lopez-Guell and Edward Burn and Nuria Mercade-Besora},
#>     note = {R package version 1.4.3},
#>     url = {https://darwin-eu.github.io/PatientProfiles/},
#>   }
```

## Example usage

### Create a reference to data in the OMOP CDM format

The PatientProfiles package is designed to work with data in the OMOP
CDM format, so our first step is to create a reference to the data using
the CDMConnector package.

``` r
library(PatientProfiles)
library(dplyr)
```

Creating a connection to a Postgres database would for example look
like:

``` r
library(RPostgres)
library(CDMConnector)

con <- dbConnect(
  drv = Postgres(),
  dbname = Sys.getenv("CDM5_POSTGRESQL_DBNAME"),
  host = Sys.getenv("CDM5_POSTGRESQL_HOST"),
  user = Sys.getenv("CDM5_POSTGRESQL_USER"),
  password = Sys.getenv("CDM5_POSTGRESQL_PASSWORD")
)

cdm <- cdmFromCon(
  con = con,
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
cdm <- mockPatientProfiles(numberIndividuals = 1000, source = "duckdb")
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
#> Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#> $ person_id                 <int> 814, 640, 731, 853, 505, 817, 270, 313, 138,…
#> $ condition_start_date      <date> 2008-02-05, 1920-08-28, 1970-04-23, 1915-04…
#> $ condition_end_date        <date> 2009-10-30, 1928-01-13, 1970-08-02, 1924-02…
#> $ condition_occurrence_id   <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1…
#> $ condition_concept_id      <int> 5, 6, 8, 2, 7, 9, 2, 4, 2, 1, 5, 4, 3, 6, 8,…
#> $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…

cdm$condition_occurrence <- cdm$condition_occurrence |>
  addAge(indexDate = "condition_start_date") |>
  addSex()

cdm$condition_occurrence |>
  glimpse()
#> Rows: ??
#> Columns: 8
#> Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#> $ person_id                 <int> 138, 174, 207, 216, 239, 270, 276, 313, 317,…
#> $ condition_start_date      <date> 1939-09-09, 1912-06-21, 1926-12-14, 1928-05…
#> $ condition_end_date        <date> 1948-11-09, 1927-04-21, 1937-09-29, 1931-04…
#> $ condition_occurrence_id   <int> 9, 12, 23, 13, 32, 7, 20, 8, 24, 33, 14, 28,…
#> $ condition_concept_id      <int> 2, 4, 3, 3, 7, 2, 10, 4, 4, 2, 6, 9, 5, 8, 7…
#> $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ age                       <int> 6, 4, 13, 8, 32, 18, 0, 25, 19, 34, 45, 38, …
#> $ sex                       <chr> "Female", "Male", "Female", "Male", "Male", …
```

We could, for example, then limit our data to only males aged between 18
and 65

``` r
cdm$condition_occurrence |>
  filter(age >= 18 & age <= 65) |>
  filter(sex == "Male")
#> # Source:   SQL [?? x 8]
#> # Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#>   person_id condition_start_date condition_end_date condition_occurrence_id
#>       <int> <date>               <date>                               <int>
#> 1       239 1991-12-11           1996-11-27                              32
#> 2       404 1982-10-31           1984-12-04                              28
#> 3       682 1932-09-09           1937-08-15                              10
#> 4       814 2008-02-05           2009-10-30                               1
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
#> Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 3, 2, 3, 1, 3, 3, 2, 2, 2, 2, 2, 3, 2, 1, 1, 2, 1…
#> $ subject_id           <int> 415, 780, 507, 560, 948, 940, 194, 643, 119, 298,…
#> $ cohort_start_date    <date> 1916-09-02, 1906-05-02, 1944-06-11, 1950-05-29, …
#> $ cohort_end_date      <date> 1937-04-16, 1928-07-12, 1948-03-30, 1961-06-14, …
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
#> Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 1, 1, 1, 2, 3, 2, 3, 3, 3, 3, 1, 1, 1, 2, 3, 2, 3…
#> $ subject_id           <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15…
#> $ cohort_start_date    <date> 1946-09-18, 1955-11-24, 1953-06-04, 1925-11-12, …
#> $ cohort_end_date      <date> 1974-02-24, 1960-02-26, 1955-11-09, 1930-06-10, …
#> $ age                  <int> 1, 33, 9, 6, 29, 10, 21, 23, 8, 18, 8, 5, 24, 7, …
#> $ age_group            <chr> "0 to 18", "19 to 65", "0 to 18", "0 to 18", "19 …
#> $ sex                  <chr> "Male", "Female", "Male", "Female", "Male", "Male…
#> $ prior_observation    <int> 625, 12380, 3442, 2507, 10630, 3733, 7745, 8553, …
```

We could use this information to subset the cohort. For example limiting
to those with at least 365 days of prior observation available before
their cohort start date like so

``` r
cdm$cohort1 |>
  filter(prior_observation >= 365)
#> # Source:   SQL [?? x 8]
#> # Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date   age
#>                   <int>      <int> <date>            <date>          <int>
#>  1                    1          1 1946-09-18        1974-02-24          1
#>  2                    1          2 1955-11-24        1960-02-26         33
#>  3                    1          3 1953-06-04        1955-11-09          9
#>  4                    2          4 1925-11-12        1930-06-10          6
#>  5                    3          5 1960-02-08        1960-10-07         29
#>  6                    2          6 1918-03-22        1922-05-22         10
#>  7                    3          7 1942-03-17        1944-07-08         21
#>  8                    3          8 1982-06-02        1990-11-15         23
#>  9                    3          9 1929-02-06        1936-07-28          8
#> 10                    3         10 1955-11-17        1958-12-22         18
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
#> Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 1, 2, 3, 1, 2, 2, 3, 2, 2, 2
#> $ subject_id           <int> 1, 2, 10, 9, 3, 7, 6, 8, 4, 5
#> $ cohort_start_date    <date> 1992-07-20, 1979-03-29, 1987-04-30, 1982-04-23, 1…
#> $ cohort_end_date      <date> 2000-07-17, 1984-08-07, 1987-05-10, 1985-05-08, 1…

cdm$cohort1 <- cdm$cohort1 |>
  addCohortIntersectFlag(
    targetCohortTable = "cohort2",
    window = c(-Inf, -1)
  )

cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 7
#> Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 3, 1, 2, 3, 1, 2, 2, 2, 2, 2
#> $ subject_id           <int> 10, 9, 3, 6, 1, 2, 7, 8, 4, 5
#> $ cohort_start_date    <date> 1987-04-30, 1982-04-23, 1962-01-26, 2012-07-24, 1…
#> $ cohort_end_date      <date> 1987-05-10, 1985-05-08, 1962-11-06, 2014-06-17, 2…
#> $ cohort_2_minf_to_m1  <dbl> 0, 1, 0, 1, 0, 0, 0, 0, 0, 0
#> $ cohort_1_minf_to_m1  <dbl> 1, 0, 1, 0, 0, 0, 0, 0, 0, 0
#> $ cohort_3_minf_to_m1  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
```

#### Count appearances of a certain cohort in a certain window

If we wanted the number of appearances, we could instead use the
`addCohortIntersectCount` function

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 2, 1, 3, 2, 1, 1, 1, 2, 2, 1
#> $ subject_id           <int> 2, 3, 6, 8, 4, 7, 5, 1, 9, 10
#> $ cohort_start_date    <date> 1938-06-21, 1993-11-29, 1977-10-21, 1968-11-30, 1…
#> $ cohort_end_date      <date> 1948-04-26, 1994-01-01, 1985-11-25, 1972-09-03, 1…

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
#> Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 1, 1, 1, 2, 3, 2, 1, 2, 2, 1
#> $ subject_id           <int> 3, 4, 7, 2, 6, 8, 5, 1, 9, 10
#> $ cohort_start_date    <date> 1993-11-29, 1989-12-28, 1952-08-05, 1938-06-21, 1…
#> $ cohort_end_date      <date> 1994-01-01, 1995-07-31, 1953-05-23, 1948-04-26, 1…
#> $ cohort_1_mid_term    <dbl> 1, 1, 1, 0, 0, 0, 0, 0, 0, 0
#> $ cohort_1_short_term  <dbl> 1, 1, 1, 0, 0, 0, 0, 0, 0, 0
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
#> Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 2, 2, 2, 2, 1, 3, 1, 3, 1, 1
#> $ subject_id           <int> 4, 5, 7, 6, 9, 8, 3, 2, 1, 10
#> $ cohort_start_date    <date> 1938-11-11, 1922-07-20, 1950-02-23, 1985-12-16, 1…
#> $ cohort_end_date      <date> 1943-08-29, 1927-03-23, 1953-08-20, 1989-03-20, 1…

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
#> Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 3, 3, 1, 2, 2, 2, 2, 1, 1, 1
#> $ subject_id           <int> 8, 2, 10, 4, 5, 7, 6, 9, 3, 1
#> $ cohort_start_date    <date> 1954-12-03, 1963-02-19, 1945-03-20, 1938-11-11, 1…
#> $ cohort_end_date      <date> 1969-08-13, 1963-02-20, 1945-09-11, 1943-08-29, 1…
#> $ cohort_1_minf_to_inf <date> 1929-07-25, 1914-10-14, 1942-12-05, NA, NA, NA, …
```

Last occurrence:

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 3, 3, 3, 3, 3, 1, 3, 2, 1, 1
#> $ subject_id           <int> 5, 8, 6, 1, 7, 9, 3, 2, 10, 4
#> $ cohort_start_date    <date> 1948-10-29, 1929-07-30, 1938-03-07, 1947-04-25, 1…
#> $ cohort_end_date      <date> 1952-10-15, 1930-09-16, 1940-04-22, 1948-03-22, 2…

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
#> Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 3, 3, 1, 3, 3, 3, 3, 2, 1, 1
#> $ subject_id           <int> 6, 1, 9, 5, 8, 7, 3, 2, 10, 4
#> $ cohort_start_date    <date> 1938-03-07, 1947-04-25, 1958-12-30, 1948-10-29, 1…
#> $ cohort_end_date      <date> 1940-04-22, 1948-03-22, 1975-01-06, 1952-10-15, 1…
#> $ cohort_1_minf_to_inf <date> 1923-06-06, 1922-10-10, 1969-03-25, NA, NA, NA, …
```

#### Add the number of days instead of the date

Instead of returning a date, we could return the days to the
intersection by using `addCohortIntersectDays`

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 3, 3, 2, 1, 1, 2, 1, 1, 3, 3
#> $ subject_id           <int> 9, 4, 1, 3, 8, 10, 7, 2, 6, 5
#> $ cohort_start_date    <date> 1922-11-01, 1933-04-23, 1961-09-09, 1932-10-19, 1…
#> $ cohort_end_date      <date> 1926-01-29, 1971-01-01, 1963-08-29, 1938-11-18, 1…

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
#> Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 3, 2, 1, 3, 3, 1, 2, 1, 1, 3
#> $ subject_id           <int> 4, 1, 8, 5, 9, 3, 10, 7, 2, 6
#> $ cohort_start_date    <date> 1933-04-23, 1961-09-09, 1955-07-31, 1931-08-05, 1…
#> $ cohort_end_date      <date> 1971-01-01, 1963-08-29, 1967-08-18, 1933-06-05, 1…
#> $ cohort_1_minf_to_inf <dbl> 15815, -202, -3652, 4575, NA, NA, NA, NA, NA, NA
```

#### Combine multiple cohort intersects

If we want to combine multiple cohort intersects we can concatenate the
operations using the `pipe` operator:

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 1, 1, 2, 2, 2, 2, 2, 1, 2, 3
#> $ subject_id           <int> 10, 3, 1, 8, 5, 6, 7, 2, 9, 4
#> $ cohort_start_date    <date> 1942-04-12, 2013-06-07, 2004-09-20, 1937-05-23, 1…
#> $ cohort_end_date      <date> 1942-10-19, 2017-02-20, 2005-11-04, 1957-12-10, 1…

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
#> Database: DuckDB 1.4.0 [root@Darwin 24.6.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 1, 2, 1, 1, 2, 2, 2, 2, 2, 3
#> $ subject_id           <int> 10, 5, 2, 3, 1, 8, 6, 7, 9, 4
#> $ cohort_start_date    <date> 1942-04-12, 1923-07-21, 1947-06-02, 2013-06-07, 2…
#> $ cohort_end_date      <date> 1942-10-19, 1924-04-07, 1954-10-29, 2017-02-20, 2…
#> $ cohort_1_minf_to_inf <dbl> 1, 1, 1, 0, 0, 0, 0, 0, 0, 0
```

``` r
mockDisconnect(cdm)
```
