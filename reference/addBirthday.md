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
  ageUnit = "years",
  name = NULL
)
```

## Arguments

- x:

  A table containing individuals in a CDM reference.

- birthday:

  Day of birth to add.

- birthdayName:

  Name of the birthday column to add.

- ageMissingMonth:

  Month of the year assigned when month of birth is missing.

- ageMissingDay:

  Day of the month assigned when day of birth is missing.

- ageImposeMonth:

  If `TRUE`, month of birth is treated as missing for all individuals.

- ageImposeDay:

  If `TRUE`, day of birth is treated as missing for all individuals.

- ageUnit:

  Unit in which to express age: `"years"`, `"months"`, or `"days"`.

- name:

  Name of the new table. If `NULL`, a temporary table is returned.

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
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmpsAr3d4/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

cdm$cohort1 |>
  addBirthday() |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> $ cohort_definition_id <int> 1, 3, 2, 3, 1, 1, 2, 1, 2, 3
#> $ subject_id           <int> 4, 1, 2, 6, 10, 7, 5, 8, 3, 9
#> $ cohort_start_date    <date> 1951-10-28, 1933-11-21, 1977-08-27, 1938-12-16, 1…
#> $ cohort_end_date      <date> 1954-06-19, 1942-01-09, 1992-06-07, 1943-04-30, 1…
#> $ birthday             <date> 1915-01-01, 1908-01-01, 1968-01-01, 1931-01-01, …

cdm$cohort1 |>
  addBirthday(birthday = 5, birthdayName = "bithday_5th") |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> $ cohort_definition_id <int> 1, 3, 2, 3, 1, 1, 2, 1, 2, 3
#> $ subject_id           <int> 4, 1, 2, 6, 10, 7, 5, 8, 3, 9
#> $ cohort_start_date    <date> 1951-10-28, 1933-11-21, 1977-08-27, 1938-12-16, 1…
#> $ cohort_end_date      <date> 1954-06-19, 1942-01-09, 1992-06-07, 1943-04-30, 1…
#> $ bithday_5th          <date> 1920-01-01, 1913-01-01, 1973-01-01, 1936-01-01, …
# }
```
