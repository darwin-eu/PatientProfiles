# Compute a flag intersect with an omop table.

Compute a flag intersect with an omop table.

## Usage

``` r
addTableIntersectFlag(
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
  addTableIntersectFlag(tableName = "visit_occurrence")
#> # Source:   table<og_164_1772095391> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          3 1961-12-26        1966-09-07     
#>  2                    1         10 1909-12-26        1914-09-26     
#>  3                    3          1 1917-11-09        1957-01-23     
#>  4                    1          9 1949-01-04        1974-11-17     
#>  5                    2          8 1944-08-31        1964-03-15     
#>  6                    1          5 1937-12-04        1948-09-23     
#>  7                    1          2 1939-07-31        1943-12-09     
#>  8                    2          4 2013-01-07        2014-01-05     
#>  9                    3          6 2003-07-22        2007-08-03     
#> 10                    3          7 1982-10-03        1982-12-13     
#> # ℹ 1 more variable: visit_occurrence_0_to_inf <dbl>

# }
```
