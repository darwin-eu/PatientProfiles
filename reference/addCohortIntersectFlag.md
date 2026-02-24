# It creates columns to indicate the presence of cohorts

It creates columns to indicate the presence of cohorts

## Usage

``` r
addCohortIntersectFlag(
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
#> ℹ The latest max observation period end date found is 2032-09-26

cdm$cohort1 |>
  addCohortIntersectFlag(
    targetCohortTable = "cohort2"
  )
#> # Source:   table<og_027_1771936186> [?? x 7]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3         10 1929-03-19        1934-08-31     
#>  2                    3          2 1966-09-27        1966-11-25     
#>  3                    1          8 1977-03-26        1979-03-11     
#>  4                    1          4 1983-11-29        1984-04-02     
#>  5                    3          6 1952-08-18        1955-07-07     
#>  6                    2          3 2008-11-22        2010-08-14     
#>  7                    1          9 2032-09-14        2032-09-20     
#>  8                    3          5 1987-02-28        1988-05-07     
#>  9                    2          1 1978-07-12        1981-11-04     
#> 10                    3          7 1936-05-03        1947-12-31     
#> # ℹ 3 more variables: cohort_1_0_to_inf <dbl>, cohort_2_0_to_inf <dbl>,
#> #   cohort_3_0_to_inf <dbl>

# }
```
