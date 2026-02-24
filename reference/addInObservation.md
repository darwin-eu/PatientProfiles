# Indicate if a certain record is within the observation period

Indicate if a certain record is within the observation period

## Usage

``` r
addInObservation(
  x,
  indexDate = "cohort_start_date",
  window = c(0, 0),
  completeInterval = FALSE,
  nameStyle = "in_observation",
  name = NULL
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- indexDate:

  Variable in x that contains the date to compute the observation flag.

- window:

  window to consider events of.

- completeInterval:

  If the individuals are in observation for the full window.

- nameStyle:

  Name of the new columns to create, it must contain "window_name" if
  multiple windows are provided.

- name:

  Name of the new table, if NULL a temporary table is returned.

## Value

cohort table with the added numeric column assessing observation (1 in
observation, 0 not in observation).

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addInObservation()
#> # Source:   table<og_123_1771936247> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          8 1967-06-07        1972-08-07     
#>  2                    1          6 1930-02-19        1934-03-23     
#>  3                    2          3 2003-04-11        2004-02-01     
#>  4                    3         10 1993-01-12        1995-05-14     
#>  5                    3          7 1933-08-04        1942-02-26     
#>  6                    2          4 1967-10-25        1967-10-30     
#>  7                    1          5 1950-07-22        1966-05-06     
#>  8                    2          2 1939-08-22        1954-03-15     
#>  9                    2          1 2017-10-24        2018-01-12     
#> 10                    2          9 1933-12-30        1967-12-15     
#> # ℹ 1 more variable: in_observation <int>

# }
```
