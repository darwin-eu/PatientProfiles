# Compute date of intersect with an omop table.

Compute date of intersect with an omop table.

## Usage

``` r
addTableIntersectDate(
  x,
  tableName,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  window = list(c(0, Inf)),
  targetDate = startDateColumn(tableName),
  inObservation = TRUE,
  order = "first",
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

- targetDate:

  Target date in tableName.

- inObservation:

  If TRUE only records inside an observation period will be considered.

- order:

  which record is considered in case of multiple records (only required
  for date and days options).

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
  addTableIntersectDate(tableName = "visit_occurrence")
#> # Source:   table<og_137_1771938029> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          6 1928-08-04        1934-03-31     
#>  2                    2          8 1979-02-24        1991-08-02     
#>  3                    1         10 1938-07-08        1951-04-12     
#>  4                    2          7 1913-08-08        1925-06-03     
#>  5                    2          3 1934-01-13        1934-01-19     
#>  6                    1          9 1923-06-21        1939-08-31     
#>  7                    2          2 1934-11-20        1940-12-30     
#>  8                    2          1 1948-04-17        1948-05-18     
#>  9                    2          5 1974-11-04        1989-05-13     
#> 10                    3          4 1930-11-13        1931-07-11     
#> # ℹ 1 more variable: visit_occurrence_0_to_inf <date>

# }
```
