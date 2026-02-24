# Add the ordinal number of the observation period associated that a given date is in.

Add the ordinal number of the observation period associated that a given
date is in.

## Usage

``` r
addObservationPeriodId(
  x,
  indexDate = "cohort_start_date",
  nameObservationPeriodId = "observation_period_id",
  name = NULL
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- indexDate:

  Variable in x that contains the date to compute the observation flag.

- nameObservationPeriodId:

  Name of the new column.

- name:

  Name of the new table, if NULL a temporary table is returned.

## Value

Table with the current observation period id added.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addObservationPeriodId()
#> # Source:   table<og_124_1771936252> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          2 1970-04-04        1978-11-07     
#>  2                    2         10 1942-05-09        1944-05-26     
#>  3                    2          8 1944-12-04        1961-12-20     
#>  4                    1          3 1962-08-13        1968-11-05     
#>  5                    1          5 1920-04-09        1920-07-04     
#>  6                    2          1 1979-12-11        1982-07-13     
#>  7                    1          7 1961-03-31        1974-09-19     
#>  8                    3          6 1970-01-08        1970-09-10     
#>  9                    3          9 1945-03-10        1947-10-26     
#> 10                    2          4 1926-10-19        1929-06-24     
#> # ℹ 1 more variable: observation_period_id <int>

# }
```
