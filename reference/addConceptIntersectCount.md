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
#> 
#> Attaching package: ‘omopgenerics’
#> The following object is masked from ‘package:stats’:
#> 
#>     filter
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
  addConceptIntersectCount(conceptSet = list("acetaminophen" = 1125315))
#> Warning: ! `codelist` casted to integers.
#> # Source:   table<og_052_1772095302> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          6 1916-04-03        1919-05-03     
#>  2                    2          8 1918-11-18        1920-01-17     
#>  3                    3          1 1989-03-10        1993-09-30     
#>  4                    1          2 1961-01-16        1961-02-20     
#>  5                    1          7 1931-10-23        1932-09-18     
#>  6                    2          9 1983-08-27        1984-03-18     
#>  7                    3          5 1937-09-24        1946-02-19     
#>  8                    3          4 1942-08-03        1955-12-21     
#>  9                    2          3 2009-03-11        2011-11-12     
#> 10                    3         10 1975-09-12        1986-10-10     
#> # ℹ 1 more variable: acetaminophen_0_to_inf <dbl>

# }
```
