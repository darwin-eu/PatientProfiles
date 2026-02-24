# Intersecting the cohort with columns of an OMOP table of user's choice. It will add an extra column to the cohort, indicating the intersected entries with the target columns in a window of the user's choice.

Intersecting the cohort with columns of an OMOP table of user's choice.
It will add an extra column to the cohort, indicating the intersected
entries with the target columns in a window of the user's choice.

## Usage

``` r
addTableIntersectField(
  x,
  tableName,
  field,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  window = list(c(0, Inf)),
  targetDate = startDateColumn(tableName),
  inObservation = TRUE,
  order = "first",
  allowDuplicates = FALSE,
  nameStyle = "{table_name}_{extra_value}_{window_name}",
  name = NULL
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- tableName:

  Name of the table to intersect with. Options: visit_occurrence,
  condition_occurrence, drug_exposure, procedure_occurrence,
  device_exposure, measurement, observation, drug_era, condition_era,
  specimen, episode.

- field:

  The columns from the table in tableName to intersect over. For
  example, if the user uses visit_occurrence in tableName then for field
  the possible options include visit_occurrence_id, visit_concept_id,
  visit_type_concept_id.

- indexDate:

  Variable in x that contains the date to compute the intersection.

- censorDate:

  whether to censor overlap events at a specific date or a column date
  of x.

- window:

  window to consider events in when intersecting with the chosen column.

- targetDate:

  The dates in the target columns in tableName that the user may want to
  restrict to.

- inObservation:

  If TRUE only records inside an observation period will be considered.

- order:

  which record is considered in case of multiple records (only required
  for date and days options).

- allowDuplicates:

  Whether to allow multiple records with same conceptSet, person_id and
  targetDate. If switched to TRUE, the created new columns (field) will
  be collapsed to a character vector separated by \`;\` to account for
  multiple values per person.

- nameStyle:

  naming of the added column or columns, should include required
  parameters.

- name:

  Name of the new table, if NULL a temporary table is returned.

## Value

table with added columns with intersect information.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addTableIntersectField(
    tableName = "visit_occurrence",
    field = "visit_concept_id",
    order = "last",
    window = c(-Inf, -1)
  )
#> # Source:   table<og_147_1771938036> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          4 1960-04-20        1964-12-19     
#>  2                    1          9 1920-08-26        1936-03-26     
#>  3                    3          2 1978-09-30        1981-10-04     
#>  4                    3          1 1973-08-08        1974-03-29     
#>  5                    2          5 1915-08-25        1917-03-17     
#>  6                    1          3 1911-09-19        1920-11-05     
#>  7                    2         10 1975-11-07        1983-07-17     
#>  8                    2          7 1926-09-25        1932-09-23     
#>  9                    1          6 1969-08-26        1987-08-19     
#> 10                    2          8 1998-03-28        2003-11-12     
#> # ℹ 1 more variable: visit_occurrence_visit_concept_id_minf_to_m1 <int>

# }
```
