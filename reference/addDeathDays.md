# Add days to death for individuals. Only death within the same observation period than `indexDate` will be observed.

Add days to death for individuals. Only death within the same
observation period than `indexDate` will be observed.

## Usage

``` r
addDeathDays(
  x,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  window = c(0, Inf),
  deathDaysName = "days_to_death",
  name = NULL,
  type = "numeric"
)
```

## Arguments

- x:

  A table containing individuals in a CDM reference.

- indexDate:

  Name of a date column in `x`, or a single date to use for all rows,
  used as the reference date.

- censorDate:

  Date or name of a date column in `x` on which to censor follow-up. If
  `NULL`, no censoring is applied.

- window:

  Window or windows of time relative to `indexDate` to consider.

- deathDaysName:

  name of the new column to be added.

- name:

  Name of the new table. If `NULL`, a temporary table is returned.

- type:

  Type of the created column(s). Counts, days, age, and observation
  durations can be `"numeric"` or `"integer"`. Flag columns can also be
  `"logical"`. Field columns can use `"auto"` to preserve the source
  type, or can be converted to `"numeric"`, `"integer"`, `"logical"`, or
  `"character"`.

## Value

table x with the added column with death information added.

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
  addDeathDays()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1022-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          1 1915-11-27        1916-05-29     
#>  2                    2          3 1969-06-25        1970-03-30     
#>  3                    2          8 1945-11-07        1948-08-14     
#>  4                    2          9 1949-11-04        1958-02-22     
#>  5                    2          6 1931-10-17        1937-10-16     
#>  6                    3          4 1952-10-15        1967-10-26     
#>  7                    1          2 1980-03-29        1980-11-27     
#>  8                    3          5 1990-09-13        1995-05-26     
#>  9                    1          7 1979-01-03        1984-05-02     
#> 10                    3         10 1974-05-17        1987-09-08     
#> # ℹ 1 more variable: days_to_death <dbl>

# }
```
