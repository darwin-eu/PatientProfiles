# Query to add the number of days till the end of the observation period at a certain date

\`r lifecycle::badge("experimental")\` Same as
\`addFutureObservation()\`, except query is not computed to a table.

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

  Variable in x that contains the date to compute the future
  observation.

- futureObservationName:

  name of the new column to be added.

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
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          6 1958-10-02        1963-01-20     
#>  2                    3          1 1988-04-07        1994-01-29     
#>  3                    3          7 1940-08-06        1948-12-30     
#>  4                    2          2 1951-08-16        1953-05-09     
#>  5                    2          8 1944-10-25        1955-10-24     
#>  6                    3          4 1975-12-06        1988-11-10     
#>  7                    3         10 1929-03-23        1942-10-08     
#>  8                    1          9 1982-10-13        1992-09-01     
#>  9                    2          3 1979-09-22        1989-08-24     
#> 10                    2          5 1932-12-21        1938-06-23     
#> # ℹ 1 more variable: future_observation <int>

# }
```
