# Add the ordinal number of the observation period associated that a given date is in.

Add the ordinal number of the observation period associated that a given
date is in.

## Usage

``` r
addObservationPeriodId(
  x,
  indexDate = "cohort_start_date",
  nameObservationPeriodId = "observation_period_id",
  name = NULL
)
```

## Arguments

- x:

  A table containing individuals in a CDM reference.

- indexDate:

  Name of a date column in `x`, or a single date to use for all rows,
  used as the reference date.

- nameObservationPeriodId:

  Name of the observation-period ID column to add.

- name:

  Name of the new table. If `NULL`, a temporary table is returned.

## Value

Table with the current observation period id added.

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
  addObservationPeriodId()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          3 1970-07-27        1984-01-24     
#>  2                    1         10 1978-09-09        1979-02-25     
#>  3                    2          8 1910-05-01        1912-05-01     
#>  4                    1          5 1987-09-17        1998-10-12     
#>  5                    3          9 1918-08-10        1923-08-09     
#>  6                    2          4 1906-05-13        1933-08-24     
#>  7                    2          6 1905-03-03        1912-02-17     
#>  8                    1          7 1958-03-03        1959-03-24     
#>  9                    1          1 1948-09-11        1949-01-09     
#> 10                    3          2 1919-03-11        1937-12-29     
#> # ℹ 1 more variable: observation_period_id <int>

# }
```
