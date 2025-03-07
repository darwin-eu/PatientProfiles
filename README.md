
# PatientProfiles <img src="man/figures/logo.png" align="right" height="200"/>

[![CRAN
status](https://www.r-pkg.org/badges/version/PatientProfiles)](https://CRAN.R-project.org/package=PatientProfiles)
[![codecov.io](https://codecov.io/github/darwin-eu/PatientProfiles/coverage.svg?branch=main)](https://app.codecov.io/github/darwin-eu/PatientProfiles?branch=main)
[![R-CMD-check](https://github.com/darwin-eu/PatientProfiles/workflows/R-CMD-check/badge.svg)](https://github.com/darwin-eu/PatientProfiles/actions)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
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
#>   OMOP Common Data Model_. R package version 1.2.3,
#>   <https://darwin-eu.github.io/PatientProfiles/>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {PatientProfiles: Identify Characteristics of Patients in the OMOP Common Data Model},
#>     author = {Marti Catala and Yuchen Guo and Mike Du and Kim Lopez-Guell and Edward Burn and Nuria Mercade-Besora},
#>     note = {R package version 1.2.3},
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
#> Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ person_id                 <int> 589, 319, 166, 603, 886, 239, 509, 516, 79, …
#> $ condition_start_date      <date> 1963-06-06, 1981-02-01, 1985-08-30, 1982-07…
#> $ condition_end_date        <date> 1963-12-19, 1981-09-11, 1998-09-06, 1984-11…
#> $ condition_occurrence_id   <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1…
#> $ condition_concept_id      <int> 9, 10, 6, 10, 4, 7, 2, 5, 10, 5, 4, 6, 4, 8,…
#> $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…

cdm$condition_occurrence <- cdm$condition_occurrence |>
  addAge(indexDate = "condition_start_date") |>
  addSex()

cdm$condition_occurrence |>
  glimpse()
#> Rows: ??
#> Columns: 8
#> Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ person_id                 <int> 589, 166, 603, 886, 516, 79, 426, 352, 798, …
#> $ condition_start_date      <date> 1963-06-06, 1985-08-30, 1982-07-06, 1929-06…
#> $ condition_end_date        <date> 1963-12-19, 1998-09-06, 1984-11-06, 1935-01…
#> $ condition_occurrence_id   <int> 1, 3, 4, 5, 8, 9, 12, 14, 15, 17, 19, 20, 21…
#> $ condition_concept_id      <int> 9, 6, 10, 4, 5, 10, 6, 8, 2, 3, 4, 9, 9, 8, …
#> $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ age                       <int> 14, 8, 8, 22, 24, 17, 5, 15, 10, 50, 14, 16,…
#> $ sex                       <chr> "Female", "Female", "Female", "Male", "Femal…
```

We could, for example, then limit our data to only males aged between 18
and 65

``` r
cdm$condition_occurrence |>
  filter(age >= 18 & age <= 65) |>
  filter(sex == "Male")
#> # Source:   SQL [?? x 8]
#> # Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#>    person_id condition_start_date condition_end_date condition_occurrence_id
#>        <int> <date>               <date>                               <int>
#>  1       886 1929-06-26           1935-01-20                               5
#>  2        76 2028-07-04           2029-12-03                              17
#>  3       515 1954-03-05           1959-05-13                              31
#>  4       530 1970-10-26           1978-07-20                              34
#>  5       669 1951-08-25           1958-06-03                              46
#>  6       358 1948-06-10           1955-05-15                              53
#>  7       478 1995-08-05           1995-12-11                              73
#>  8        50 1987-09-10           1994-09-17                              79
#>  9       987 1961-09-30           1963-08-07                              84
#> 10       592 1945-11-05           1947-05-11                              96
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
#> Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 1, 1, 3, 3, 2, 1, 3, 3, 1, 2, 2, 1, 2, 2, 1, 1, 2…
#> $ subject_id           <int> 179, 961, 340, 386, 462, 250, 94, 142, 266, 753, …
#> $ cohort_start_date    <date> 1934-07-20, 1911-01-27, 1948-02-15, 1960-07-29, …
#> $ cohort_end_date      <date> 1936-07-30, 1936-06-27, 1950-01-18, 1963-11-05, …
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
#> Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 2, 3, 2, 2, 2, 3, 3, 3, 1, 2, 3, 2, 1, 3, 1, 2, 2…
#> $ subject_id           <int> 1, 2, 4, 5, 7, 8, 9, 11, 12, 13, 14, 16, 17, 18, …
#> $ cohort_start_date    <date> 1951-06-11, 1943-05-05, 1910-06-06, 1942-04-27, …
#> $ cohort_end_date      <date> 1951-10-18, 1944-04-30, 1919-09-18, 1968-09-14, …
#> $ age                  <int> 8, 7, 5, 10, 30, 0, 0, 4, 27, 12, 3, 5, 22, 7, 4,…
#> $ age_group            <chr> "0 to 18", "0 to 18", "0 to 18", "0 to 18", "19 t…
#> $ sex                  <chr> "Male", "Male", "Male", "Female", "Female", "Male…
#> $ prior_observation    <int> 3083, 2681, 1982, 3769, 11317, 182, 7, 1555, 1011…
```

We could use this information to subset the cohort. For example limiting
to those with at least 365 days of prior observation available before
their cohort start date like so

``` r
cdm$cohort1 |>
  filter(prior_observation >= 365)
#> # Source:   SQL [?? x 8]
#> # Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date   age
#>                   <int>      <int> <date>            <date>          <int>
#>  1                    2          1 1951-06-11        1951-10-18          8
#>  2                    3          2 1943-05-05        1944-04-30          7
#>  3                    2          4 1910-06-06        1919-09-18          5
#>  4                    2          5 1942-04-27        1968-09-14         10
#>  5                    2          7 1954-12-26        1957-05-08         30
#>  6                    3         11 1943-04-05        1966-10-09          4
#>  7                    1         12 1957-09-06        1958-04-04         27
#>  8                    2         13 1930-11-09        1937-07-20         12
#>  9                    3         14 1912-06-18        1942-03-20          3
#> 10                    2         16 1977-09-15        1978-04-13          5
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
#> Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 1, 2, 1, 1, 2, 3, 1, 3, 1, 2
#> $ subject_id           <int> 10, 8, 3, 7, 5, 1, 9, 2, 6, 4
#> $ cohort_start_date    <date> 1985-11-23, 1944-09-11, 1936-05-07, 1928-06-24, 1…
#> $ cohort_end_date      <date> 1992-07-12, 1959-01-19, 1949-07-18, 1935-07-14, 1…

cdm$cohort1 <- cdm$cohort1 |>
  addCohortIntersectFlag(
    targetCohortTable = "cohort2",
    window = c(-Inf, -1)
  )

cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 7
#> Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 2, 3, 1, 1, 2, 1, 2, 1, 1, 3
#> $ subject_id           <int> 5, 1, 9, 6, 4, 10, 8, 3, 7, 2
#> $ cohort_start_date    <date> 1974-06-17, 1999-09-16, 1990-07-10, 1990-04-28, 2…
#> $ cohort_end_date      <date> 1977-01-11, 2013-08-01, 1995-05-04, 2001-08-14, 2…
#> $ cohort_3_minf_to_m1  <dbl> 0, 1, 0, 1, 0, 0, 0, 0, 0, 0
#> $ cohort_1_minf_to_m1  <dbl> 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
#> $ cohort_2_minf_to_m1  <dbl> 1, 0, 0, 0, 1, 0, 0, 0, 0, 0
```

#### Count appearances of a certain cohort in a certain window

If we wanted the number of appearances, we could instead use the
`addCohortIntersectCount` function

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 3, 2, 3, 2, 2, 2, 1, 2, 1, 3
#> $ subject_id           <int> 1, 6, 9, 5, 7, 2, 8, 4, 3, 10
#> $ cohort_start_date    <date> 1967-07-08, 1975-11-03, 1940-01-29, 1929-05-03, 1…
#> $ cohort_end_date      <date> 1990-06-21, 1977-03-03, 1957-10-05, 1929-12-21, 1…

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
#> Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 2, 3, 2, 3, 2, 2, 1, 2, 1, 3
#> $ subject_id           <int> 2, 1, 6, 9, 5, 7, 8, 4, 3, 10
#> $ cohort_start_date    <date> 1949-08-26, 1967-07-08, 1975-11-03, 1940-01-29, 1…
#> $ cohort_end_date      <date> 1951-07-06, 1990-06-21, 1977-03-03, 1957-10-05, 1…
#> $ cohort_1_short_term  <dbl> 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
#> $ cohort_1_mid_term    <dbl> 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
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
#> Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 1, 1, 2, 3, 2, 3, 2, 2, 1, 1
#> $ subject_id           <int> 6, 5, 1, 2, 9, 8, 7, 10, 4, 3
#> $ cohort_start_date    <date> 1924-03-08, 1926-02-10, 1965-08-30, 1914-02-07, 1…
#> $ cohort_end_date      <date> 1924-08-05, 1931-04-12, 1980-09-12, 1915-02-13, 1…

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
#> Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 1, 3, 1, 2, 3, 2, 2, 2, 1, 1
#> $ subject_id           <int> 6, 8, 5, 1, 2, 9, 7, 10, 4, 3
#> $ cohort_start_date    <date> 1924-03-08, 1948-08-27, 1926-02-10, 1965-08-30, 1…
#> $ cohort_end_date      <date> 1924-08-05, 1950-04-06, 1931-04-12, 1980-09-12, 1…
#> $ cohort_1_minf_to_inf <date> 1911-03-03, 1934-09-06, NA, NA, NA, NA, NA, NA, …
```

Last occurrence:

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 3, 3, 3, 1, 1, 2, 1, 3, 3, 3
#> $ subject_id           <int> 2, 10, 9, 6, 4, 1, 3, 7, 5, 8
#> $ cohort_start_date    <date> 1966-06-09, 1983-01-25, 1981-07-03, 1977-03-24, 1…
#> $ cohort_end_date      <date> 1968-01-28, 1989-09-13, 1981-08-11, 1994-05-30, 2…

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
#> Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 1, 2, 3, 3, 3, 3, 1, 1, 3, 3
#> $ subject_id           <int> 6, 1, 8, 2, 10, 9, 4, 3, 7, 5
#> $ cohort_start_date    <date> 1977-03-24, 1987-07-30, 1988-12-08, 1966-06-09, 1…
#> $ cohort_end_date      <date> 1994-05-30, 1989-12-17, 1989-03-20, 1968-01-28, 1…
#> $ cohort_1_minf_to_inf <date> 1989-01-11, 1982-10-15, 1984-10-15, NA, NA, NA, …
```

#### Add the number of days instead of the date

Instead of returning a date, we could return the days to the
intersection by using `addCohortIntersectDays`

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 3, 2, 1, 2, 3, 2, 1, 1, 2, 1
#> $ subject_id           <int> 10, 4, 9, 7, 2, 1, 3, 8, 6, 5
#> $ cohort_start_date    <date> 1940-08-16, 1921-10-07, 1962-04-14, 1927-03-26, 1…
#> $ cohort_end_date      <date> 1941-11-27, 1936-03-13, 1965-03-23, 1937-08-27, 1…

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
#> Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 2, 2, 3, 1, 3, 1, 2, 1, 1, 2
#> $ subject_id           <int> 4, 7, 2, 5, 10, 9, 1, 3, 8, 6
#> $ cohort_start_date    <date> 1921-10-07, 1927-03-26, 1934-06-18, 1971-06-21, 1…
#> $ cohort_end_date      <date> 1936-03-13, 1937-08-27, 1936-02-16, 1981-04-02, 1…
#> $ cohort_1_minf_to_inf <dbl> 2323, 7448, 1496, 827, NA, NA, NA, NA, NA, NA
```

#### Combine multiple cohort intersects

If we want to combine multiple cohort intersects we can concatenate the
operations using the `pipe` operator:

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 1, 1, 1, 1, 1, 1, 1, 2, 3, 2
#> $ subject_id           <int> 3, 7, 1, 8, 6, 10, 2, 9, 5, 4
#> $ cohort_start_date    <date> 1961-02-12, 1961-06-21, 1931-11-05, 1960-11-22, 1…
#> $ cohort_end_date      <date> 1972-11-08, 1977-01-04, 1932-11-15, 1964-07-01, 1…

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
#> Database: DuckDB v1.1.0 [root@Darwin 24.3.0:R 4.4.1/:memory:]
#> $ cohort_definition_id <int> 3, 1, 1, 1, 1, 1, 1, 1, 2, 2
#> $ subject_id           <int> 5, 3, 7, 1, 8, 6, 10, 2, 9, 4
#> $ cohort_start_date    <date> 1951-03-28, 1961-02-12, 1961-06-21, 1931-11-05, 1…
#> $ cohort_end_date      <date> 1957-06-26, 1972-11-08, 1977-01-04, 1932-11-15, 1…
#> $ cohort_1_minf_to_inf <dbl> 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
```

``` r
mockDisconnect(cdm)
```
