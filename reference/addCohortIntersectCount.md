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

cdm$cohort1 |>
  addCohortIntersectCount(
    targetCohortTable = "cohort2"
  )
#> # Source:   table<og_006_1772095280> [?? x 7]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          6 1941-06-04        1942-08-08     
#>  2                    3         10 1943-06-09        1947-09-05     
#>  3                    2          3 1964-03-01        1964-06-24     
#>  4                    3          9 1916-12-17        1917-03-07     
#>  5                    1          4 1978-04-06        1980-05-22     
#>  6                    2          2 1956-08-20        1982-07-05     
#>  7                    3          8 1952-12-02        1969-11-03     
#>  8                    2          5 1950-08-19        1975-07-22     
#>  9                    3          1 1945-07-30        1956-10-30     
#> 10                    1          7 1917-10-08        1926-02-06     
#> # ℹ 3 more variables: cohort_3_0_to_inf <dbl>, cohort_1_0_to_inf <dbl>,
#> #   cohort_2_0_to_inf <dbl>

# }
```
