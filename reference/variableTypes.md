# Classify the variables between 5 types: "numeric", "categorical", "logical", "date", "integer", or NA.

Classify the variables between 5 types: "numeric", "categorical",
"logical", "date", "integer", or NA.

## Usage

``` r
variableTypes(table)
```

## Arguments

- table:

  Tibble.

## Value

Tibble with the variables type and classification.

## Examples

``` r
# \donttest{
library(PatientProfiles)
library(dplyr, warn.conflicts = TRUE)

x <- tibble(
  person_id = c(1, 2),
  start_date = as.Date(c("2020-05-02", "2021-11-19")),
  asthma = c(0, 1)
)

variableTypes(x)
#> # A tibble: 3 × 2
#>   variable_name variable_type
#>   <chr>         <chr>        
#> 1 person_id     numeric      
#> 2 start_date    date         
#> 3 asthma        numeric      
# }
```
