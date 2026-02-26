# It creates column to indicate the flag overlap information between a table and a concept

It creates column to indicate the flag overlap information between a
table and a concept

## Usage

``` r
addConceptIntersectFlag(
  x,
  conceptSet,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  window = list(c(0, Inf)),
  targetStartDate = "event_start_date",
  targetEndDate = "event_end_date",
  inObservation = TRUE,
  nameStyle = "{concept_name}_{window_name}",
  name = NULL
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- conceptSet:

  Concept set list.

- indexDate:

  Variable in x that contains the date to compute the intersection.

- censorDate:

  whether to censor overlap events at a date column of x

- window:

  window to consider events in.

- targetStartDate:

  Event start date to use for the intersection.

- targetEndDate:

  Event end date to use for the intersection.

- inObservation:

  If TRUE only records inside an observation period will be considered.

- nameStyle:

  naming of the added column or columns, should include required
  parameters.

- name:

  Name of the new table, if NULL a temporary table is returned.

## Value

table with added columns with overlap information

## Examples

``` r
# \donttest{
library(PatientProfiles)
library(omopgenerics, warn.conflicts = TRUE)
library(dplyr, warn.conflicts = TRUE)

cdm <- mockPatientProfiles(source = "duckdb")

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
  addConceptIntersectFlag(conceptSet = list("acetaminophen" = 1125315))
#> Warning: ! `codelist` casted to integers.
#> # Source:   table<og_096_1772095318> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          7 1911-02-28        1911-11-21     
#>  2                    3          4 1951-04-20        1978-07-05     
#>  3                    1          6 1936-04-04        1938-07-17     
#>  4                    1          8 1932-09-05        1936-01-13     
#>  5                    2          5 1923-05-17        1924-11-29     
#>  6                    2          2 1956-04-29        1968-08-05     
#>  7                    3          1 1975-06-01        1977-07-12     
#>  8                    3         10 1977-07-17        1986-11-09     
#>  9                    2          3 1959-02-10        1959-10-18     
#> 10                    3          9 1971-07-20        1985-11-24     
#> # ℹ 1 more variable: acetaminophen_0_to_inf <dbl>

# }
```
