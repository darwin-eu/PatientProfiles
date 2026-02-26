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
#> # Source:   table<og_066_1772095306> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1         10 1962-11-18        1989-03-27     
#>  2                    3          6 2005-05-03        2011-12-07     
#>  3                    3          9 1994-10-05        1998-02-12     
#>  4                    1          3 1924-03-30        1955-11-14     
#>  5                    3          5 1962-07-11        1966-03-21     
#>  6                    3          1 1944-03-18        1944-07-16     
#>  7                    2          4 1923-01-14        1926-01-07     
#>  8                    2          8 2014-09-29        2016-07-04     
#>  9                    2          7 1957-06-27        1965-08-08     
#> 10                    3          2 1916-10-01        1923-06-12     
#> # ℹ 1 more variable: acetaminophen_0_to_inf <date>

# }
```
