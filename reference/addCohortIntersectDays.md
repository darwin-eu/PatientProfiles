# It creates columns to indicate the number of days between the current table and a target cohort

It creates columns to indicate the number of days between the current
table and a target cohort

## Usage

``` r
addCohortIntersectDays(
  x,
  targetCohortTable,
  targetCohortId = NULL,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  targetDate = "cohort_start_date",
  order = "first",
  window = c(0, Inf),
  nameStyle = "{cohort_name}_{window_name}",
  name = NULL,
  type = "numeric"
)
```

## Arguments

- x:

  A table containing individuals in a CDM reference.

- targetCohortTable:

  Name of the cohort table to intersect with.

- targetCohortId:

  Cohort definition IDs to include from `targetCohortTable`. If `NULL`,
  all cohorts are included.

- indexDate:

  Name of a date column in `x`, or a single date to use for all rows,
  used as the reference date.

- censorDate:

  Date or name of a date column in `x` on which to censor follow-up. If
  `NULL`, no censoring is applied.

- targetDate:

  Name or names of date columns in the target tables to use for the
  intersection.

- order:

  Which record to use when multiple records occur in a window: `"first"`
  or `"last"`.

- window:

  Window or windows of time relative to `indexDate` to consider.

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

x along with additional columns for each cohort of interest.

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
  addCohortIntersectDays(targetCohortTable = "cohort2")
#> # A query:  ?? x 7
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          4 1946-02-11        1950-04-19     
#>  2                    1          2 1939-12-02        1944-11-22     
#>  3                    3          8 1981-08-20        1991-04-02     
#>  4                    2          6 1934-10-13        1936-10-10     
#>  5                    1          9 1928-12-06        1958-11-24     
#>  6                    1          1 1955-12-15        1973-02-28     
#>  7                    2          7 1950-01-24        1957-04-25     
#>  8                    2         10 1974-09-20        1975-07-16     
#>  9                    2          3 1949-09-27        1954-09-21     
#> 10                    2          5 1982-05-20        1982-08-14     
#> # ℹ 3 more variables: cohort_3_0_to_inf <dbl>, cohort_1_0_to_inf <dbl>,
#> #   cohort_2_0_to_inf <dbl>

# }
```
