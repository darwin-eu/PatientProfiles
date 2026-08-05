# Add the first or last cohort event and its date

`addCohortEventDate()` finds the first or last event in each window.
When no event is observed before the applicable boundary, the event is
reported as `"end_of_observation"` if the observation period boundary is
reached or `"censor"` if the window boundary or `censorDate` is reached.
The date value represents that boundary.

## Usage

``` r
addCohortEventDate(
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

## Value

`x` with an event column and a date column for every window.

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
  addCohortEventDate(targetCohortTable = "cohort2")
#> # A query:  ?? x 6
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          1 1963-10-14        1983-08-20     
#>  2                    3          2 1956-05-26        1974-04-28     
#>  3                    2          3 1920-11-03        1931-03-05     
#>  4                    3          5 1918-08-28        1925-09-26     
#>  5                    2          9 1938-08-01        1941-12-03     
#>  6                    1          4 2002-06-21        2009-08-10     
#>  7                    1          6 1935-02-03        1935-06-16     
#>  8                    3          7 1952-11-05        1955-12-21     
#>  9                    2          8 1949-02-05        1949-03-27     
#> 10                    3         10 1976-07-10        1984-02-08     
#> # ℹ 2 more variables: event_0_to_inf <chr>, date_0_to_inf <date>
# }
```
