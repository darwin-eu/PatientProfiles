# Add cohort name for each cohort_definition_id

Add cohort name for each cohort_definition_id

## Usage

``` r
addCohortName(cohort)
```

## Arguments

- cohort:

  cohort to which add the cohort name

## Value

cohort with an extra column with the cohort names

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
cdm$cohort1 |>
  addCohortName()
#> # Source:   SQL [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date cohort_name
#>                   <int>      <int> <date>            <date>          <chr>      
#>  1                    1          4 1947-05-09        1956-07-21      cohort_1   
#>  2                    2         10 1939-06-07        1954-04-05      cohort_2   
#>  3                    1          3 1921-08-14        1923-05-15      cohort_1   
#>  4                    1          7 1907-01-30        1907-02-21      cohort_1   
#>  5                    3          1 1957-03-08        1958-08-11      cohort_3   
#>  6                    1          9 1964-02-23        1965-10-17      cohort_1   
#>  7                    1          2 1929-06-05        1931-04-22      cohort_1   
#>  8                    1          5 1931-07-22        1963-05-14      cohort_1   
#>  9                    1          6 1983-05-01        2019-06-09      cohort_1   
#> 10                    3          8 1907-01-04        1927-05-05      cohort_3   
# }
```
