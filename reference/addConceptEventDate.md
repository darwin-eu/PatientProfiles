# Add the first or last concept event and its date

`addConceptEventDate()` finds the first or last event from a set of
concepts in each window. When no event is observed before the applicable
boundary, the event is reported as `"end_of_observation"` if the
observation period boundary is reached or `"censor"` if the window
boundary or `censorDate` is reached. The date value represents that
boundary.

## Usage

``` r
addConceptEventDate(
  x,
  conceptSet,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  targetDate = "event_start_date",
  order = "first",
  window = list(c(0, Inf)),
  multipleEvents = NULL,
  nameStyle = "{value}_{window_name}",
  name = NULL
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
  addConceptEventDate(conceptSet = list(acetaminophen = 1125315L))
#> # A query:  ?? x 6
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          1 1923-02-07        1935-04-13     
#>  2                    3          2 1966-01-29        1969-01-24     
#>  3                    1          3 1933-03-09        1936-07-22     
#>  4                    1          4 1993-06-14        1994-11-07     
#>  5                    2          5 1913-12-20        1922-09-02     
#>  6                    1          6 1966-06-22        1974-02-14     
#>  7                    1          7 1946-05-09        1969-04-30     
#>  8                    2          8 1985-09-03        1999-12-08     
#>  9                    3          9 1965-07-21        2006-08-14     
#> 10                    1         10 1913-11-03        1914-12-07     
#> # ℹ 2 more variables: event_0_to_inf <chr>, date_0_to_inf <date>
# }
```
