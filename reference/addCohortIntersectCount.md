# It creates columns to indicate number of occurrences of intersection with a cohort

It creates columns to indicate number of occurrences of intersection
with a cohort

## Usage

``` r
addCohortIntersectCount(
  x,
  targetCohortTable,
  targetCohortId = NULL,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  targetStartDate = "cohort_start_date",
  targetEndDate = "cohort_end_date",
  window = list(c(0, Inf)),
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

- targetStartDate:

  Name or names of start-date columns in the target tables to use for
  the intersection.

- targetEndDate:

  Name or names of end-date columns in the target tables to use for the
  intersection. If `NULL`, the target is treated as a point event.

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

The original table (`x`) with one added column per intersection with the
desired cohort in a specific window. One column will be created for each
combination of window and cohort. The value of the column will be the
number of intersections in the desired window, or NA if the individual
is not in observation at any time in the window.

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
  addCohortIntersectCount(
    targetCohortTable = "cohort2"
  )
#> # A query:  ?? x 7
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          6 1961-01-31        1963-06-20     
#>  2                    3          1 1950-11-13        1981-02-01     
#>  3                    2          3 1931-10-01        1934-10-04     
#>  4                    2          8 1963-07-30        1971-04-14     
#>  5                    2          2 1983-03-19        1987-01-13     
#>  6                    1          5 1957-07-15        1967-11-01     
#>  7                    2          9 1987-11-11        1994-04-11     
#>  8                    3         10 1940-10-26        1941-11-22     
#>  9                    3          7 2000-07-11        2006-04-02     
#> 10                    3          4 1964-02-07        1964-11-01     
#> # ℹ 3 more variables: cohort_1_0_to_inf <dbl>, cohort_2_0_to_inf <dbl>,
#> #   cohort_3_0_to_inf <dbl>

# }
```
