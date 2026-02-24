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
#> # Source:   table<og_084_1771937962> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          6 1960-09-22        1975-09-13     
#>  2                    2          2 1934-08-23        1940-04-10     
#>  3                    1          1 1957-08-20        1958-04-02     
#>  4                    3          4 1934-05-23        1940-07-15     
#>  5                    2         10 1988-02-29        1988-12-27     
#>  6                    2          8 1963-01-19        1965-02-06     
#>  7                    1          5 1979-08-23        1993-07-28     
#>  8                    1          9 1923-02-22        1933-07-27     
#>  9                    3          3 1962-06-03        1972-06-23     
#> 10                    2          7 1925-10-30        1929-06-12     
#> # ℹ 1 more variable: acetaminophen_0_to_inf <dbl>

# }
```
