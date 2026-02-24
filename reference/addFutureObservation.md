# Compute the number of days till the end of the observation period at a certain date

Compute the number of days till the end of the observation period at a
certain date

## Usage

``` r
addFutureObservation(
  x,
  indexDate = "cohort_start_date",
  futureObservationName = "future_observation",
  futureObservationType = "days",
  name = NULL
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- indexDate:

  Variable in x that contains the date to compute the future
  observation.

- futureObservationName:

  name of the new column to be added.

- futureObservationType:

  Whether to return a "date" or the number of "days".

- name:

  Name of the new table, if NULL a temporary table is returned.

## Value

cohort table with added column containing future observation of the
individuals.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addFutureObservation()
#> # Source:   table<og_121_1771937996> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          3 1924-04-17        1946-05-22     
#>  2                    1          7 1941-01-15        1953-03-25     
#>  3                    2          8 1935-12-07        1940-12-16     
#>  4                    3          6 1915-02-07        1915-11-29     
#>  5                    1          5 1975-06-15        1995-01-05     
#>  6                    3          1 1973-04-13        1996-05-26     
#>  7                    3          4 1986-04-04        1986-07-02     
#>  8                    2         10 1972-08-30        1973-01-23     
#>  9                    1          9 1966-09-12        1967-07-20     
#> 10                    1          2 1920-11-14        1925-01-04     
#> # ℹ 1 more variable: future_observation <int>

# }
```
