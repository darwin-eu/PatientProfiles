# Add the birth day of an individual to a table

**\[experimental\]** Same as
[`addBirthday()`](https://darwin-eu.github.io/PatientProfiles/reference/addBirthday.md),
except query is not computed to a table.

The function accounts for leap years and corrects the invalid dates to
the next valid date.

## Usage

``` r
addBirthdayQuery(
  x,
  birthdayName = "birthday",
  birthday = 0,
  ageMissingMonth = 1,
  ageMissingDay = 1,
  ageImposeMonth = FALSE,
  ageImposeDay = FALSE,
  ageUnit = "years"
)
```

## Arguments

- x:

  A table containing individuals in a CDM reference.

- birthdayName:

  Name of the birthday column to add.

- birthday:

  Day of birth to add.

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

## Value

The table with a query that add the new column containing the birth day.

## Examples

``` r
# \donttest{
library(PatientProfiles)
library(dplyr)

cdm <- mockPatientProfiles(source = "duckdb")
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmpIdk5b4/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

cdm$cohort1 |>
  addBirthdayQuery() |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> $ cohort_definition_id <int> 1, 2, 1, 3, 3, 3, 2, 2, 2, 2
#> $ subject_id           <int> 7, 2, 6, 1, 5, 4, 3, 10, 8, 9
#> $ cohort_start_date    <date> 1946-06-19, 1936-05-24, 1944-02-21, 1955-11-25, 1…
#> $ cohort_end_date      <date> 1975-09-23, 1945-12-27, 1961-09-26, 1972-09-09, 1…
#> $ birthday             <date> 1925-01-01, 1929-01-01, 1927-01-01, 1953-01-01, …

cdm$cohort1 |>
  addBirthdayQuery(birthday = 5) |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> $ cohort_definition_id <int> 1, 2, 1, 3, 3, 3, 2, 2, 2, 2
#> $ subject_id           <int> 7, 2, 6, 1, 5, 4, 3, 10, 8, 9
#> $ cohort_start_date    <date> 1946-06-19, 1936-05-24, 1944-02-21, 1955-11-25, 1…
#> $ cohort_end_date      <date> 1975-09-23, 1945-12-27, 1961-09-26, 1972-09-09, 1…
#> $ birthday             <date> 1930-01-01, 1934-01-01, 1932-01-01, 1958-01-01, …
# }
```
