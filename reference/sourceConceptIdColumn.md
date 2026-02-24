# Get the name of the source concept_id column for a certain table in the cdm

Get the name of the source concept_id column for a certain table in the
cdm

## Usage

``` r
sourceConceptIdColumn(tableName)
```

## Arguments

- tableName:

  Name of the table.

## Value

Name of the source_concept_id column in that table.

## Examples

``` r
# \donttest{
library(PatientProfiles)

sourceConceptIdColumn("condition_occurrence")
#> [1] "condition_source_concept_id"
# }
```
