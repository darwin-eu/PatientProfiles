
# PatientProfiles <img src="man/figures/logo.png" align="right" height="200"/>

[![CRAN status](https://www.r-pkg.org/badges/version/PatientProfiles)](https://CRAN.R-project.org/package=PatientProfiles)
[![codecov.io](https://codecov.io/github/darwin-eu/PatientProfiles/coverage.svg?branch=main)](https://app.codecov.io/github/darwin-eu/PatientProfiles?branch=main)
[![R-CMD-check](https://github.com/darwin-eu/PatientProfiles/workflows/R-CMD-check/badge.svg)](https://github.com/darwin-eu/PatientProfiles/actions)
[![Lifecycle:stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![metacran downloads](https://cranlogs.r-pkg.org/badges/PatientProfiles)](https://cran.r-project.org/package=PatientProfiles)
[![metacran downloads](https://cranlogs.r-pkg.org/badges/grand-total/PatientProfiles)](https://cran.r-project.org/package=PatientProfiles)

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
#> 
#> To cite package 'PatientProfiles' in publications use:
#> 
#>   Catala M, Guo Y, Du M, Lopez-Guell K, Burn E, Mercade-Besora N
#>   (????). _PatientProfiles: Identify Characteristics of Patients in the
#>   OMOP Common Data Model_. R package version 1.2.1,
#>   <https://darwin-eu.github.io/PatientProfiles/>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {PatientProfiles: Identify Characteristics of Patients in the OMOP Common Data Model},
#>     author = {Marti Catala and Yuchen Guo and Mike Du and Kim Lopez-Guell and Edward Burn and Nuria Mercade-Besora},
#>     note = {R package version 1.2.1},
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

cdm <- cdm_from_con(
  con,
  cdm_schema = Sys.getenv("CDM5_POSTGRESQL_CDM_SCHEMA"),
  write_schema = Sys.getenv("CDM5_POSTGRESQL_RESULT_SCHEMA")
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
#> Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#> $ person_id                 <int> 778, 530, 421, 858, 144, 579, 646, 185, 174,…
#> $ condition_start_date      <date> 1912-06-09, 1990-01-17, 1946-11-29, 1953-11…
#> $ condition_end_date        <date> 1922-03-03, 1991-11-16, 1949-05-22, 1965-10…
#> $ condition_occurrence_id   <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1…
#> $ condition_concept_id      <int> 2, 5, 5, 5, 7, 7, 10, 4, 10, 5, 6, 7, 2, 4, …
#> $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…

cdm$condition_occurrence <- cdm$condition_occurrence |>
  addAge(indexDate = "condition_start_date") |>
  addSex()

cdm$condition_occurrence |>
  glimpse()
#> Rows: ??
#> Columns: 8
#> Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#> $ person_id                 <int> 778, 530, 858, 144, 579, 185, 174, 426, 9, 5…
#> $ condition_start_date      <date> 1912-06-09, 1990-01-17, 1953-11-10, 1966-05…
#> $ condition_end_date        <date> 1922-03-03, 1991-11-16, 1965-10-24, 1966-07…
#> $ condition_occurrence_id   <int> 1, 2, 4, 5, 6, 8, 9, 10, 11, 13, 14, 15, 17,…
#> $ condition_concept_id      <int> 2, 5, 5, 7, 7, 4, 10, 5, 6, 2, 4, 1, 6, 5, 6…
#> $ condition_type_concept_id <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ age                       <int> 5, 31, 22, 16, 50, 0, 16, 28, 20, 10, 34, 7,…
#> $ sex                       <chr> "Male", "Male", "Male", "Female", "Male", "M…
```

We could, for example, then limit our data to only males aged between 18
and 65

``` r
cdm$condition_occurrence |>
  filter(age >= 18 & age <= 65) |>
  filter(sex == "Male")
#> # Source:   SQL [?? x 8]
#> # Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#>    person_id condition_start_date condition_end_date condition_occurrence_id
#>        <int> <date>               <date>                               <int>
#>  1       530 1990-01-17           1991-11-16                               2
#>  2       858 1953-11-10           1965-10-24                               4
#>  3       579 1996-12-07           1998-01-13                               6
#>  4       426 1991-03-14           1997-04-27                              10
#>  5         9 1966-12-27           1969-06-02                              11
#>  6        32 2000-06-03           2008-07-17                              17
#>  7         9 1973-12-31           1987-05-25                              23
#>  8       649 2000-08-22           2008-02-22                              33
#>  9       284 1931-11-30           1939-01-08                              49
#> 10       707 1977-02-11           1978-10-10                              54
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
#> Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#> $ cohort_definition_id <int> 1, 1, 2, 1, 2, 3, 1, 3, 2, 3, 1, 2, 1, 2, 1, 2, 2…
#> $ subject_id           <int> 93, 783, 571, 218, 462, 103, 15, 404, 602, 333, 1…
#> $ cohort_start_date    <date> 1970-07-10, 1943-10-13, 1933-05-15, 1934-06-18, …
#> $ cohort_end_date      <date> 1984-02-26, 1947-11-11, 1933-06-11, 1949-09-17, …
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
#> Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#> $ cohort_definition_id <int> 1, 2, 2, 2, 1, 3, 2, 2, 3, 1, 1, 2, 1, 2, 2, 2, 3…
#> $ subject_id           <int> 2, 4, 5, 7, 8, 9, 11, 13, 14, 15, 17, 18, 22, 24,…
#> $ cohort_start_date    <date> 1931-10-24, 1975-04-04, 1978-03-13, 1914-07-03, …
#> $ cohort_end_date      <date> 1953-08-30, 1987-07-31, 1988-01-13, 1925-06-15, …
#> $ age                  <int> 10, 0, 3, 0, 12, 5, 21, 14, 8, 16, 0, 10, 1, 0, 8…
#> $ age_group            <chr> "0 to 18", "0 to 18", "0 to 18", "0 to 18", "0 to…
#> $ sex                  <chr> "Male", "Male", "Female", "Female", "Male", "Male…
#> $ prior_observation    <int> 3948, 93, 1167, 183, 4705, 2100, 7942, 5238, 3203…
```

We could use this information to subset the cohort. For example limiting
to those with at least 365 days of prior observation available before
their cohort start date like so

``` r
cdm$cohort1 |>
  filter(prior_observation >= 365)
#> # Source:   SQL [?? x 8]
#> # Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date   age
#>                   <int>      <int> <date>            <date>          <int>
#>  1                    1          2 1931-10-24        1953-08-30         10
#>  2                    2          5 1978-03-13        1988-01-13          3
#>  3                    1          8 1933-11-19        1935-05-11         12
#>  4                    3          9 1951-10-02        1966-05-19          5
#>  5                    2         11 1987-09-30        1991-02-25         21
#>  6                    2         13 1934-05-05        1937-09-21         14
#>  7                    3         14 1988-10-08        1990-12-31          8
#>  8                    1         15 1920-05-19        1924-07-11         16
#>  9                    2         18 1973-11-17        1978-07-31         10
#> 10                    1         22 1938-09-28        1956-07-31          1
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
#> Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#> $ cohort_definition_id <int> 3, 1, 2, 2, 3, 2, 2, 2, 1, 3
#> $ subject_id           <int> 10, 4, 1, 5, 3, 7, 9, 6, 2, 8
#> $ cohort_start_date    <date> 1974-02-03, 1918-10-07, 1967-07-21, 1951-05-19, 1…
#> $ cohort_end_date      <date> 1974-12-26, 1920-03-27, 1967-12-09, 1953-09-30, 1…

cdm$cohort1 <- cdm$cohort1 |>
  addCohortIntersectFlag(
    targetCohortTable = "cohort2",
    window = c(-Inf, -1)
  )

cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 7
#> Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#> $ cohort_definition_id <int> 3, 2, 2, 2, 2, 1, 3, 2, 1, 3
#> $ subject_id           <int> 10, 1, 5, 7, 9, 4, 3, 6, 2, 8
#> $ cohort_start_date    <date> 1974-02-03, 1967-07-21, 1951-05-19, 1934-06-19, 1…
#> $ cohort_end_date      <date> 1974-12-26, 1967-12-09, 1953-09-30, 1938-06-10, 1…
#> $ cohort_1_minf_to_m1  <dbl> 0, 1, 0, 0, 1, 0, 0, 0, 0, 0
#> $ cohort_2_minf_to_m1  <dbl> 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
#> $ cohort_3_minf_to_m1  <dbl> 0, 0, 1, 1, 0, 0, 0, 0, 0, 0
```

#### Count appearances of a certain cohort in a certain window

If we wanted the number of appearances, we could instead use the
`addCohortIntersectCount` function

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#> $ cohort_definition_id <int> 2, 1, 3, 2, 1, 1, 2, 3, 2, 1
#> $ subject_id           <int> 4, 1, 7, 2, 3, 5, 10, 6, 9, 8
#> $ cohort_start_date    <date> 1961-04-27, 1997-02-08, 1956-03-09, 1980-07-04, 1…
#> $ cohort_end_date      <date> 1970-08-24, 2011-04-10, 1956-12-19, 1989-02-23, 1…

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
#> Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#> $ cohort_definition_id <int> 2, 2, 1, 3, 2, 1, 1, 2, 3, 1
#> $ subject_id           <int> 9, 4, 1, 7, 2, 3, 5, 10, 6, 8
#> $ cohort_start_date    <date> 1922-08-27, 1961-04-27, 1997-02-08, 1956-03-09, 1…
#> $ cohort_end_date      <date> 1928-06-22, 1970-08-24, 2011-04-10, 1956-12-19, 1…
#> $ cohort_1_mid_term    <dbl> 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
#> $ cohort_1_short_term  <dbl> 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
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
#> Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#> $ cohort_definition_id <int> 3, 3, 2, 1, 1, 1, 3, 1, 3, 2
#> $ subject_id           <int> 9, 4, 6, 8, 1, 5, 10, 7, 2, 3
#> $ cohort_start_date    <date> 1972-05-17, 1936-05-20, 1954-03-09, 1935-10-23, 2…
#> $ cohort_end_date      <date> 1988-05-11, 1945-08-14, 1966-11-09, 1937-04-23, 2…

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
#> Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#> $ cohort_definition_id <int> 3, 2, 1, 2, 3, 1, 1, 3, 1, 3
#> $ subject_id           <int> 9, 6, 8, 3, 4, 1, 5, 10, 7, 2
#> $ cohort_start_date    <date> 1972-05-17, 1954-03-09, 1935-10-23, 1938-12-02, 1…
#> $ cohort_end_date      <date> 1988-05-11, 1966-11-09, 1937-04-23, 1941-11-19, 1…
#> $ cohort_1_minf_to_inf <date> 1980-05-05, 1967-03-31, 1916-11-14, 1919-01-09, …
```

Last occurrence:

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#> $ cohort_definition_id <int> 2, 3, 3, 2, 3, 2, 2, 1, 2, 3
#> $ subject_id           <int> 4, 10, 7, 1, 2, 9, 6, 3, 8, 5
#> $ cohort_start_date    <date> 1921-12-06, 1989-08-06, 1992-06-11, 1981-10-14, 1…
#> $ cohort_end_date      <date> 1928-08-03, 1995-01-24, 1997-09-11, 1982-11-12, 1…

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
#> Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#> $ cohort_definition_id <int> 2, 2, 1, 2, 3, 3, 2, 3, 2, 3
#> $ subject_id           <int> 9, 6, 3, 4, 10, 7, 1, 2, 8, 5
#> $ cohort_start_date    <date> 1969-11-14, 1938-04-30, 1983-05-27, 1921-12-06, 1…
#> $ cohort_end_date      <date> 1973-09-22, 1939-02-01, 1993-11-26, 1928-08-03, 1…
#> $ cohort_1_minf_to_inf <date> 1971-02-23, 1942-11-21, 1971-04-30, NA, NA, NA, …
```

#### Add the number of days instead of the date

Instead of returning a date, we could return the days to the
intersection by using `addCohortIntersectDays`

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#> $ cohort_definition_id <int> 3, 2, 2, 1, 1, 3, 1, 1, 2, 1
#> $ subject_id           <int> 1, 9, 5, 7, 4, 3, 2, 10, 6, 8
#> $ cohort_start_date    <date> 1966-12-06, 1955-09-03, 1963-11-24, 1995-11-30, 1…
#> $ cohort_end_date      <date> 1990-01-06, 1977-12-24, 1978-05-27, 1996-07-27, 2…

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
#> Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#> $ cohort_definition_id <int> 2, 1, 1, 3, 2, 1, 1, 3, 1, 2
#> $ subject_id           <int> 5, 2, 8, 1, 9, 7, 4, 3, 10, 6
#> $ cohort_start_date    <date> 1963-11-24, 1913-08-23, 1982-09-08, 1966-12-06, 1…
#> $ cohort_end_date      <date> 1978-05-27, 1914-08-12, 1991-06-28, 1990-01-06, 1…
#> $ cohort_1_minf_to_inf <dbl> 8809, 4412, -2029, NA, NA, NA, NA, NA, NA, NA
```

#### Combine multiple cohort intersects

If we want to combine multiple cohort intersects we can concatenate the
operations using the `pipe` operator:

``` r
cdm$cohort1 |>
  glimpse()
#> Rows: ??
#> Columns: 4
#> Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#> $ cohort_definition_id <int> 2, 1, 2, 3, 2, 3, 3, 2, 2, 3
#> $ subject_id           <int> 2, 4, 3, 7, 10, 1, 6, 8, 9, 5
#> $ cohort_start_date    <date> 1945-02-11, 1955-06-28, 1957-11-19, 1986-03-17, 1…
#> $ cohort_end_date      <date> 1980-06-10, 1962-08-23, 1958-05-22, 1992-08-12, 1…

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
#> Database: DuckDB v1.1.1 [martics@Windows 10 x64:R 4.2.1/:memory:]
#> $ cohort_definition_id <int> 2, 3, 2, 1, 2, 3, 2, 3, 3, 2
#> $ subject_id           <int> 8, 5, 2, 4, 3, 7, 10, 1, 6, 9
#> $ cohort_start_date    <date> 1972-02-17, 1944-11-17, 1945-02-11, 1955-06-28, 1…
#> $ cohort_end_date      <date> 1987-10-18, 1947-12-20, 1980-06-10, 1962-08-23, 1…
#> $ cohort_1_minf_to_inf <dbl> 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
```

``` r
mockDisconnect(cdm)
```
