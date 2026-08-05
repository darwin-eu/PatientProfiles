# Categorize a numeric variable

Categorize a numeric variable

## Usage

``` r
addCategories(
  x,
  variable,
  categories,
  missingCategoryValue = "None",
  overlap = FALSE,
  includeLowerBound = TRUE,
  includeUpperBound = TRUE,
  name = NULL
)
```

## Arguments

- x:

  A table containing individuals in a CDM reference.

- variable:

  Target variable that we want to categorize.

- categories:

  List of lists of named categories with lower and upper limit.

- missingCategoryValue:

  Value to assign to those individuals not in any named category. If
  NULL or NA, missing values will not be changed.

- overlap:

  TRUE if the categories given overlap.

- includeLowerBound:

  Whether to include the lower bound in the group.

- includeUpperBound:

  Whether to include the upper bound in the group.

- name:

  Name of the new table. If `NULL`, a temporary table is returned.

## Value

The x table with the categorical variable added.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmpsAr3d4/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

result <- cdm$cohort1 |>
  addAge() |>
  addCategories(
    variable = "age",
    categories = list("age_group" = list(
      "0 to 39" = c(0, 39), "40 to 79" = c(40, 79), "80 to 150" = c(80, 150)
    ))
  )

# }
```
