# Add cdm name

Add cdm name

## Usage

``` r
addCdmName(table, cdm = omopgenerics::cdmReference(table))
```

## Arguments

- table:

  A table to process.

- cdm:

  A `cdm_reference` object.

## Value

Table with an extra column with the cdm names

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
  addCdmName()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1022-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date cdm_name
#>                   <int>      <int> <date>            <date>          <chr>   
#>  1                    1         10 1991-03-18        1994-11-17      PP_MOCK 
#>  2                    3          6 1941-04-02        1944-03-24      PP_MOCK 
#>  3                    3          1 1971-06-03        1973-07-17      PP_MOCK 
#>  4                    1          4 1952-10-28        1953-07-21      PP_MOCK 
#>  5                    2          8 1913-08-07        1920-08-24      PP_MOCK 
#>  6                    1          5 1932-06-03        1941-01-02      PP_MOCK 
#>  7                    3          9 1950-01-29        1950-02-01      PP_MOCK 
#>  8                    2          7 1961-08-29        1972-02-12      PP_MOCK 
#>  9                    2          2 1962-04-10        1984-09-23      PP_MOCK 
#> 10                    1          3 1993-01-04        1997-08-21      PP_MOCK 
# }
```
