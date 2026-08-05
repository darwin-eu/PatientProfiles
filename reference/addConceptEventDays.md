# Add the first or last concept event and its relative days

`addConceptEventDays()` finds the first or last event from a set of
concepts in each window. When no event is observed before the applicable
boundary, the event is reported as `"end_of_observation"` if the
observation period boundary is reached or `"censor"` if the window
boundary or `censorDate` is reached. The days value represents that
boundary.

## Usage

``` r
addConceptEventDays(
  x,
  conceptSet,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  targetDate = "event_start_date",
  order = "first",
  window = list(c(0, Inf)),
  multipleEvents = NULL,
  nameStyle = "{value}_{window_name}",
  name = NULL,
  type = "numeric"
)
```

## Arguments

- x:

  A table containing individuals in a CDM reference.

- conceptSet:

  A named list of concept sets.

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
#> ℹ /tmp/RtmpSvnpxc/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

cdm$cohort1 |>
  addConceptEventDays(conceptSet = list(acetaminophen = 1125315L))
#> # A query:  ?? x 6
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          1 1944-01-18        1944-12-12     
#>  2                    2          2 1977-05-31        1986-08-31     
#>  3                    3          3 1973-10-24        1975-07-20     
#>  4                    2          4 1933-07-30        1938-09-17     
#>  5                    2          5 1978-05-14        2001-06-28     
#>  6                    2          6 1912-12-21        1936-03-30     
#>  7                    1          7 1959-03-14        1962-05-03     
#>  8                    2          8 1986-03-10        1986-04-30     
#>  9                    2          9 1979-03-11        1983-09-14     
#> 10                    2         10 1985-05-23        1997-11-03     
#> # ℹ 2 more variables: event_0_to_inf <chr>, days_0_to_inf <dbl>
# }
```
