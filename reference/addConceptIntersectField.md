# It adds a custom column (field) from the intersection with a certain table subsetted by concept id. In general it is used to add the first value of a certain measurement.

It adds a custom column (field) from the intersection with a certain
table subsetted by concept id. In general it is used to add the first
value of a certain measurement.

## Usage

``` r
addConceptIntersectField(
  x,
  conceptSet,
  field,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  window = list(c(0, Inf)),
  targetDate = "event_start_date",
  order = "first",
  inObservation = TRUE,
  allowDuplicates = FALSE,
  nameStyle = "{field}_{concept_name}_{window_name}",
  name = NULL
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- conceptSet:

  Concept set list.

- field:

  Column in the standard omop table that you want to add.

- indexDate:

  Variable in x that contains the date to compute the intersection.

- censorDate:

  Whether to censor overlap events at a date column of x

- window:

  Window to consider events in.

- targetDate:

  Event date to use for the intersection.

- order:

  'last' or 'first' to refer to which event consider if multiple events
  are present in the same window.

- inObservation:

  If TRUE only records inside an observation period will be considered.

- allowDuplicates:

  Whether to allow multiple records with same conceptSet, person_id and
  targetDate. If switched to TRUE, the created new columns (field) will
  be collapsed to a character vector separated by `;` to account for
  multiple values per person.

- nameStyle:

  naming of the added column or columns, should include required
  parameters.

- name:

  Name of the new table, if NULL a temporary table is returned.

## Value

Table with the `field` value obtained from the intersection

## Examples

``` r
# \donttest{
library(PatientProfiles)
library(omopgenerics, warn.conflicts = TRUE)
library(dplyr, warn.conflicts = TRUE)

cdm <- mockPatientProfiles(source = "duckdb")
#> Warning: There are observation period end dates after the current date: 2026-02-26
#> ℹ The latest max observation period end date found is 2027-03-20

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
  addConceptIntersectField(
    conceptSet = list("acetaminophen" = 1125315),
    field = "drug_type_concept_id"
  )
#> Warning: ! `codelist` casted to integers.
#> # Source:   table<og_086_1772095314> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          6 1944-07-23        1960-02-06     
#>  2                    3          3 1982-12-22        2002-10-29     
#>  3                    3          5 1978-03-01        1979-03-08     
#>  4                    2          8 1980-05-04        1981-10-24     
#>  5                    2          9 1961-12-03        1969-03-24     
#>  6                    3          4 1933-01-12        1957-09-19     
#>  7                    2          7 1936-01-13        1942-04-30     
#>  8                    2          2 1937-01-13        1939-06-17     
#>  9                    2         10 1983-10-26        1995-10-25     
#> 10                    2          1 1938-10-12        1956-08-24     
#> # ℹ 1 more variable: drug_type_concept_id_acetaminophen_0_to_inf <chr>

# }
```
