# Add date of death for individuals. Only death within the same observation period than \`indexDate\` will be observed.

Add date of death for individuals. Only death within the same
observation period than \`indexDate\` will be observed.

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
#> # Source:   table<og_096_1771936225> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          5 1953-01-12        1962-11-27     
#>  2                    3          2 1983-11-20        1994-12-24     
#>  3                    1          3 1913-04-24        1915-04-02     
#>  4                    1          4 1921-12-31        1936-11-05     
#>  5                    1          7 1963-07-02        1976-10-04     
#>  6                    3          8 1965-08-19        1967-12-02     
#>  7                    3          6 1989-01-29        1989-05-08     
#>  8                    1         10 1969-11-23        1980-12-17     
#>  9                    2          1 1914-06-28        1917-01-06     
#> 10                    3          9 1987-02-14        1987-07-20     
#> # ℹ 1 more variable: date_of_death <date>

# }
```
