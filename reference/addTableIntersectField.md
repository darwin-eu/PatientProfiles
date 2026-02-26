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
  nameStyle = "{table_name}_{field}_{window_name}",
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
  be collapsed to a character vector separated by `;` to account for
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
#> # Source:   table<og_159_1772095782> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          3 1953-10-11        1960-01-02     
#>  2                    2         10 1943-12-12        1945-04-18     
#>  3                    1          7 1998-06-21        2015-11-30     
#>  4                    3          5 1939-05-06        1947-12-22     
#>  5                    1          8 1932-04-07        1932-06-25     
#>  6                    3          4 1995-10-08        1998-12-20     
#>  7                    1          1 1961-02-13        1986-05-15     
#>  8                    1          2 1961-02-03        1962-08-30     
#>  9                    2          6 1970-12-18        1984-07-16     
#> 10                    2          9 1969-08-19        1970-09-01     
#> # ℹ 1 more variable: visit_occurrence_visit_concept_id_minf_to_m1 <int>

# }
```
