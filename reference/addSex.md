# Compute the sex of the individuals

Compute the sex of the individuals

## Usage

``` r
addSex(x, sexName = "sex", missingSexValue = "None", name = NULL)
```

## Arguments

- x:

  Table with individuals in the cdm.

- sexName:

  name of the new column to be added.

- missingSexValue:

  Value to include if missing sex.

- name:

  Name of the new table, if NULL a temporary table is returned.

## Value

table x with the added column with sex information.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addSex()
#> # Source:   table<og_127_1771936264> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date sex   
#>                   <int>      <int> <date>            <date>          <chr> 
#>  1                    2          1 1948-06-19        1950-07-03      Female
#>  2                    2          2 1962-06-29        1975-04-09      Male  
#>  3                    3          3 1949-06-07        1953-08-21      Female
#>  4                    2          4 1909-10-22        1922-07-03      Female
#>  5                    1          5 1956-12-18        1958-11-18      Male  
#>  6                    1          6 1939-10-17        1944-10-16      Male  
#>  7                    3          7 1998-09-06        2001-08-17      Female
#>  8                    3          8 1957-08-22        1957-10-02      Male  
#>  9                    1          9 1939-07-09        1940-05-30      Male  
#> 10                    1         10 1962-08-08        1963-05-20      Female

# }
```
