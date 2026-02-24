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
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          3 1968-11-21        1969-01-24     
#>  2                    1          8 1972-03-31        1979-02-22     
#>  3                    1          9 1977-03-18        1989-03-10     
#>  4                    2          7 1918-07-15        1920-02-12     
#>  5                    3          2 1960-10-12        1964-04-30     
#>  6                    1          5 1961-02-07        1961-12-05     
#>  7                    3          4 1932-07-14        1937-01-20     
#>  8                    1          1 1962-12-31        1967-03-23     
#>  9                    3          6 1995-05-04        1996-08-30     
#> 10                    2         10 1909-12-15        1914-12-25     
#> # ℹ 1 more variable: observation_period_id <int>

# }
```
