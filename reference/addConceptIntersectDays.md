# It creates column to indicate the days of difference from an index date to a concept

It creates column to indicate the days of difference from an index date
to a concept

## Usage

``` r
addConceptIntersectDays(
  x,
  conceptSet,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  window = list(c(0, Inf)),
  targetDate = "event_start_date",
  order = "first",
  inObservation = TRUE,
  nameStyle = "{concept_name}_{window_name}",
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

- window:

  Window or windows of time relative to `indexDate` to consider.

- targetDate:

  Name or names of date columns in the target tables to use for the
  intersection.

- order:

  Which record to use when multiple records occur in a window: `"first"`
  or `"last"`.

- inObservation:

  If `TRUE`, only records that occur during an observation period are
  considered.

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

table with added columns with overlap information

## Examples

``` r
# \donttest{
library(PatientProfiles)
library(omopgenerics, warn.conflicts = TRUE)
library(dplyr, warn.conflicts = TRUE)

cdm <- mockPatientProfiles(source = "duckdb")
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/Rtmp52x3ty/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

concept <- tibble(
  concept_id = c(1125315),
  domain_id = "Drug",
  vocabulary_id = NA_character_,
  concept_class_id = "Ingredient",
  standard_concept = "S",
  concept_code = NA_character_,
  valid_start_date = as.Date("1900-01-01"),
  valid_end_date = as.Date("2099-01-01"),
  invalid_reason = NA_character_
) |>
  mutate(concept_name = paste0("concept: ", .data$concept_id))
cdm <- insertTable(cdm, "concept", concept)

cdm$cohort1 |>
  addConceptIntersectDays(conceptSet = list("acetaminophen" = 1125315))
#> Warning: ! `codelist` cast to integers.
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1022-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          8 2009-02-21        2012-03-07     
#>  2                    1          4 1922-10-07        1929-08-19     
#>  3                    1          3 1989-02-28        1995-07-03     
#>  4                    1          1 1955-12-26        1966-10-21     
#>  5                    3         10 1930-08-26        1930-11-04     
#>  6                    3          9 1950-08-19        1955-12-25     
#>  7                    1          7 1928-03-18        1929-03-18     
#>  8                    1          2 1961-07-27        1969-04-22     
#>  9                    1          5 1967-11-07        1980-05-01     
#> 10                    1          6 1940-05-31        1943-08-06     
#> # ℹ 1 more variable: acetaminophen_0_to_inf <dbl>

# }
```
