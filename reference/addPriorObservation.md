# Compute the number of days of prior observation in the current observation period at a certain date

Compute the number of days of prior observation in the current
observation period at a certain date

## Usage

``` r
addPriorObservation(
  x,
  indexDate = "cohort_start_date",
  priorObservationName = "prior_observation",
  priorObservationType = "days",
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

- priorObservationName:

  Name of the prior-observation column to add.

- priorObservationType:

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

cohort table with added column containing prior observation of the
individuals.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmpSvnpxc/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

cdm$cohort1 |>
  addPriorObservation()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          2 1985-06-26        1986-05-26     
#>  2                    2         10 1947-06-26        1948-08-14     
#>  3                    2          4 1935-04-30        1948-10-13     
#>  4                    1          5 1942-07-28        1943-02-10     
#>  5                    2          7 1952-11-23        1973-04-15     
#>  6                    3          8 1982-11-16        1985-09-05     
#>  7                    1          3 1931-08-03        1932-08-01     
#>  8                    1          9 1954-03-30        1962-01-28     
#>  9                    1          6 1957-09-06        1960-04-02     
#> 10                    3          1 1992-05-24        1999-05-23     
#> # ℹ 1 more variable: prior_observation <dbl>

# }
```
