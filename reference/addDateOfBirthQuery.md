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

  A table containing individuals in a CDM reference.

- dateOfBirthName:

  Name of the date-of-birth column to add.

- missingDay:

  Day of the month assigned when day of birth is missing.

- missingMonth:

  Month of the year assigned when month of birth is missing.

- imposeDay:

  If `TRUE`, day of birth is treated as missing for all individuals.

- imposeMonth:

  If `TRUE`, month of birth is treated as missing for all individuals.

## Value

The function returns the table x with an extra column that contains the
date of birth.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmpSvnpxc/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

cdm$cohort1 |>
  addDateOfBirthQuery()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          3 1978-02-10        1979-05-09     
#>  2                    2          5 1946-08-04        1946-12-01     
#>  3                    2          2 1956-01-31        1961-03-06     
#>  4                    2         10 1952-03-02        1957-07-01     
#>  5                    3          9 1930-10-04        1931-02-08     
#>  6                    3          4 1970-05-25        1971-05-31     
#>  7                    1          7 1937-02-22        1943-03-01     
#>  8                    3          6 1975-06-14        1977-12-26     
#>  9                    3          1 1958-01-13        1976-09-09     
#> 10                    2          8 1970-07-28        1996-01-24     
#> # ℹ 1 more variable: date_of_birth <date>

# }
```
