# Query to add the number of days of prior observation in the current observation period at a certain date

Same as
[`addPriorObservation()`](https://darwin-eu.github.io/PatientProfiles/reference/addPriorObservation.md),
except query is not computed to a table.

## Usage

``` r
addPriorObservationQuery(
  x,
  indexDate = "cohort_start_date",
  priorObservationName = "prior_observation",
  priorObservationType = "days",
  type = "numeric"
)
```

## Arguments

- x:

  A table containing individuals in a CDM reference.

- indexDate:

  Name of a date column in `x`, or a single date to use for all rows,
  used as the reference date.

- priorObservationName:

  Name of the prior-observation column to add.

- priorObservationType:

  Whether to return a `"date"` or a number of `"days"`.

- type:

  Type of the created column(s). Counts, days, age, and observation
  durations can be `"numeric"` or `"integer"`. Flag columns can also be
  `"logical"`. Field columns can use `"auto"` to preserve the source
  type, or can be converted to `"numeric"`, `"integer"`, `"logical"`, or
  `"character"`.

## Value

cohort table with added column containing prior observation of the
individuals.

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
  addPriorObservationQuery()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          7 1963-01-05        1963-07-17     
#>  2                    2          4 1919-05-03        1922-08-24     
#>  3                    3          9 1919-07-04        1925-08-19     
#>  4                    3          2 1956-05-24        1959-04-28     
#>  5                    2          6 1976-10-21        1993-11-06     
#>  6                    3          1 1917-12-16        1922-03-17     
#>  7                    2         10 1933-09-07        1960-10-21     
#>  8                    2          3 1926-08-09        1938-04-17     
#>  9                    2          8 1941-01-25        1953-06-30     
#> 10                    1          5 1915-12-01        1916-06-06     
#> # ℹ 1 more variable: prior_observation <dbl>

# }
```
