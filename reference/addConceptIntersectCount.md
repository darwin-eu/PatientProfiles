# It creates column to indicate the count overlap information between a table and a concept

It creates column to indicate the count overlap information between a
table and a concept

## Usage

``` r
addConceptIntersectCount(
  x,
  conceptSet,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  window = list(c(0, Inf)),
  targetStartDate = "event_start_date",
  targetEndDate = "event_end_date",
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

- targetStartDate:

  Name or names of start-date columns in the target tables to use for
  the intersection.

- targetEndDate:

  Name or names of end-date columns in the target tables to use for the
  intersection. If `NULL`, the target is treated as a point event.

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

The original table (`x`) with one added column per intersection with the
desired conceptSet in a specific window. One column will be created for
each combination of window and conceptSet. The value of the column will
be the number of intersections in the desired window, or NA if the
individual is not in observation at any time in the window.

## Examples

``` r
# \donttest{
library(PatientProfiles)
library(omopgenerics, warn.conflicts = TRUE)
#> 
#> Attaching package: ‘omopgenerics’
#> The following object is masked from ‘package:stats’:
#> 
#>     filter
library(dplyr, warn.conflicts = TRUE)

cdm <- mockPatientProfiles(source = "duckdb")
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmpIdk5b4/duckdb
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
  addConceptIntersectCount(conceptSet = list("acetaminophen" = 1125315))
#> Warning: ! `codelist` cast to integers.
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          5 1990-01-13        1994-07-10     
#>  2                    1          2 1917-11-19        1936-01-02     
#>  3                    3          3 1928-07-01        1938-05-16     
#>  4                    3          4 1942-04-24        1947-02-19     
#>  5                    1          7 1966-12-31        1972-04-12     
#>  6                    1          8 1970-07-02        2006-11-30     
#>  7                    1          6 1976-05-08        1978-04-16     
#>  8                    3         10 1952-08-19        1967-06-25     
#>  9                    3          1 2011-07-05        2013-07-21     
#> 10                    1          9 1969-11-23        1972-03-07     
#> # ℹ 1 more variable: acetaminophen_0_to_inf <dbl>

# }
```
