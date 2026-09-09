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
  weights = NULL,
  customEstimates = list()
)
```

## Arguments

- table:

  A table to process.

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

- customEstimates:

  Named list of custom functions. Each function must accept a variable
  vector as its first argument and return one numeric value. If
  `weights` are supplied, they are passed as the second argument when
  the function provides one; otherwise the estimate is calculated
  without weights.

## Value

A summarised_result object with the summarised data of interest.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/Rtmp52x3ty/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

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
#>   the database side.
#> → Start summary of data, at 2026-09-09 00:42:46.120178
#> ✔ Summary finished, at 2026-09-09 00:42:46.217114
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
#> → Start summary of data, at 2026-09-09 00:42:46.574303
#> ✔ Summary finished, at 2026-09-09 00:42:46.67417
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
#>   the database side.
#> → Start summary of data, at 2026-09-09 00:42:47.180473
#> ✔ Summary finished, at 2026-09-09 00:42:47.306861
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
#> → Start summary of data, at 2026-09-09 00:42:47.869379
#> ✔ Summary finished, at 2026-09-09 00:42:48.146818

# add a custom estimate
ess <- function(x) sum(x^2) / sum(x)
result <- summariseResult(
  table = x,
  variables = "age",
  estimates = "ess",
  customEstimates = list(ess = ess)
)
#> ℹ The following estimates will be calculated:
#> • age: ess
#> ! Table is collected to memory because custom estimates are evaluated in R.
#> → Start summary of data, at 2026-09-09 00:42:48.784251
#> ✔ Summary finished, at 2026-09-09 00:42:48.84743

# }
```
