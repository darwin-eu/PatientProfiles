# Indicate if a certain record is within the observation period

Indicate if a certain record is within the observation period

## Usage

``` r
addInObservation(
  x,
  indexDate = "cohort_start_date",
  window = c(0, 0),
  completeInterval = FALSE,
  nameStyle = "in_observation",
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

- window:

  Window or windows of time relative to `indexDate` to consider.

- completeInterval:

  If `TRUE`, individuals must be observed for the full requested
  interval.

- nameStyle:

  Naming pattern for the added column or columns. It should include the
  required formatting variables. If more than one `tableName` is
  provided, it must include `{table_name}`.

- name:

  Name of the new table. If `NULL`, a temporary table is returned.

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
#> ℹ /tmp/RtmpIdk5b4/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

cdm$cohort1 |>
  addInObservation()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1         10 1913-11-03        1914-02-14     
#>  2                    3          7 1960-09-05        1961-11-29     
#>  3                    1          3 1936-06-17        1968-11-04     
#>  4                    3          2 1961-11-05        1968-06-22     
#>  5                    1          8 1931-03-08        1940-07-08     
#>  6                    3          6 1955-09-15        1956-05-02     
#>  7                    3          1 1912-06-23        1915-11-18     
#>  8                    1          5 1980-07-11        1981-10-29     
#>  9                    1          9 1932-10-20        1935-07-22     
#> 10                    2          4 1980-09-14        1997-09-25     
#> # ℹ 1 more variable: in_observation <dbl>

# }
```
