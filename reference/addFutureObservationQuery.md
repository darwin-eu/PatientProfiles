# Query to add the number of days till the end of the observation period at a certain date

Same as
[`addFutureObservation()`](https://darwin-eu.github.io/PatientProfiles/reference/addFutureObservation.md),
except query is not computed to a table.

## Usage

``` r
addFutureObservationQuery(
  x,
  indexDate = "cohort_start_date",
  futureObservationName = "future_observation",
  futureObservationType = "days"
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

## Value

cohort table with added column containing future observation of the
individuals.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addFutureObservationQuery()
#> # Source:   SQL [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          6 1979-04-26        1986-09-19     
#>  2                    2          4 1980-11-09        1981-04-07     
#>  3                    1          9 1962-03-15        1966-12-29     
#>  4                    1          2 1949-04-01        1954-02-16     
#>  5                    1          8 1934-04-12        1938-04-19     
#>  6                    1          5 1936-12-03        1951-12-08     
#>  7                    2          3 1996-02-11        2002-09-08     
#>  8                    3          7 1989-04-18        1995-08-20     
#>  9                    3          1 1922-05-13        1922-08-17     
#> 10                    1         10 1903-08-30        1919-03-02     
#> # ℹ 1 more variable: future_observation <int>

# }
```
