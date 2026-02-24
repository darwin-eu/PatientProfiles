# Add days to death for individuals. Only death within the same observation period than \`indexDate\` will be observed.

Add days to death for individuals. Only death within the same
observation period than \`indexDate\` will be observed.

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

cdm$cohort1 |>
  addDeathDays()
#> # Source:   table<og_102_1771937982> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          7 1956-04-19        1958-01-10     
#>  2                    1          2 1962-12-03        1965-11-27     
#>  3                    3          3 1925-02-11        1948-09-24     
#>  4                    1          6 1976-02-23        1985-03-03     
#>  5                    2          4 1983-10-07        2001-05-01     
#>  6                    3          9 1951-11-22        1954-01-23     
#>  7                    1          8 1968-10-18        1968-12-01     
#>  8                    1          5 1991-04-22        1999-03-10     
#>  9                    2         10 1947-07-05        1952-03-22     
#> 10                    1          1 1994-08-11        2005-10-27     
#> # ℹ 1 more variable: days_to_death <dbl>

# }
```
