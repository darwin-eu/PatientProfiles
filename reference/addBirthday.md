# Add the birth day of an individual to a table

**\[experimental\]**

The function accounts for leap years and corrects the invalid dates to
the next valid date.

## Usage

``` r
addBirthday(
  x,
  birthday = 0,
  birthdayName = "birthday",
  ageMissingMonth = 1L,
  ageMissingDay = 1L,
  ageImposeMonth = FALSE,
  ageImposeDay = FALSE,
  name = NULL
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- birthday:

  Number of birth day.

- birthdayName:

  Birth day variable name.

- ageMissingMonth:

  Month of the year assigned to individuals with missing month of birth.

- ageMissingDay:

  day of the month assigned to individuals with missing day of birth.

- ageImposeMonth:

  TRUE or FALSE. Whether the month of the date of birth will be
  considered as missing for all the individuals.

- ageImposeDay:

  TRUE or FALSE. Whether the day of the date of birth will be considered
  as missing for all the individuals.

- name:

  Name of the new table, if NULL a temporary table is returned.

## Value

The table with a new column containing the birth day.

## Examples

``` r
# \donttest{
library(PatientProfiles)
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union

cdm <- mockPatientProfiles(source = "duckdb")
#> Warning: There are observation period end dates after the current date: 2026-02-26
#> ℹ The latest max observation period end date found is 2028-05-24

cdm$cohort1 |>
  addBirthday() |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#> $ cohort_definition_id <int> 2, 2, 1, 2, 2, 2, 2, 2, 3, 2
#> $ subject_id           <int> 3, 4, 10, 8, 7, 6, 9, 1, 2, 5
#> $ cohort_start_date    <date> 1978-05-05, 2016-11-07, 1955-02-09, 1981-07-11, 1…
#> $ cohort_end_date      <date> 1978-11-11, 2021-12-22, 1978-05-15, 1987-10-05, 1…
#> $ birthday             <date> 1966-01-01, 1970-01-01, 1941-01-01, 1980-01-01, …

cdm$cohort1 |>
  addBirthday(birthday = 5, birthdayName = "bithday_5th") |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#> $ cohort_definition_id <int> 2, 2, 1, 2, 2, 2, 2, 2, 3, 2
#> $ subject_id           <int> 3, 4, 10, 8, 7, 6, 9, 1, 2, 5
#> $ cohort_start_date    <date> 1978-05-05, 2016-11-07, 1955-02-09, 1981-07-11, 1…
#> $ cohort_end_date      <date> 1978-11-11, 2021-12-22, 1978-05-15, 1987-10-05, 1…
#> $ bithday_5th          <date> 1971-01-01, 1975-01-01, 1946-01-01, 1985-01-01, …
# }
```
