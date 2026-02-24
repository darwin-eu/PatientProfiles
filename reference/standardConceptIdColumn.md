# Get the name of the standard concept_id column for a certain table in the cdm

Get the name of the standard concept_id column for a certain table in
the cdm

## Usage

``` r
standardConceptIdColumn(tableName)
```

## Arguments

- tableName:

  Name of the table.

## Value

Name of the concept_id column in that table.

## Examples

``` r
# \donttest{
library(PatientProfiles)

standardConceptIdColumn("condition_occurrence")
#> [1] "condition_concept_id"
# }
```
