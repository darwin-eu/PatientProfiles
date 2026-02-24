# Query to add a column with the individual birth date

\`r lifecycle::badge("experimental")\` Same as \`addDateOfBirth()\`,
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
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          8 1946-11-24        1952-05-13     
#>  2                    1          6 1907-06-12        1910-01-10     
#>  3                    1          4 1967-09-15        1979-09-26     
#>  4                    2          9 1955-09-09        1978-10-18     
#>  5                    2         10 1968-04-04        1995-06-13     
#>  6                    1          7 1943-03-05        1957-05-02     
#>  7                    3          2 1991-09-28        1995-08-14     
#>  8                    1          1 1971-12-18        1987-11-12     
#>  9                    1          5 1945-10-01        1951-06-08     
#> 10                    2          3 1985-02-07        2006-12-15     
#> # ℹ 1 more variable: date_of_birth <date>

# }
```
