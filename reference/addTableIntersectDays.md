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
#> # Source:   table<og_154_1772095779> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          1 1954-03-16        1957-11-25     
#>  2                    1          4 1915-10-05        1925-07-12     
#>  3                    1          5 1971-02-08        1984-09-13     
#>  4                    3          6 1935-01-11        1957-06-24     
#>  5                    2          8 1986-09-10        1987-03-16     
#>  6                    1          3 1953-04-01        1986-11-12     
#>  7                    1         10 1962-02-14        1984-07-07     
#>  8                    2          7 1987-11-11        1998-08-10     
#>  9                    2          9 1932-01-01        1933-03-24     
#> 10                    2          2 1987-01-16        1989-10-27     
#> # ℹ 1 more variable: visit_occurrence_0_to_inf <dbl>

# }
```
