# Compute the number of days of prior observation in the current observation period at a certain date

Compute the number of days of prior observation in the current
observation period at a certain date

## Usage

``` r
addPriorObservation(
  x,
  indexDate = "cohort_start_date",
  priorObservationName = "prior_observation",
  priorObservationType = "days",
  name = NULL
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- indexDate:

  Variable in x that contains the date to compute the demographics
  characteristics.

- priorObservationName:

  Prior observation variable name.

- priorObservationType:

  Whether to return a "date" or the number of "days".

- name:

  Name of the new table, if NULL a temporary table is returned.

## Value

cohort table with added column containing prior observation of the
individuals.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addPriorObservation()
#> # Source:   table<og_138_1772095367> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          2 1918-08-21        1929-04-24     
#>  2                    2          1 1930-09-13        1937-01-17     
#>  3                    2          6 1916-12-31        1940-03-04     
#>  4                    3          4 1944-02-21        1945-01-15     
#>  5                    2          3 1948-06-27        1952-07-05     
#>  6                    3          5 1968-08-03        1970-08-30     
#>  7                    3          8 1920-11-18        1923-02-17     
#>  8                    3          7 1942-08-28        1962-11-28     
#>  9                    1          9 1929-11-10        1932-10-30     
#> 10                    3         10 1977-07-29        1982-06-18     
#> # ℹ 1 more variable: prior_observation <int>

# }
```
