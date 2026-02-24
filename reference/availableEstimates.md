# Show the available estimates that can be used for the different variable_type supported.

Show the available estimates that can be used for the different
variable_type supported.

## Usage

``` r
availableEstimates(variableType = NULL, fullQuantiles = FALSE)
```

## Arguments

- variableType:

  A set of variable types.

- fullQuantiles:

  Whether to display the exact quantiles that can be computed or only
  the qXX to summarise all of them.

## Value

A tibble with the available estimates.

## Examples

``` r
# \donttest{
library(PatientProfiles)

availableEstimates()
#> # A tibble: 59 × 4
#>    variable_type estimate_name      estimate_description           estimate_type
#>    <chr>         <chr>              <chr>                          <chr>        
#>  1 date          mean               mean of the variable of inter… date         
#>  2 date          sd                 standard deviation of the var… numeric      
#>  3 date          median             median of the variable of int… date         
#>  4 date          qXX                qualtile of XX% the variable … date         
#>  5 date          min                minimum of the variable of in… date         
#>  6 date          max                maximum of the variable of in… date         
#>  7 date          count_missing      number of missing values.      integer      
#>  8 date          percentage_missing percentage of missing values   percentage   
#>  9 numeric       sum                sum of all the values for the… numeric      
#> 10 numeric       mean               mean of the variable of inter… numeric      
#> # ℹ 49 more rows
availableEstimates("numeric")
#> # A tibble: 22 × 4
#>    variable_type estimate_name      estimate_description           estimate_type
#>    <chr>         <chr>              <chr>                          <chr>        
#>  1 numeric       sum                sum of all the values for the… numeric      
#>  2 numeric       mean               mean of the variable of inter… numeric      
#>  3 numeric       sd                 standard deviation of the var… numeric      
#>  4 numeric       median             median of the variable of int… numeric      
#>  5 numeric       qXX                qualtile of XX% the variable … numeric      
#>  6 numeric       min                minimum of the variable of in… numeric      
#>  7 numeric       max                maximum of the variable of in… numeric      
#>  8 numeric       count_missing      number of missing values.      integer      
#>  9 numeric       percentage_missing percentage of missing values   percentage   
#> 10 numeric       count              count number of `1`. Only all… integer      
#> # ℹ 12 more rows
availableEstimates(c("numeric", "categorical"))
#> # A tibble: 26 × 4
#>    variable_type estimate_name      estimate_description           estimate_type
#>    <chr>         <chr>              <chr>                          <chr>        
#>  1 numeric       sum                sum of all the values for the… numeric      
#>  2 numeric       mean               mean of the variable of inter… numeric      
#>  3 numeric       sd                 standard deviation of the var… numeric      
#>  4 numeric       median             median of the variable of int… numeric      
#>  5 numeric       qXX                qualtile of XX% the variable … numeric      
#>  6 numeric       min                minimum of the variable of in… numeric      
#>  7 numeric       max                maximum of the variable of in… numeric      
#>  8 numeric       count_missing      number of missing values.      integer      
#>  9 numeric       percentage_missing percentage of missing values   percentage   
#> 10 numeric       count              count number of `1`. Only all… integer      
#> # ℹ 16 more rows
# }
```
