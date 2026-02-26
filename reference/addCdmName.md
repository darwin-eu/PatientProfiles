# Add cdm name

Add cdm name

## Usage

``` r
addCdmName(table, cdm = omopgenerics::cdmReference(table))
```

## Arguments

- table:

  Table in the cdm

- cdm:

  A cdm reference object

## Value

Table with an extra column with the cdm names

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
#> Warning: There are observation period end dates after the current date: 2026-02-26
#> ℹ The latest max observation period end date found is 2026-11-07

cdm$cohort1 |>
  addCdmName()
#> # Source:   SQL [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date cdm_name
#>                   <int>      <int> <date>            <date>          <chr>   
#>  1                    2          5 1974-09-25        1982-07-01      PP_MOCK 
#>  2                    2          7 1958-01-07        1958-04-23      PP_MOCK 
#>  3                    3          1 1970-06-27        1985-09-05      PP_MOCK 
#>  4                    3          8 1927-12-21        1929-04-17      PP_MOCK 
#>  5                    3          9 1953-04-19        1956-06-19      PP_MOCK 
#>  6                    1          4 1948-08-17        1954-06-21      PP_MOCK 
#>  7                    1          2 2019-07-09        2020-04-19      PP_MOCK 
#>  8                    2          3 1983-02-24        1990-01-10      PP_MOCK 
#>  9                    3          6 1948-06-01        1951-01-11      PP_MOCK 
#> 10                    1         10 1926-02-24        1936-10-10      PP_MOCK 
# }
```
