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

- targetDate:

  Event date to use for the intersection.

- order:

  last or first date to use for date/days calculations.

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
  addConceptIntersectDays(conceptSet = list("acetaminophen" = 1125315))
#> Warning: ! `codelist` casted to integers.
#> # Source:   table<og_064_1771936201> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          8 1939-12-05        1956-09-11     
#>  2                    1          1 1971-10-28        1973-03-11     
#>  3                    3          9 2014-06-07        2015-10-11     
#>  4                    3          6 1917-04-27        1932-08-27     
#>  5                    2          2 1934-10-21        1947-04-20     
#>  6                    1          7 1935-06-23        1959-03-27     
#>  7                    3         10 1994-03-24        1996-04-16     
#>  8                    1          5 1961-02-25        1963-06-03     
#>  9                    1          3 2000-02-21        2001-01-18     
#> 10                    1          4 1951-07-01        1951-10-05     
#> # ℹ 1 more variable: acetaminophen_0_to_inf <dbl>

# }
```
