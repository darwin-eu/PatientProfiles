# Compute the age of the individuals at a certain date

Compute the age of the individuals at a certain date

## Usage

``` r
addAge(
  x,
  indexDate = "cohort_start_date",
  ageName = "age",
  ageGroup = NULL,
  ageMissingMonth = 1,
  ageMissingDay = 1,
  ageImposeMonth = FALSE,
  ageImposeDay = FALSE,
  ageUnit = "years",
  missingAgeGroupValue = "None",
  name = NULL,
  type = "numeric"
)
```

## Arguments

- x:

  A table containing individuals in a CDM reference.

- indexDate:

  Name of a date column in `x`, or a single date to use for all rows,
  used as the reference date.

- ageName:

  Name of the age column to add.

- ageGroup:

  If not `NULL`, a list of age-group vectors.

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

- missingAgeGroupValue:

  Value to use when age is missing.

- name:

  Name of the new table. If `NULL`, a temporary table is returned.

- type:

  Type of the created column(s). Counts, days, age, and observation
  durations can be `"numeric"` or `"integer"`. Flag columns can also be
  `"logical"`. Field columns can use `"auto"` to preserve the source
  type, or can be converted to `"numeric"`, `"integer"`, `"logical"`, or
  `"character"`.

## Value

tibble with the age column added.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmpB2T0r9/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

cdm$cohort1 |>
  addAge()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date   age
#>                   <int>      <int> <date>            <date>          <dbl>
#>  1                    2          4 1962-01-27        1987-07-17          7
#>  2                    3          2 1907-02-25        1908-05-30          5
#>  3                    2          5 1949-06-14        1951-09-10          6
#>  4                    1          8 1936-04-16        1953-07-04         31
#>  5                    2          6 1980-08-13        1987-10-18         18
#>  6                    3          3 1971-12-14        1983-12-15          9
#>  7                    1          1 1983-08-01        2010-02-24          6
#>  8                    3          9 1946-11-14        1963-10-27          2
#>  9                    2          7 1966-01-28        1969-07-08         23
#> 10                    3         10 1994-05-21        1995-06-26         33

# }
```
