# Add the ordinal number of the observation period associated that a given date is in. Result is not computed, only query is added.

Add the ordinal number of the observation period associated that a given
date is in. Result is not computed, only query is added.

## Usage

``` r
addObservationPeriodIdQuery(
  x,
  indexDate = "cohort_start_date",
  nameObservationPeriodId = "observation_period_id"
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- indexDate:

  Variable in x that contains the date to compute the observation flag.

- nameObservationPeriodId:

  Name of the new column.

## Value

Table with the current observation period id added.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addObservationPeriodIdQuery()
#> # Source:   SQL [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1         10 1962-08-08        1963-05-20     
#>  2                    2          4 1909-10-22        1922-07-03     
#>  3                    3          7 1998-09-06        2001-08-17     
#>  4                    2          2 1962-06-29        1975-04-09     
#>  5                    1          6 1939-10-17        1944-10-16     
#>  6                    1          5 1956-12-18        1958-11-18     
#>  7                    2          1 1948-06-19        1950-07-03     
#>  8                    3          3 1949-06-07        1953-08-21     
#>  9                    1          9 1939-07-09        1940-05-30     
#> 10                    3          8 1957-08-22        1957-10-02     
#> # ℹ 1 more variable: observation_period_id <int>

# }
```
