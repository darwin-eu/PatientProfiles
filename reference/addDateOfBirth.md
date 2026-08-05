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

- name:

  Name of the new table. If `NULL`, a temporary table is returned.

## Value

The function returns the table x with an extra column that contains the
date of birth.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmpsAr3d4/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

cdm$cohort1 |>
  addDateOfBirth()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          3 1927-01-29        1927-04-11     
#>  2                    2          5 1918-05-25        1943-07-20     
#>  3                    1          8 1926-09-16        1927-07-22     
#>  4                    2          6 1976-12-10        1983-10-04     
#>  5                    3          9 1958-03-07        1959-07-12     
#>  6                    1          2 1951-01-21        1957-10-02     
#>  7                    3          1 1949-12-23        1983-06-21     
#>  8                    3         10 1982-05-05        1991-04-26     
#>  9                    1          7 1958-08-28        1961-06-13     
#> 10                    3          4 1920-09-24        1927-07-08     
#> # ℹ 1 more variable: date_of_birth <date>

# }
```
