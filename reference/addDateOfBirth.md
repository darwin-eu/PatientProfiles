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

  Table in the cdm that contains 'person_id' or 'subject_id'.

- dateOfBirthName:

  Name of the column to be added with the date of birth.

- missingDay:

  Day of the individuals with no or imposed day of birth.

- missingMonth:

  Month of the individuals with no or imposed month of birth.

- imposeDay:

  Whether to impose day of birth.

- imposeMonth:

  Whether to impose month of birth.

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
#> # Source:   table<og_095_1771936219> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          7 1933-03-05        1936-06-24     
#>  2                    1          3 1961-07-22        1970-08-06     
#>  3                    3          9 1944-08-04        1945-10-31     
#>  4                    3         10 1957-06-05        1960-09-23     
#>  5                    3          5 1959-03-14        1959-07-23     
#>  6                    3          2 1999-01-10        2005-07-14     
#>  7                    2          8 1915-07-17        1965-07-14     
#>  8                    2          4 1986-10-11        1987-05-26     
#>  9                    3          1 1969-01-23        1975-10-18     
#> 10                    2          6 1991-09-02        1993-03-17     
#> # ℹ 1 more variable: date_of_birth <date>

# }
```
