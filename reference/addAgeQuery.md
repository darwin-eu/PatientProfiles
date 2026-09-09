# Query to add the age of the individuals at a certain date

Same as
[`addAge()`](https://darwin-eu.github.io/PatientProfiles/reference/addAge.md),
except query is not computed to a table.

## Usage

``` r
addAgeQuery(
  x,
  indexDate = "cohort_start_date",
  ageName = "age",
  ageGroup = NULL,
  ageMissingMonth = 1,
  ageMissingDay = 1,
  ageImposeMonth = FALSE,
  ageImposeDay = FALSE,
  ageUnit = "years",
  missingAgeGroupValue = "None",
  type = "numeric"
)
```

## Arguments

- x:

  A table containing individuals in a CDM reference.

- indexDate:

  Name of a date column in `x`, or a single date to use for all rows,
  used as the reference date.

- ageName:

  Name of the age column to add.

- ageGroup:

  If not `NULL`, a list of age-group vectors.

- ageMissingMonth:

  Month of the year assigned when month of birth is missing.

- ageMissingDay:

  Day of the month assigned when day of birth is missing.

- ageImposeMonth:

  If `TRUE`, month of birth is treated as missing for all individuals.

- ageImposeDay:

  If `TRUE`, day of birth is treated as missing for all individuals.

- ageUnit:

  Unit in which to express age: `"years"`, `"months"`, or `"days"`.

- missingAgeGroupValue:

  Value to use when age is missing.

- type:

  Type of the created column(s). Counts, days, age, and observation
  durations can be `"numeric"` or `"integer"`. Flag columns can also be
  `"logical"`. Field columns can use `"auto"` to preserve the source
  type, or can be converted to `"numeric"`, `"integer"`, `"logical"`, or
  `"character"`.

## Value

tibble with the age column added.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/Rtmp52x3ty/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

cdm$cohort1 |>
  addAgeQuery()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1022-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date   age
#>                   <int>      <int> <date>            <date>          <dbl>
#>  1                    2          7 1936-04-26        1936-05-05          8
#>  2                    3         10 1925-03-06        1926-01-12          2
#>  3                    2          2 1966-04-11        1966-09-21         33
#>  4                    1          1 1968-06-29        1974-05-05          2
#>  5                    2          8 1958-01-13        1974-07-17         12
#>  6                    1          4 1960-09-11        1973-06-30          5
#>  7                    1          9 1957-09-01        1958-04-06         18
#>  8                    1          3 1991-02-13        1991-11-04         20
#>  9                    2          6 1936-06-28        1944-11-29         17
#> 10                    1          5 1947-02-19        1959-04-01          3

# }
```
