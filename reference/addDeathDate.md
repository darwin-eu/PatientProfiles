# Add date of death for individuals. Only death within the same observation period than `indexDate` will be observed.

Add date of death for individuals. Only death within the same
observation period than `indexDate` will be observed.

## Usage

``` r
addDeathDate(
  x,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  window = c(0, Inf),
  deathDateName = "date_of_death",
  name = NULL
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

- deathDateName:

  name of the new column to be added.

- name:

  Name of the new table. If `NULL`, a temporary table is returned.

## Value

table x with the added column with death information added.

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
  addDeathDate()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          3 1965-04-14        1984-04-18     
#>  2                    2         10 1954-05-16        1967-12-15     
#>  3                    1          2 1930-01-21        1930-08-14     
#>  4                    3          9 1960-08-28        1991-06-07     
#>  5                    1          4 2005-08-26        2006-04-23     
#>  6                    1          7 2006-11-09        2013-05-16     
#>  7                    3          5 1925-10-08        1940-04-07     
#>  8                    1          8 1955-09-19        1957-04-08     
#>  9                    1          6 1922-03-18        1927-01-07     
#> 10                    2          1 1908-04-14        1919-12-09     
#> # ℹ 1 more variable: date_of_death <date>

# }
```
