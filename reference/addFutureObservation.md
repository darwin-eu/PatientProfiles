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

  Variable in x that contains the date to compute the demographics
  characteristics.

- futureObservationName:

  Future observation variable name.

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
#> # Source:   table<og_133_1772095350> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          3 2006-09-10        2007-11-17     
#>  2                    3          5 1992-01-04        1998-05-31     
#>  3                    2          2 1981-10-06        1987-06-13     
#>  4                    1          4 1930-08-24        1931-02-07     
#>  5                    1         10 1957-07-26        1967-01-12     
#>  6                    1          8 1932-12-30        1950-09-07     
#>  7                    1          7 1972-05-22        1984-11-05     
#>  8                    3          1 1970-11-09        1985-08-12     
#>  9                    1          9 1972-05-06        1972-11-12     
#> 10                    3          6 1948-06-26        1953-02-16     
#> # ℹ 1 more variable: future_observation <int>

# }
```
