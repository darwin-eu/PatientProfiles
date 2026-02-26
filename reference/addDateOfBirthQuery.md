# Query to add a column with the individual birth date

Same as
[`addDateOfBirth()`](https://darwin-eu.github.io/PatientProfiles/reference/addDateOfBirth.md),
except query is not computed to a table.

## Usage

``` r
addDateOfBirthQuery(
  x,
  dateOfBirthName = "date_of_birth",
  missingDay = 1,
  missingMonth = 1,
  imposeDay = FALSE,
  imposeMonth = FALSE
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- dateOfBirthName:

  dateOfBirth column name.

- missingDay:

  day of the month assigned to individuals with missing day of birth.

- missingMonth:

  Month of the year assigned to individuals with missing month of birth.

- imposeDay:

  TRUE or FALSE. Whether the day of the date of birth will be considered
  as missing for all the individuals.

- imposeMonth:

  TRUE or FALSE. Whether the month of the date of birth will be
  considered as missing for all the individuals.

## Value

The function returns the table x with an extra column that contains the
date of birth.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addDateOfBirthQuery()
#> # Source:   SQL [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          2 1912-12-15        1921-02-27     
#>  2                    2          9 1917-09-02        1918-01-25     
#>  3                    3          8 1967-11-03        1967-12-18     
#>  4                    2          4 1939-04-13        1940-05-10     
#>  5                    2          7 1994-05-11        1997-09-04     
#>  6                    1          3 1905-12-06        1919-05-22     
#>  7                    1         10 1951-02-16        1974-10-16     
#>  8                    2          1 1947-11-30        1956-05-23     
#>  9                    1          5 1955-10-22        1957-05-07     
#> 10                    3          6 1968-11-21        1969-09-17     
#> # ℹ 1 more variable: date_of_birth <date>

# }
```
