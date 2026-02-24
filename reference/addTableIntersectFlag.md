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
#> # Source:   table<og_152_1771938039> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          3 1911-09-01        1911-11-16     
#>  2                    2          6 1962-07-20        1979-10-16     
#>  3                    1          5 1972-02-10        1990-02-15     
#>  4                    2         10 1904-09-09        1921-11-28     
#>  5                    1          4 1944-04-25        1945-12-08     
#>  6                    3          1 1948-05-12        1966-08-08     
#>  7                    1          7 1943-11-06        1943-12-07     
#>  8                    3          2 1934-05-18        1935-12-31     
#>  9                    3          9 1974-06-03        1974-07-22     
#> 10                    3          8 1922-09-30        1938-01-18     
#> # ℹ 1 more variable: visit_occurrence_0_to_inf <dbl>

# }
```
