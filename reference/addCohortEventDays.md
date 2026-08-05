# Add the first or last cohort event and its relative days

`addCohortEventDays()` finds the first or last event in each window.
When no event is observed before the applicable boundary, the event is
reported as `"end_of_observation"` if the observation period boundary is
reached or `"censor"` if the window boundary or `censorDate` is reached.
The days value represents that boundary.

## Usage

``` r
addCohortEventDays(
  x,
  targetCohortTable,
  targetCohortId = NULL,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  targetDate = "cohort_start_date",
  order = "first",
  window = c(0, Inf),
  multipleEvents = NULL,
  nameStyle = "{value}_{window_name}",
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

- multipleEvents:

  How events occurring on the same date are handled. If `NULL`, the
  first event in the original event order is returned. If `TRUE`, all
  simultaneous event names are sorted alphabetically and joined with
  `"; "`. A character vector gives priority to the specified event
  names; the first matching name is returned, with unspecified names
  following in alphabetical order. Boundary labels (`"censor"` and
  `"end_of_observation"`) are never combined with event names.

- nameStyle:

  Naming pattern for the added columns. It must contain `{value}` and
  can also contain `{window_name}`.

- name:

  Name of the new table. If `NULL`, a temporary table is returned.

- type:

  Type of the created column(s). Counts, days, age, and observation
  durations can be `"numeric"` or `"integer"`. Flag columns can also be
  `"logical"`. Field columns can use `"auto"` to preserve the source
  type, or can be converted to `"numeric"`, `"integer"`, `"logical"`, or
  `"character"`.

## Value

`x` with an event column and a days column of the requested `type`,
relative to `indexDate`, for every window.

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
  addCohortEventDays(targetCohortTable = "cohort2")
#> # A query:  ?? x 6
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          1 1912-05-21        1917-04-16     
#>  2                    2          4 1945-07-27        1958-07-31     
#>  3                    3          7 1932-09-21        1936-01-21     
#>  4                    3         10 1913-03-22        1915-05-26     
#>  5                    1          2 2000-09-17        2009-10-11     
#>  6                    3          3 2000-03-10        2003-12-04     
#>  7                    2          5 1939-06-19        1958-04-11     
#>  8                    3          6 2011-08-30        2014-08-21     
#>  9                    1          8 1975-12-19        1984-10-08     
#> 10                    2          9 1960-12-29        1970-03-05     
#> # ℹ 2 more variables: event_0_to_inf <chr>, days_0_to_inf <dbl>
# }
```
