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
#> # Source:   table<og_076_1772095310> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          9 1992-01-24        1992-05-08     
#>  2                    1          5 1980-12-13        1982-04-28     
#>  3                    1          6 1982-08-21        1992-03-07     
#>  4                    1          2 1959-07-22        1972-08-26     
#>  5                    1          7 1972-05-22        1980-07-04     
#>  6                    1          1 1914-01-06        1914-07-07     
#>  7                    2         10 1916-06-24        1917-07-12     
#>  8                    3          8 1965-02-01        1965-05-24     
#>  9                    2          3 1919-08-02        1931-04-26     
#> 10                    1          4 1915-04-14        1919-07-19     
#> # ℹ 1 more variable: acetaminophen_0_to_inf <dbl>

# }
```
