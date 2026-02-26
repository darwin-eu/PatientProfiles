# Compute number of intersect with an omop table.

Compute number of intersect with an omop table.

## Usage

``` r
addTableIntersectCount(
  x,
  tableName,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  window = list(c(0, Inf)),
  targetStartDate = startDateColumn(tableName),
  targetEndDate = endDateColumn(tableName),
  inObservation = TRUE,
  nameStyle = "{table_name}_{window_name}",
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

- indexDate:

  Variable in x that contains the date to compute the intersection.

- censorDate:

  whether to censor overlap events at a specific date or a column date
  of x.

- window:

  window to consider events in.

- targetStartDate:

  Column name with start date for comparison.

- targetEndDate:

  Column name with end date for comparison.

- inObservation:

  If TRUE only records inside an observation period will be considered.

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
  addTableIntersectCount(tableName = "visit_occurrence")
#> # Source:   table<og_140_1772095772> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          8 1928-10-05        1939-12-22     
#>  2                    1          3 1971-10-30        1993-11-28     
#>  3                    1          2 1939-07-22        1964-07-19     
#>  4                    3          6 1941-12-20        1970-07-12     
#>  5                    1          9 1919-04-01        1924-01-11     
#>  6                    2         10 1952-07-23        1955-03-07     
#>  7                    3          4 1970-06-01        1971-04-24     
#>  8                    1          5 1960-10-06        1964-07-02     
#>  9                    3          1 1925-06-09        1926-07-28     
#> 10                    3          7 1975-08-13        1996-06-24     
#> # ℹ 1 more variable: visit_occurrence_0_to_inf <dbl>

# }
```
