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

cdm$cohort1 |>
  addCohortIntersectFlag(
    targetCohortTable = "cohort2"
  )
#> # Source:   table<og_039_1772095295> [?? x 7]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          2 1918-09-16        1926-07-26     
#>  2                    3         10 1957-08-06        1993-07-28     
#>  3                    2          5 1926-01-20        1936-12-22     
#>  4                    2          4 1922-07-30        1934-09-28     
#>  5                    2          6 1914-07-24        1920-01-31     
#>  6                    3          8 1999-01-14        2009-02-13     
#>  7                    2          3 1917-03-27        1918-05-26     
#>  8                    2          9 1966-09-13        1970-09-16     
#>  9                    1          7 2010-07-29        2018-11-02     
#> 10                    2          1 1967-04-28        1974-01-08     
#> # ℹ 3 more variables: cohort_1_0_to_inf <dbl>, cohort_3_0_to_inf <dbl>,
#> #   cohort_2_0_to_inf <dbl>

# }
```
