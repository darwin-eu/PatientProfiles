# Compute the number of days till the end of the observation period at a certain date

Compute the number of days till the end of the observation period at a
certain date

## Usage

``` r
addFutureObservation(
  x,
  indexDate = "cohort_start_date",
  futureObservationName = "future_observation",
  futureObservationType = "days",
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

- futureObservationName:

  Name of the future-observation column to add.

- futureObservationType:

  Whether to return a `"date"` or a number of `"days"`.

- name:

  Name of the new table. If `NULL`, a temporary table is returned.

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
  addFutureObservation()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          9 1936-07-06        1940-10-20     
#>  2                    2          1 1947-01-15        1947-06-08     
#>  3                    2          8 1933-05-15        1944-10-06     
#>  4                    1          6 1990-11-01        1993-03-03     
#>  5                    3         10 1945-03-09        1965-08-24     
#>  6                    1          4 1910-11-05        1918-12-16     
#>  7                    2          2 1938-07-14        1943-10-06     
#>  8                    3          3 1983-12-15        1989-11-22     
#>  9                    3          7 1959-02-12        1964-07-29     
#> 10                    1          5 1949-10-19        1952-01-16     
#> # ℹ 1 more variable: future_observation <dbl>

# }
```
