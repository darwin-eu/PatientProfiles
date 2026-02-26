# Add a column with the individual birth date

Add a column with the individual birth date

## Usage

``` r
addDateOfBirth(
  x,
  dateOfBirthName = "date_of_birth",
  missingDay = 1,
  missingMonth = 1,
  imposeDay = FALSE,
  imposeMonth = FALSE,
  name = NULL
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

- name:

  Name of the new table, if NULL a temporary table is returned.

## Value

The function returns the table x with an extra column that contains the
date of birth.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addDateOfBirth()
#> # Source:   table<og_107_1772095328> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          8 1956-09-02        1960-11-23     
#>  2                    1          1 1941-08-06        1944-08-31     
#>  3                    2          4 1995-08-16        1996-10-05     
#>  4                    1          6 1963-07-12        1973-03-10     
#>  5                    1          5 1967-04-17        1968-03-07     
#>  6                    2          2 1947-12-13        1948-07-26     
#>  7                    1         10 1927-01-15        1938-05-21     
#>  8                    3          7 1950-09-27        1975-05-31     
#>  9                    1          3 1934-05-01        1940-11-11     
#> 10                    3          9 1985-04-16        2000-01-02     
#> # ℹ 1 more variable: date_of_birth <date>

# }
```
