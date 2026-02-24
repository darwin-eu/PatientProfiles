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

cdm$cohort1 |>
  addCohortIntersectDate(targetCohortTable = "cohort2")
#> # Source:   table<og_014_1771937931> [?? x 7]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          9 1932-03-13        1932-06-02     
#>  2                    2          4 1937-09-07        1952-05-01     
#>  3                    1          1 1964-06-29        1991-04-01     
#>  4                    1          3 1944-04-28        1960-05-26     
#>  5                    1         10 1986-11-11        1988-04-20     
#>  6                    2          2 1956-02-05        1958-03-05     
#>  7                    2          6 1939-06-30        1942-03-28     
#>  8                    1          7 1985-06-21        1988-05-14     
#>  9                    2          5 1909-05-10        1911-07-01     
#> 10                    2          8 1961-08-06        1961-11-17     
#> # ℹ 3 more variables: cohort_3_0_to_inf <date>, cohort_2_0_to_inf <date>,
#> #   cohort_1_0_to_inf <date>

# }
```
