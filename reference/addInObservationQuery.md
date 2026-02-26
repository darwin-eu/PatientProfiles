# Query to add a new column to indicate if a certain record is within the observation period

Same as
[`addInObservation()`](https://darwin-eu.github.io/PatientProfiles/reference/addInObservation.md),
except query is not computed to a table.

## Usage

``` r
addInObservationQuery(
  x,
  indexDate = "cohort_start_date",
  window = c(0, 0),
  completeInterval = FALSE,
  nameStyle = "in_observation"
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- indexDate:

  Variable in x that contains the date to compute the observation flag.

- window:

  window to consider events of.

- completeInterval:

  If the individuals are in observation for the full window.

- nameStyle:

  Name of the new columns to create, it must contain "window_name" if
  multiple windows are provided.

## Value

cohort table with the added numeric column assessing observation (1 in
observation, 0 not in observation).

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addInObservationQuery()
#> # Source:   SQL [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          6 1966-04-30        1979-09-09     
#>  2                    1          7 1925-03-15        1929-02-16     
#>  3                    2         10 1946-06-17        1951-07-31     
#>  4                    1          2 2005-04-30        2005-05-30     
#>  5                    1          4 1926-08-05        1928-07-27     
#>  6                    3          8 1967-10-09        1975-07-20     
#>  7                    3          5 1971-05-02        1972-07-26     
#>  8                    1          3 1975-08-18        1990-06-25     
#>  9                    2          9 1988-04-22        2021-05-07     
#> 10                    1          1 1921-01-19        1954-01-29     
#> # ℹ 1 more variable: in_observation <int>

# }
```
