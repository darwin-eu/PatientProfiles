# Compute the sex of the individuals

Compute the sex of the individuals

## Usage

``` r
addSex(x, sexName = "sex", missingSexValue = "None", name = NULL)
```

## Arguments

- x:

  A table containing individuals in a CDM reference.

- sexName:

  Name of the sex column to add.

- missingSexValue:

  Value to use when sex is missing.

- name:

  Name of the new table. If `NULL`, a temporary table is returned.

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
  addSex()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1022-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date sex   
#>                   <int>      <int> <date>            <date>          <chr> 
#>  1                    1          1 1946-09-12        1954-07-28      Male  
#>  2                    2          2 1944-05-21        1944-06-18      Male  
#>  3                    3          3 1984-11-13        1987-11-11      Male  
#>  4                    1          4 1931-01-22        1938-03-10      Male  
#>  5                    3          5 1951-07-09        1957-02-15      Female
#>  6                    3          6 2006-03-19        2007-09-21      Male  
#>  7                    1          7 1924-04-24        1925-03-13      Female
#>  8                    1          8 1941-09-18        1954-04-15      Female
#>  9                    2          9 1937-09-18        1940-12-23      Male  
#> 10                    3         10 1937-12-07        1946-10-05      Female

# }
```
