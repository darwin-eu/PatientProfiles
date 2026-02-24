# Compute time to intersect with an omop table.

Compute time to intersect with an omop table.

## Usage

``` r
addTableIntersectDays(
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
  addTableIntersectDays(tableName = "visit_occurrence")
#> # Source:   table<og_142_1771936276> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          3 1909-05-01        1952-02-03     
#>  2                    2          5 1965-02-21        1990-04-29     
#>  3                    3          6 1987-12-13        1997-10-09     
#>  4                    2         10 1978-05-11        1982-06-03     
#>  5                    2          2 1946-11-14        1950-01-05     
#>  6                    3          7 1964-05-11        1965-02-01     
#>  7                    3          9 2016-08-19        2017-01-20     
#>  8                    1          1 1974-06-24        1982-12-15     
#>  9                    3          8 1959-10-25        1961-01-03     
#> 10                    1          4 1932-02-14        1933-12-25     
#> # ℹ 1 more variable: visit_occurrence_0_to_inf <dbl>

# }
```
