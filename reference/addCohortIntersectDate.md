# Date of cohorts that are present in a certain window

Date of cohorts that are present in a certain window

## Usage

``` r
addCohortIntersectDate(
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
  cohorts will be used with a time variable added for each cohort of
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
#> Warning: There are observation period end dates after the current date: 2026-02-26
#> ℹ The latest max observation period end date found is 2030-08-21

cdm$cohort1 |>
  addCohortIntersectDate(targetCohortTable = "cohort2")
#> # Source:   table<og_016_1772095682> [?? x 7]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          6 1945-05-12        1945-09-05     
#>  2                    3          5 1920-04-21        1941-02-10     
#>  3                    2          2 1910-12-19        1921-11-30     
#>  4                    1          8 1988-10-16        1996-04-29     
#>  5                    3          7 1929-02-12        1946-05-26     
#>  6                    1          1 1995-01-29        1995-10-19     
#>  7                    3          3 1934-06-29        1941-06-17     
#>  8                    3         10 1975-06-25        1975-08-24     
#>  9                    3          9 1957-01-12        1957-10-07     
#> 10                    3          4 2015-09-20        2017-04-30     
#> # ℹ 3 more variables: cohort_1_0_to_inf <date>, cohort_2_0_to_inf <date>,
#> #   cohort_3_0_to_inf <date>

# }
```
