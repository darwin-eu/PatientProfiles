# Get the name of the end date column for a certain table in the cdm

Get the name of the end date column for a certain table in the cdm

## Usage

``` r
endDateColumn(tableName)
```

## Arguments

- tableName:

  Name of the table.

## Value

Name of the end date column in that table.

## Examples

``` r
# \donttest{
library(PatientProfiles)

endDateColumn("condition_occurrence")
#> [1] "condition_end_date"
# }
```
