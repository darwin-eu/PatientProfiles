# Add date of death for individuals. Only death within the same observation period than `indexDate` will be observed.

Add date of death for individuals. Only death within the same
observation period than `indexDate` will be observed.

## Usage

``` r
addDeathDate(
  x,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  window = c(0, Inf),
  deathDateName = "date_of_death",
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

- deathDateName:

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

cdm$cohort1 |>
  addDeathDate()
#> # Source:   table<og_108_1772095334> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          8 1982-01-14        1982-03-06     
#>  2                    2          3 1942-03-27        1948-01-24     
#>  3                    2          5 1931-12-07        1932-08-20     
#>  4                    3          7 1953-07-05        1955-08-30     
#>  5                    2         10 1912-03-11        1930-12-09     
#>  6                    1          4 1984-11-22        1990-06-14     
#>  7                    1          2 1923-10-25        1925-11-01     
#>  8                    1          9 1964-10-14        1990-09-13     
#>  9                    2          1 1904-09-14        1932-02-21     
#> 10                    2          6 1994-12-05        1998-11-04     
#> # ℹ 1 more variable: date_of_death <date>

# }
```
