# Filter a cohort according to cohort_definition_id column, the result is not computed into a table. only a query is added. Used usually as internal functions of other packages.

Filter a cohort according to cohort_definition_id column, the result is
not computed into a table. only a query is added. Used usually as
internal functions of other packages.

## Usage

``` r
filterCohortId(cohort, cohortId = NULL)
```

## Arguments

- cohort:

  A `cohort_table` object.

- cohortId:

  A vector with cohort ids.

## Value

A `cohort_table` object.
