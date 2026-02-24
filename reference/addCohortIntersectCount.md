# It creates columns to indicate number of occurrences of intersection with a cohort

It creates columns to indicate number of occurrences of intersection
with a cohort

## Usage

``` r
addCohortIntersectCount(
  x,
  targetCohortTable,
  targetCohortId = NULL,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  targetStartDate = "cohort_start_date",
  targetEndDate = "cohort_end_date",
  window = list(c(0, Inf)),
  nameStyle = "{cohort_name}_{window_name}",
  name = NULL
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- targetCohortTable:

  name of the cohort that we want to check for overlap.

- targetCohortId:

  vector of cohort definition ids to include.

- indexDate:

  Variable in x that contains the date to compute the intersection.

- censorDate:

  whether to censor overlap events at a specific date or a column date
  of x.

- targetStartDate:

  date of reference in cohort table, either for start (in overlap) or on
  its own (for incidence).

- targetEndDate:

  date of reference in cohort table, either for end (overlap) or NULL
  (if incidence).

- window:

  window to consider events of.

- nameStyle:

  naming of the added column or columns, should include required
  parameters.

- name:

  Name of the new table, if NULL a temporary table is returned.

## Value

table with added columns with overlap information.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
#> Warning: There are observation period end dates after the current date: 2026-02-24
#> ℹ The latest max observation period end date found is 2031-12-31

cdm$cohort1 |>
  addCohortIntersectCount(
    targetCohortTable = "cohort2"
  )
#> # Source:   table<og_004_1771937928> [?? x 7]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          1 1960-12-30        1970-01-13     
#>  2                    2          5 1924-06-10        1927-01-08     
#>  3                    1          2 1996-01-27        2024-01-29     
#>  4                    3          4 1931-08-24        1933-08-23     
#>  5                    1          6 1981-06-18        1985-11-15     
#>  6                    3          9 1920-03-18        1936-02-10     
#>  7                    2          8 1931-10-08        1941-12-27     
#>  8                    3         10 1942-01-22        1942-09-13     
#>  9                    3          7 1930-12-06        1932-12-05     
#> 10                    1          3 1986-10-23        1987-07-06     
#> # ℹ 3 more variables: cohort_1_0_to_inf <dbl>, cohort_3_0_to_inf <dbl>,
#> #   cohort_2_0_to_inf <dbl>

# }
```
