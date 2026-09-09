# Add flag for death for individuals. Only death within the same observation period than `indexDate` will be observed.

Add flag for death for individuals. Only death within the same
observation period than `indexDate` will be observed.

## Usage

``` r
addDeathFlag(
  x,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  window = c(0, Inf),
  deathFlagName = "death",
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

- deathFlagName:

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

The original table (`x`) with one added column per window indicating
whether the individual's death record intersects that window. The value
of the column can either indicate presence (1 or TRUE), no intersection
(0 or FALSE), or NA if the individual is not in observation at any time
of the window. The representation depends on `type`.

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
  addDeathFlag()
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1022-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date death
#>                   <int>      <int> <date>            <date>          <dbl>
#>  1                    2          4 1928-06-03        1931-12-01          0
#>  2                    1         10 1984-09-28        1987-11-30          0
#>  3                    1          9 1932-03-10        1933-12-11          0
#>  4                    1          2 1998-05-25        2003-04-01          0
#>  5                    2          3 1959-05-09        1962-01-27          0
#>  6                    1          5 1958-10-08        1968-09-10          0
#>  7                    3          8 1969-03-13        1977-08-04          0
#>  8                    3          1 1977-09-12        1979-12-28          0
#>  9                    2          6 1964-11-13        1965-07-18          0
#> 10                    2          7 1983-05-10        1992-03-31          0

# }
```
