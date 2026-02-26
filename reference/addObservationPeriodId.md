# Add the ordinal number of the observation period associated that a given date is in.

Add the ordinal number of the observation period associated that a given
date is in.

## Usage

``` r
addObservationPeriodId(
  x,
  indexDate = "cohort_start_date",
  nameObservationPeriodId = "observation_period_id",
  name = NULL
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- indexDate:

  Variable in x that contains the date to compute the observation flag.

- nameObservationPeriodId:

  Name of the new column.

- name:

  Name of the new table, if NULL a temporary table is returned.

## Value

Table with the current observation period id added.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addObservationPeriodId()
#> # Source:   table<og_136_1772095361> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          1 1942-07-11        1942-08-11     
#>  2                    3          7 1909-10-16        1913-05-05     
#>  3                    2          8 1966-09-18        1969-03-01     
#>  4                    2          9 1907-05-13        1943-05-27     
#>  5                    2          2 1930-03-19        1931-10-08     
#>  6                    2         10 1940-09-10        1941-05-10     
#>  7                    1          6 1971-01-04        1985-05-27     
#>  8                    3          3 1952-11-11        1952-12-08     
#>  9                    3          4 1935-04-21        1948-05-02     
#> 10                    1          5 2002-03-24        2004-04-03     
#> # ℹ 1 more variable: observation_period_id <int>

# }
```
