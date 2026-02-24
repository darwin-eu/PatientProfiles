# Get the name of the start date column for a certain table in the cdm

Get the name of the start date column for a certain table in the cdm

## Usage

``` r
startDateColumn(tableName)
```

## Arguments

- tableName:

  Name of the table.

## Value

Name of the start date column in that table.

## Examples

``` r
# \donttest{
library(PatientProfiles)

startDateColumn("condition_occurrence")
#> [1] "condition_start_date"
# }
```
