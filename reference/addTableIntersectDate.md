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
#> # Source:   table<og_149_1772095381> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          3 1908-12-28        1921-10-22     
#>  2                    3          5 1970-08-10        1996-10-10     
#>  3                    3          1 1951-11-07        1953-01-24     
#>  4                    3          6 1942-03-08        1955-08-25     
#>  5                    1         10 1961-08-02        1963-05-26     
#>  6                    1          7 1972-03-12        1984-11-27     
#>  7                    3          4 1945-08-08        1948-04-16     
#>  8                    1          8 2006-03-21        2008-07-21     
#>  9                    3          9 1960-09-04        1961-05-10     
#> 10                    3          2 1944-03-02        1961-09-10     
#> # ℹ 1 more variable: visit_occurrence_0_to_inf <date>

# }
```
