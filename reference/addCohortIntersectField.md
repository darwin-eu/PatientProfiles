# It creates a column with the field of a desired intersection

It creates a column with the field of a desired intersection

## Usage

``` r
addCohortIntersectField(
  x,
  targetCohortTable,
  field,
  targetCohortId = NULL,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  targetDate = "cohort_start_date",
  order = "first",
  window = list(c(0, Inf)),
  nameStyle = "{cohort_name}_{field}_{window_name}",
  name = NULL
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- targetCohortTable:

  name of the cohort that we want to check for overlap.

- field:

  Column of interest in the targetCohort.

- targetCohortId:

  vector of cohort definition ids to include.

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

table with added columns with overlap information.

## Examples

``` r
# \donttest{
library(PatientProfiles)
library(dplyr)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort2 <- cdm$cohort2 |>
  mutate(even = if_else(subject_id %% 2, "yes", "no")) |>
  compute(name = "cohort2")

cdm$cohort1 |>
  addCohortIntersectFlag(
    targetCohortTable = "cohort2"
  )
#> # Source:   table<og_029_1772095689> [?? x 7]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          7 1958-03-20        1965-11-22     
#>  2                    2          1 1973-04-05        1986-03-27     
#>  3                    2          2 1967-12-06        1987-09-22     
#>  4                    2          4 1988-03-06        1997-09-26     
#>  5                    3          5 1995-09-19        1996-06-17     
#>  6                    3          3 1984-11-16        2009-06-10     
#>  7                    1          6 1919-08-03        1924-03-22     
#>  8                    3         10 1980-02-26        2003-12-11     
#>  9                    1          9 1961-12-05        1983-03-17     
#> 10                    2          8 1919-08-10        1922-05-11     
#> # ℹ 3 more variables: cohort_2_0_to_inf <dbl>, cohort_1_0_to_inf <dbl>,
#> #   cohort_3_0_to_inf <dbl>

# }
```
