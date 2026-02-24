# Query to add the sex of the individuals

\`r lifecycle::badge("experimental")\` Same as \`addSex()\`, except
query is not computed to a table.

## Usage

``` r
addSexQuery(x, sexName = "sex", missingSexValue = "None")
```

## Arguments

- x:

  Table with individuals in the cdm.

- sexName:

  name of the new column to be added.

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
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date sex   
#>                   <int>      <int> <date>            <date>          <chr> 
#>  1                    2          1 1930-09-13        1937-01-17      Male  
#>  2                    1          2 1918-08-21        1929-04-24      Female
#>  3                    2          3 1948-06-27        1952-07-05      Male  
#>  4                    3          4 1944-02-21        1945-01-15      Male  
#>  5                    3          5 1968-08-03        1970-08-30      Female
#>  6                    2          6 1916-12-31        1940-03-04      Male  
#>  7                    3          7 1942-08-28        1962-11-28      Female
#>  8                    3          8 1920-11-18        1923-02-17      Male  
#>  9                    1          9 1929-11-10        1932-10-30      Female
#> 10                    3         10 1977-07-29        1982-06-18      Male  

# }
```
