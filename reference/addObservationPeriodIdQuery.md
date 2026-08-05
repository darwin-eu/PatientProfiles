# Add the ordinal number of the observation period associated that a given date is in. Result is not computed, only query is added.

Add the ordinal number of the observation period associated that a given
date is in. Result is not computed, only query is added.

## Usage

``` r
addObservationPeriodIdQuery(
  x,
  indexDate = "cohort_start_date",
  nameObservationPeriodId = "observation_period_id"
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

## Value

Table with the current observation period id added.

## Examples

``` r
# \donttest{
library(PatientProfiles)

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
  addObservationPeriodIdQuery()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          5 1958-08-21        1976-04-25     
#>  2                    1          1 1930-09-17        1934-04-13     
#>  3                    3          4 1967-02-28        1975-01-11     
#>  4                    2          2 1960-09-19        1974-04-09     
#>  5                    3          3 1964-05-28        1968-09-15     
#>  6                    3         10 1919-05-20        1919-10-03     
#>  7                    3          6 1997-08-24        2001-05-14     
#>  8                    2          8 1984-01-18        1984-08-17     
#>  9                    2          9 1926-12-23        1927-02-20     
#> 10                    2          7 1917-02-28        1920-01-05     
#> # ℹ 1 more variable: observation_period_id <int>

# }
```
