# Date of cohorts that are present in a certain window

Date of cohorts that are present in a certain window

## Usage

``` r
addCohortIntersectDate(
  x,
  targetCohortTable,
  targetCohortId = NULL,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  targetDate = "cohort_start_date",
  order = "first",
  window = c(0, Inf),
  nameStyle = "{cohort_name}_{window_name}",
  name = NULL
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
  addCohortIntersectDate(targetCohortTable = "cohort2")
#> # A query:  ?? x 7
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          1 1951-12-16        1954-09-06     
#>  2                    2          8 1946-09-01        1950-10-25     
#>  3                    3          9 1957-08-30        1972-08-31     
#>  4                    1          2 1928-02-18        1931-10-29     
#>  5                    1          5 1955-02-12        1955-09-22     
#>  6                    3         10 1936-06-03        1949-02-04     
#>  7                    3          3 1908-01-07        1915-02-01     
#>  8                    3          6 1926-12-19        1933-10-06     
#>  9                    1          7 1934-12-19        1936-04-05     
#> 10                    2          4 1932-07-31        1949-04-05     
#> # ℹ 3 more variables: cohort_2_0_to_inf <date>, cohort_3_0_to_inf <date>,
#> #   cohort_1_0_to_inf <date>

# }
```
