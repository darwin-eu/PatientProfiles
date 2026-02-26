# It creates columns to indicate the number of days between the current table and a target cohort

It creates columns to indicate the number of days between the current
table and a target cohort

## Usage

``` r
addCohortIntersectDays(
  x,
  targetCohortTable,
  targetCohortId = NULL,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  targetDate = "cohort_start_date",
  order = "first",
  window = c(0, Inf),
  nameStyle = "{cohort_name}_{window_name}",
  name = NULL
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- targetCohortTable:

  Cohort table to.

- targetCohortId:

  Cohort IDs of interest from the other cohort table. If NULL, all
  cohorts will be used with a days variable added for each cohort of
  interest.

- indexDate:

  Variable in x that contains the date to compute the intersection.

- censorDate:

  whether to censor overlap events at a specific date or a column date
  of x.

- targetDate:

  Date of interest in the other cohort table. Either cohort_start_date
  or cohort_end_date.

- order:

  date to use if there are multiple records for an individual during the
  window of interest. Either first or last.

- window:

  Window of time to identify records relative to the indexDate. Records
  outside of this time period will be ignored.

- nameStyle:

  naming of the added column or columns, should include required
  parameters.

- name:

  Name of the new table, if NULL a temporary table is returned.

## Value

x along with additional columns for each cohort of interest.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addCohortIntersectDays(targetCohortTable = "cohort2")
#> # Source:   table<og_022_1772095685> [?? x 7]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          3 1927-02-10        1931-11-24     
#>  2                    2          5 1947-09-04        1963-07-20     
#>  3                    1          2 1950-07-20        1960-11-01     
#>  4                    2          6 1947-04-16        1948-12-29     
#>  5                    2         10 1937-05-04        1939-09-25     
#>  6                    3          4 1979-02-19        1981-12-01     
#>  7                    2          7 1987-04-23        1988-03-07     
#>  8                    1          9 1938-04-30        1939-03-02     
#>  9                    3          1 1968-09-28        1973-01-15     
#> 10                    1          8 1950-12-24        1950-12-27     
#> # ℹ 3 more variables: cohort_3_0_to_inf <dbl>, cohort_2_0_to_inf <dbl>,
#> #   cohort_1_0_to_inf <dbl>

# }
```
