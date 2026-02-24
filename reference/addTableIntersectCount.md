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
#> # Source:   table<og_128_1771938025> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          8 1969-06-10        1991-06-20     
#>  2                    1          3 1913-05-11        1921-04-03     
#>  3                    2          6 1946-06-13        1973-08-23     
#>  4                    3         10 1943-04-13        1950-06-17     
#>  5                    2          1 1987-06-08        1987-06-11     
#>  6                    2          7 1984-07-24        1988-05-29     
#>  7                    3          5 1929-09-12        1934-05-18     
#>  8                    2          9 1992-06-15        1993-02-13     
#>  9                    1          2 1977-01-01        1985-12-02     
#> 10                    3          4 1906-05-24        1907-05-28     
#> # ℹ 1 more variable: visit_occurrence_0_to_inf <dbl>

# }
```
