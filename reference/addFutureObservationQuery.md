# Query to add the number of days till the end of the observation period at a certain date

Same as
[`addFutureObservation()`](https://darwin-eu.github.io/PatientProfiles/reference/addFutureObservation.md),
except query is not computed to a table.

## Usage

``` r
addFutureObservationQuery(
  x,
  indexDate = "cohort_start_date",
  futureObservationName = "future_observation",
  futureObservationType = "days",
  type = "numeric"
)
```

## Arguments

- x:

  A table containing individuals in a CDM reference.

- indexDate:

  Name of a date column in `x`, or a single date to use for all rows,
  used as the reference date.

- futureObservationName:

  Name of the future-observation column to add.

- futureObservationType:

  Whether to return a `"date"` or a number of `"days"`.

- type:

  Type of the created column(s). Counts, days, age, and observation
  durations can be `"numeric"` or `"integer"`. Flag columns can also be
  `"logical"`. Field columns can use `"auto"` to preserve the source
  type, or can be converted to `"numeric"`, `"integer"`, `"logical"`, or
  `"character"`.

## Value

cohort table with added column containing future observation of the
individuals.

## Examples

``` r
# \donttest{
library(PatientProfiles)

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
  addFutureObservationQuery()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          1 1955-07-30        1963-08-28     
#>  2                    3          5 1940-07-18        1945-07-08     
#>  3                    3          2 1996-10-21        1997-12-27     
#>  4                    3          4 1962-03-18        1963-11-07     
#>  5                    3          8 1919-09-08        1922-02-06     
#>  6                    2          6 2005-10-12        2009-04-10     
#>  7                    3         10 1980-08-20        1985-04-01     
#>  8                    3          7 1999-08-14        2007-09-01     
#>  9                    3          3 1987-06-28        1989-10-30     
#> 10                    2          9 1979-12-13        1982-09-16     
#> # ℹ 1 more variable: future_observation <dbl>

# }
```
