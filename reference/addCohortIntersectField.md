# It creates a column with the field of a desired intersection

It creates a column with the field of a desired intersection

## Usage

``` r
addCohortIntersectField(
  x,
  targetCohortTable,
  field,
  targetCohortId = NULL,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  targetDate = "cohort_start_date",
  order = "first",
  window = list(c(0, Inf)),
  nameStyle = "{cohort_name}_{field}_{window_name}",
  name = NULL,
  type = "auto"
)
```

## Arguments

- x:

  A table containing individuals in a CDM reference.

- targetCohortTable:

  Name of the cohort table to intersect with.

- field:

  Name or names of columns in the target tables to add to `x`.

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

table with added columns with overlap information.

## Examples

``` r
# \donttest{
library(PatientProfiles)
library(dplyr)

cdm <- mockPatientProfiles(source = "duckdb")
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmpsAr3d4/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

cdm$cohort2 <- cdm$cohort2 |>
  mutate(even = if_else(subject_id %% 2, "yes", "no")) |>
  compute(name = "cohort2")

cdm$cohort1 |>
  addCohortIntersectFlag(
    targetCohortTable = "cohort2"
  )
#> # A query:  ?? x 7
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          6 1952-08-01        1965-06-15     
#>  2                    1          7 1912-04-22        1921-06-29     
#>  3                    1          3 1984-02-05        1985-10-29     
#>  4                    2          4 1988-09-20        1992-11-03     
#>  5                    3         10 1947-01-21        1947-04-18     
#>  6                    1          9 1950-08-14        1951-02-10     
#>  7                    1          5 1912-06-23        1920-04-13     
#>  8                    1          8 1982-12-10        1985-02-05     
#>  9                    3          2 1967-10-12        1975-01-21     
#> 10                    3          1 1922-07-04        1939-05-11     
#> # ℹ 3 more variables: cohort_2_0_to_inf <dbl>, cohort_1_0_to_inf <dbl>,
#> #   cohort_3_0_to_inf <dbl>

# }
```
