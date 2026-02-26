# Add days to death for individuals. Only death within the same observation period than `indexDate` will be observed.

Add days to death for individuals. Only death within the same
observation period than `indexDate` will be observed.

## Usage

``` r
addDeathDays(
  x,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  window = c(0, Inf),
  deathDaysName = "days_to_death",
  name = NULL
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- indexDate:

  Variable in x that contains the window origin.

- censorDate:

  Name of a column to stop followup.

- window:

  window to consider events over.

- deathDaysName:

  name of the new column to be added.

- name:

  Name of the new table, if NULL a temporary table is returned.

## Value

table x with the added column with death information added.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
#> Warning: There are observation period end dates after the current date: 2026-02-26
#> ℹ The latest max observation period end date found is 2028-08-29

cdm$cohort1 |>
  addDeathDays()
#> # Source:   table<og_114_1772095337> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          6 1968-12-11        1970-09-01     
#>  2                    2          8 1969-04-05        1971-02-21     
#>  3                    1          7 1933-01-27        1941-02-22     
#>  4                    1          5 1998-02-05        2025-01-08     
#>  5                    2          9 1961-01-18        1961-01-19     
#>  6                    1          1 1988-04-20        1989-02-08     
#>  7                    2          3 1961-01-18        1963-01-07     
#>  8                    1         10 1938-11-20        1946-09-15     
#>  9                    3          4 1981-06-16        1982-05-13     
#> 10                    2          2 1931-04-06        1931-09-05     
#> # ℹ 1 more variable: days_to_death <dbl>

# }
```
