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

  Variable in x that contains the date to compute the prior observation.

- priorObservationName:

  name of the new column to be added.

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
#> # Source:   table<og_126_1771936258> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          1 1920-09-28        1921-01-12     
#>  2                    3          7 1928-01-23        1930-12-08     
#>  3                    2          4 1973-12-20        1974-01-21     
#>  4                    2          9 1921-04-01        1921-06-27     
#>  5                    1          8 1981-06-23        1997-09-30     
#>  6                    1          5 1954-09-15        1954-11-09     
#>  7                    2         10 1966-06-02        1969-10-16     
#>  8                    2          3 1929-04-04        1973-09-06     
#>  9                    1          6 1959-12-20        1979-06-23     
#> 10                    2          2 1968-11-02        1971-04-08     
#> # ℹ 1 more variable: prior_observation <int>

# }
```
