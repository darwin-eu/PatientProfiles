# Summarise variables using a set of estimate functions. The output will be a formatted summarised_result object.

Summarise variables using a set of estimate functions. The output will
be a formatted summarised_result object.

## Usage

``` r
summariseResult(
  table,
  group = list(),
  includeOverallGroup = FALSE,
  strata = list(),
  includeOverallStrata = TRUE,
  variables = NULL,
  estimates = NULL,
  counts = TRUE,
  weights = NULL
)
```

## Arguments

- table:

  Table with different records.

- group:

  List of groups to be considered.

- includeOverallGroup:

  TRUE or FALSE. If TRUE, results for an overall group will be reported
  when a list of groups has been specified.

- strata:

  List of the stratifications within each group to be considered.

- includeOverallStrata:

  TRUE or FALSE. If TRUE, results for an overall strata will be reported
  when a list of strata has been specified.

- variables:

  Variables to summarise, it can be a list to point to different set of
  estimate names.

- estimates:

  Estimates to obtain, it can be a list to point to different set of
  variables.

- counts:

  Whether to compute number of records and number of subjects.

- weights:

  Name of the column in the table that contains the weights to be used
  when measuring the estimates.

## Value

A summarised_result object with the summarised data of interest.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

x <- cdm$cohort1 |>
  addDemographics()

# summarise all variables with default estimates
result <- summariseResult(x)
#> ℹ The following estimates will be calculated:
#> • age: min, q25, median, q75, max
#> • cohort_end_date: min, q25, median, q75, max
#> • cohort_start_date: min, q25, median, q75, max
#> • future_observation: min, q25, median, q75, max
#> • prior_observation: min, q25, median, q75, max
#> • sex: count, percentage
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-26 08:43:18.018781
#> ✔ Summary finished, at 2026-02-26 08:43:18.100267
result
#> # A tibble: 31 × 13
#>    result_id cdm_name group_name group_level strata_name strata_level
#>        <int> <chr>    <chr>      <chr>       <chr>       <chr>       
#>  1         1 PP_MOCK  overall    overall     overall     overall     
#>  2         1 PP_MOCK  overall    overall     overall     overall     
#>  3         1 PP_MOCK  overall    overall     overall     overall     
#>  4         1 PP_MOCK  overall    overall     overall     overall     
#>  5         1 PP_MOCK  overall    overall     overall     overall     
#>  6         1 PP_MOCK  overall    overall     overall     overall     
#>  7         1 PP_MOCK  overall    overall     overall     overall     
#>  8         1 PP_MOCK  overall    overall     overall     overall     
#>  9         1 PP_MOCK  overall    overall     overall     overall     
#> 10         1 PP_MOCK  overall    overall     overall     overall     
#> # ℹ 21 more rows
#> # ℹ 7 more variables: variable_name <chr>, variable_level <chr>,
#> #   estimate_name <chr>, estimate_type <chr>, estimate_value <chr>,
#> #   additional_name <chr>, additional_level <chr>

# get only counts of records and subjects
result <- summariseResult(x, variables = character())
#> → Start summary of data, at 2026-02-26 08:43:18.416393
#> ✔ Summary finished, at 2026-02-26 08:43:18.545316
result
#> # A tibble: 2 × 13
#>   result_id cdm_name group_name group_level strata_name strata_level
#>       <int> <chr>    <chr>      <chr>       <chr>       <chr>       
#> 1         1 PP_MOCK  overall    overall     overall     overall     
#> 2         1 PP_MOCK  overall    overall     overall     overall     
#> # ℹ 7 more variables: variable_name <chr>, variable_level <chr>,
#> #   estimate_name <chr>, estimate_type <chr>, estimate_value <chr>,
#> #   additional_name <chr>, additional_level <chr>

# specify variables and estimates
result <- summariseResult(
  table = x,
  variables = c("cohort_start_date", "age"),
  estimates = c("mean", "median", "density")
)
#> ℹ The following estimates will be calculated:
#> • cohort_start_date: mean, median, density
#> • age: mean, median, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-26 08:43:19.026757
#> ✔ Summary finished, at 2026-02-26 08:43:19.119749
result
#> # A tibble: 2,054 × 13
#>    result_id cdm_name group_name group_level strata_name strata_level
#>        <int> <chr>    <chr>      <chr>       <chr>       <chr>       
#>  1         1 PP_MOCK  overall    overall     overall     overall     
#>  2         1 PP_MOCK  overall    overall     overall     overall     
#>  3         1 PP_MOCK  overall    overall     overall     overall     
#>  4         1 PP_MOCK  overall    overall     overall     overall     
#>  5         1 PP_MOCK  overall    overall     overall     overall     
#>  6         1 PP_MOCK  overall    overall     overall     overall     
#>  7         1 PP_MOCK  overall    overall     overall     overall     
#>  8         1 PP_MOCK  overall    overall     overall     overall     
#>  9         1 PP_MOCK  overall    overall     overall     overall     
#> 10         1 PP_MOCK  overall    overall     overall     overall     
#> # ℹ 2,044 more rows
#> # ℹ 7 more variables: variable_name <chr>, variable_level <chr>,
#> #   estimate_name <chr>, estimate_type <chr>, estimate_value <chr>,
#> #   additional_name <chr>, additional_level <chr>

# different estimates for each variable
result <- summariseResult(
  table = x,
  variables = list(c("age", "prior_observation"), "sex"),
  estimates = list(c("min", "max"), c("count", "percentage"))
)
#> ℹ The following estimates will be calculated:
#> • age: min, max
#> • prior_observation: min, max
#> • sex: count, percentage
#> → Start summary of data, at 2026-02-26 08:43:19.600459
#> ✔ Summary finished, at 2026-02-26 08:43:20.029971

# }
```
