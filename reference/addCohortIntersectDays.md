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
#> # Source:   table<og_020_1771937935> [?? x 7]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          7 1936-06-28        1938-05-16     
#>  2                    1         10 1945-04-11        1951-10-16     
#>  3                    1          9 1983-02-02        1998-07-01     
#>  4                    1          5 1979-08-10        1989-08-20     
#>  5                    2          6 1945-03-20        1947-01-08     
#>  6                    2          8 1964-11-30        1970-02-04     
#>  7                    3          2 1946-02-18        1954-06-29     
#>  8                    1          4 1979-07-06        2002-06-13     
#>  9                    1          1 1924-07-27        1928-06-03     
#> 10                    1          3 2009-06-20        2014-02-28     
#> # ℹ 3 more variables: cohort_1_0_to_inf <dbl>, cohort_2_0_to_inf <dbl>,
#> #   cohort_3_0_to_inf <dbl>

# }
```
