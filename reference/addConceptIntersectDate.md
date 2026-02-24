# It creates column to indicate the date overlap information between a table and a concept

It creates column to indicate the date overlap information between a
table and a concept

## Usage

``` r
addConceptIntersectDate(
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
  addConceptIntersectDate(conceptSet = list("acetaminophen" = 1125315))
#> Warning: ! `codelist` casted to integers.
#> # Source:   table<og_054_1771937950> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          6 1958-10-23        1964-02-11     
#>  2                    1          7 1931-05-18        1957-09-03     
#>  3                    1          5 1949-10-04        1951-10-06     
#>  4                    2          8 1966-03-29        1970-05-20     
#>  5                    3         10 1923-03-21        1928-04-24     
#>  6                    3          2 1961-10-22        1964-02-03     
#>  7                    2          1 1959-04-06        1974-03-25     
#>  8                    3          4 1915-04-26        1932-08-19     
#>  9                    3          3 1987-10-06        1993-09-06     
#> 10                    2          9 1949-10-02        1950-05-06     
#> # ℹ 1 more variable: acetaminophen_0_to_inf <date>

# }
```
