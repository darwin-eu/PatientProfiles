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
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date cohort_name
#>                   <int>      <int> <date>            <date>          <chr>      
#>  1                    3          9 1950-10-09        1973-10-20      cohort_3   
#>  2                    2          7 1974-03-20        1986-05-07      cohort_2   
#>  3                    3          8 1966-08-21        1967-09-14      cohort_3   
#>  4                    1          3 1950-06-09        1968-04-04      cohort_1   
#>  5                    3         10 2001-06-19        2001-07-30      cohort_3   
#>  6                    2          6 1912-05-25        1913-02-18      cohort_2   
#>  7                    3          5 1961-04-29        1961-05-22      cohort_3   
#>  8                    1          4 1940-10-07        1945-06-03      cohort_1   
#>  9                    3          2 1943-03-25        1945-01-13      cohort_3   
#> 10                    3          1 1971-07-26        1979-07-24      cohort_3   
# }
```
