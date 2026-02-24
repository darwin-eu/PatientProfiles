# Query to add a new column to indicate if a certain record is within the observation period

\`r lifecycle::badge("experimental")\` Same as \`addInObservation()\`,
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
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          8 1969-04-19        1969-08-09     
#>  2                    3          6 1975-07-06        1983-03-02     
#>  3                    2          5 1998-01-10        1999-01-16     
#>  4                    3          7 1942-04-12        1942-08-26     
#>  5                    1          9 1960-06-11        1964-11-20     
#>  6                    2          1 1968-04-30        1971-05-27     
#>  7                    1         10 1920-04-02        1925-09-24     
#>  8                    3          4 1959-02-13        1966-04-24     
#>  9                    2          3 1958-12-11        1959-12-25     
#> 10                    2          2 1966-10-24        1968-09-04     
#> # ℹ 1 more variable: in_observation <int>

# }
```
