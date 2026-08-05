# It creates columns to indicate the presence of cohorts

It creates columns to indicate the presence of cohorts

## Usage

``` r
addCohortIntersectFlag(
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
combination of window and cohort. The value of the column can either
indicate presence (1 or TRUE), no intersection (0 or FALSE), or NA if
the individual is not in observation at any time of the window. The
representation depends on `type`.

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
  addCohortIntersectFlag(
    targetCohortTable = "cohort2"
  )
#> # A query:  ?? x 6
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          7 1938-09-01        1952-03-30     
#>  2                    3          9 1941-09-21        1960-05-18     
#>  3                    1          5 1955-01-14        1967-05-07     
#>  4                    2          2 1992-05-16        1992-08-08     
#>  5                    1          8 1925-05-30        1937-10-19     
#>  6                    1          3 1929-09-09        1959-02-19     
#>  7                    3          4 1944-03-02        1951-03-01     
#>  8                    2          6 1943-05-01        1945-10-10     
#>  9                    1         10 1957-09-19        1961-02-19     
#> 10                    3          1 1925-07-05        1930-02-27     
#> # ℹ 2 more variables: cohort_1_0_to_inf <dbl>, cohort_2_0_to_inf <dbl>

# }
```
