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

cdm$cohort1 |>
  addCdmName()
#> # Source:   SQL [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date cdm_name
#>                   <int>      <int> <date>            <date>          <chr>   
#>  1                    3          9 1957-05-31        1960-07-18      PP_MOCK 
#>  2                    2          8 1956-12-14        1962-09-13      PP_MOCK 
#>  3                    1          3 1996-09-20        1997-12-30      PP_MOCK 
#>  4                    3          2 2006-10-06        2010-02-17      PP_MOCK 
#>  5                    3          1 1912-11-26        1916-09-26      PP_MOCK 
#>  6                    3         10 1963-05-27        1965-01-02      PP_MOCK 
#>  7                    1          7 1935-01-02        1944-02-29      PP_MOCK 
#>  8                    2          5 1960-03-21        1967-04-19      PP_MOCK 
#>  9                    2          6 1955-08-10        1978-08-28      PP_MOCK 
#> 10                    1          4 1940-03-22        1945-04-06      PP_MOCK 
# }
```
