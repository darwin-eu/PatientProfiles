# Query to add the number of days of prior observation in the current observation period at a certain date

Same as
[`addPriorObservation()`](https://darwin-eu.github.io/PatientProfiles/reference/addPriorObservation.md),
except query is not computed to a table.

## Usage

``` r
addPriorObservationQuery(
  x,
  indexDate = "cohort_start_date",
  priorObservationName = "prior_observation",
  priorObservationType = "days"
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

## Value

cohort table with added column containing prior observation of the
individuals.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addPriorObservationQuery()
#> # Source:   SQL [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          4 1952-09-28        1959-03-25     
#>  2                    3          7 1931-04-13        1943-09-25     
#>  3                    3          3 1949-08-01        1958-03-23     
#>  4                    2          6 1970-03-27        1986-11-13     
#>  5                    2          9 1952-06-17        1956-02-13     
#>  6                    2          2 1950-06-20        1953-02-22     
#>  7                    1          8 1934-07-20        1966-06-17     
#>  8                    3          1 1912-10-09        1913-08-23     
#>  9                    1          5 1945-02-06        1980-09-16     
#> 10                    1         10 1989-06-25        2000-06-04     
#> # ℹ 1 more variable: prior_observation <int>

# }
```
