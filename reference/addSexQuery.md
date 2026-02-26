# Query to add the sex of the individuals

Same as
[`addSex()`](https://darwin-eu.github.io/PatientProfiles/reference/addSex.md),
except query is not computed to a table.

## Usage

``` r
addSexQuery(x, sexName = "sex", missingSexValue = "None")
```

## Arguments

- x:

  Table with individuals in the cdm.

- sexName:

  Sex variable name.

- missingSexValue:

  Value to include if missing sex.

## Value

table x with the added column with sex information.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addSexQuery()
#> # Source:   SQL [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date sex   
#>                   <int>      <int> <date>            <date>          <chr> 
#>  1                    2          1 1916-08-11        1940-03-26      Female
#>  2                    3          2 1966-04-24        1967-08-07      Female
#>  3                    2          3 1997-10-26        1998-09-29      Male  
#>  4                    3          4 1989-03-15        1990-01-19      Female
#>  5                    2          5 1919-03-28        1936-11-08      Female
#>  6                    3          6 1937-12-05        1948-04-21      Female
#>  7                    1          7 1944-06-24        1948-12-20      Female
#>  8                    2          8 1990-04-06        1991-02-09      Female
#>  9                    3          9 1944-02-24        1947-06-20      Male  
#> 10                    2         10 1971-01-22        1971-07-28      Male  

# }
```
