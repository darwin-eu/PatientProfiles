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

  A table containing individuals in a CDM reference.

- sexName:

  Name of the sex column to add.

- missingSexValue:

  Value to use when sex is missing.

## Value

table x with the added column with sex information.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/Rtmp52x3ty/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

cdm$cohort1 |>
  addSexQuery()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1022-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date sex   
#>                   <int>      <int> <date>            <date>          <chr> 
#>  1                    3          1 1974-03-15        1986-04-24      Male  
#>  2                    1          2 1948-10-28        1961-09-05      Female
#>  3                    3          3 1959-06-27        1959-06-29      Female
#>  4                    1          4 1967-11-22        1976-06-25      Female
#>  5                    1          5 1962-07-31        1968-10-02      Female
#>  6                    3          6 1940-08-01        1951-11-14      Male  
#>  7                    2          7 1967-02-23        1968-05-13      Male  
#>  8                    1          8 1940-04-24        1943-04-17      Female
#>  9                    3          9 1937-08-25        1938-03-29      Male  
#> 10                    1         10 1952-03-11        1963-09-21      Female

# }
```
