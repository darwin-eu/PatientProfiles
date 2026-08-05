# Query to add a new column to indicate if a certain record is within the observation period

Same as
[`addInObservation()`](https://darwin-eu.github.io/PatientProfiles/reference/addInObservation.md),
except query is not computed to a table.

## Usage

``` r
addInObservationQuery(
  x,
  indexDate = "cohort_start_date",
  window = c(0, 0),
  completeInterval = FALSE,
  nameStyle = "in_observation",
  type = "numeric"
)
```

## Arguments

- x:

  A table containing individuals in a CDM reference.

- indexDate:

  Name of a date column in `x`, or a single date to use for all rows,
  used as the reference date.

- window:

  Window or windows of time relative to `indexDate` to consider.

- completeInterval:

  If `TRUE`, individuals must be observed for the full requested
  interval.

- nameStyle:

  Naming pattern for the added column or columns. It should include the
  required formatting variables. If more than one `tableName` is
  provided, it must include `{table_name}`.

- type:

  Type of the created column(s). Counts, days, age, and observation
  durations can be `"numeric"` or `"integer"`. Flag columns can also be
  `"logical"`. Field columns can use `"auto"` to preserve the source
  type, or can be converted to `"numeric"`, `"integer"`, `"logical"`, or
  `"character"`.

## Value

Cohort table with an added column assessing observation. Values are
1/`TRUE` in observation and 0/`FALSE` otherwise, according to `type`.

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
  addInObservationQuery()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          3 1923-03-19        1923-06-18     
#>  2                    3          7 1977-11-14        1978-08-22     
#>  3                    2         10 1931-09-26        1933-12-27     
#>  4                    3          5 1978-10-26        1980-02-20     
#>  5                    1          6 1968-03-14        1970-03-18     
#>  6                    1          9 1929-11-15        1931-05-08     
#>  7                    1          1 1988-09-06        1991-09-16     
#>  8                    2          4 1978-09-28        1981-10-24     
#>  9                    1          8 1975-02-26        1976-04-03     
#> 10                    1          2 1964-12-04        1970-02-24     
#> # ℹ 1 more variable: in_observation <dbl>

# }
```
