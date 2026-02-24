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
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union

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
#> # Source:   table<og_040_1771936193> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          1 1977-03-30        1979-05-26     
#>  2                    1          9 1980-01-08        2001-05-31     
#>  3                    3          6 1967-12-22        1974-01-10     
#>  4                    1          5 1941-06-11        1944-03-19     
#>  5                    1          7 1955-11-04        1958-10-11     
#>  6                    3          3 1965-05-01        1977-08-18     
#>  7                    3          2 1970-03-06        1998-04-24     
#>  8                    1          8 1918-08-03        1925-01-19     
#>  9                    1          4 1969-01-27        1990-07-08     
#> 10                    2         10 1940-01-23        1942-06-15     
#> # ℹ 1 more variable: acetaminophen_0_to_inf <dbl>

# }
```
