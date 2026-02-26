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

  Sex variable name.

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
#> # Source:   table<og_139_1772095767> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date sex   
#>                   <int>      <int> <date>            <date>          <chr> 
#>  1                    2          1 1924-05-15        1930-08-04      Female
#>  2                    1          2 1990-11-09        1993-01-25      Female
#>  3                    2          3 1964-06-13        1971-09-30      Male  
#>  4                    2          4 1949-05-28        1951-01-23      Female
#>  5                    2          5 1959-02-22        1973-07-27      Male  
#>  6                    3          6 1928-09-17        1930-11-24      Female
#>  7                    2          7 1980-01-11        1983-10-12      Female
#>  8                    1          8 1974-12-14        1989-05-21      Male  
#>  9                    1          9 1946-12-21        1950-01-27      Female
#> 10                    3         10 1976-02-05        1976-07-22      Male  

# }
```
