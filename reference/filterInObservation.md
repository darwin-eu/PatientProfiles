# Filter the rows of a `cdm_table` to the ones in observation that `indexDate` is in observation.

Filter the rows of a `cdm_table` to the ones in observation that
`indexDate` is in observation.

## Usage

``` r
filterInObservation(x, indexDate)
```

## Arguments

- x:

  A `cdm_table` object.

- indexDate:

  Name of a column of x that is a date.

## Value

A `cdm_table` that is a subset of the original table.

## Examples

``` r
if (FALSE) { # \dontrun{
library(PatientProfiles)
library(omock)

cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")

cdm$condition_occurrence |>
  filterInObservation(indexDate = "condition_start_date")

} # }
```
