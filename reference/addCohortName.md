# Add cohort name for each cohort_definition_id

Add cohort name for each cohort_definition_id

## Usage

``` r
addCohortName(cohort)
```

## Arguments

- cohort:

  A `cohort_table` object.

## Value

cohort with an extra column with the cohort names

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmpIdk5b4/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.
cdm$cohort1 |>
  addCohortName()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date cohort_name
#>                   <int>      <int> <date>            <date>          <chr>      
#>  1                    3          8 1984-10-13        1987-04-10      cohort_3   
#>  2                    1          1 1945-11-27        1948-11-14      cohort_1   
#>  3                    1          7 1997-06-30        2009-09-16      cohort_1   
#>  4                    2          2 1921-12-20        1943-06-20      cohort_2   
#>  5                    2         10 1976-03-09        1978-05-30      cohort_2   
#>  6                    3          5 1981-01-25        1981-05-11      cohort_3   
#>  7                    1          4 1964-07-22        1967-02-06      cohort_1   
#>  8                    1          3 1971-06-03        1972-07-05      cohort_1   
#>  9                    3          9 1978-08-19        1992-10-14      cohort_3   
#> 10                    3          6 1963-08-04        1969-07-23      cohort_3   
# }
```
