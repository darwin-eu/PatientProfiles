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
#> # Source:   table<og_135_1772095355> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          1 1965-05-14        1966-05-18     
#>  2                    3          9 1969-01-03        1973-08-24     
#>  3                    1          8 1942-03-25        1961-11-15     
#>  4                    3          5 1973-01-04        1993-11-20     
#>  5                    1          6 1942-11-20        1948-05-21     
#>  6                    3          7 1911-10-15        1920-07-30     
#>  7                    3          4 1947-02-02        1947-08-22     
#>  8                    2         10 1920-04-20        1923-04-24     
#>  9                    2          2 1938-05-21        1941-12-04     
#> 10                    2          3 1939-09-17        1941-07-14     
#> # ℹ 1 more variable: in_observation <int>

# }
```
