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

  Table with individuals in the cdm.

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

  Name of the new table, if NULL a temporary table is returned.

## Value

The x table with the categorical variable added.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
#> Warning: There are observation period end dates after the current date: 2026-02-26
#> ℹ The latest max observation period end date found is 2026-07-13

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
