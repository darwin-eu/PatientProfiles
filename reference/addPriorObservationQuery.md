# Query to add the number of days of prior observation in the current observation period at a certain date

\`r lifecycle::badge("experimental")\` Same as
\`addPriorObservation()\`, except query is not computed to a table.

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

  Variable in x that contains the date to compute the prior observation.

- priorObservationName:

  name of the new column to be added.

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
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          2 1973-03-21        1982-07-11     
#>  2                    2          6 1958-05-13        1994-05-27     
#>  3                    2          1 1944-08-22        1948-12-31     
#>  4                    2          7 1973-09-10        1974-05-10     
#>  5                    1          8 1962-01-04        1976-05-27     
#>  6                    3         10 2013-05-24        2016-04-09     
#>  7                    3          5 1956-04-20        1958-02-13     
#>  8                    1          9 1941-03-24        1941-04-07     
#>  9                    2          4 1976-07-21        1996-09-21     
#> 10                    2          3 1931-09-01        1935-01-21     
#> # ℹ 1 more variable: prior_observation <int>

# }
```
