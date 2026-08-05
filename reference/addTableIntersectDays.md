# Compute time to intersect with an omop table.

Compute time to intersect with an omop table.

## Usage

``` r
addTableIntersectDays(
  x,
  tableName,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  window = list(c(0, Inf)),
  targetDate = startDateColumn(tableName),
  inObservation = TRUE,
  order = "first",
  nameStyle = "{table_name}_{window_name}",
  name = NULL,
  type = "numeric"
)
```

## Arguments

- x:

  A table containing individuals in a CDM reference.

- tableName:

  Names of one or more OMOP CDM tables to intersect with.

- indexDate:

  Name of a date column in `x`, or a single date to use for all rows,
  used as the reference date.

- censorDate:

  Date or name of a date column in `x` on which to censor follow-up. If
  `NULL`, no censoring is applied.

- window:

  Window or windows of time relative to `indexDate` to consider.

- targetDate:

  Name or names of date columns in the target tables to use for the
  intersection.

- inObservation:

  If `TRUE`, only records that occur during an observation period are
  considered.

- order:

  Which record to use when multiple records occur in a window: `"first"`
  or `"last"`.

- nameStyle:

  Naming pattern for the added column or columns. It should include the
  required formatting variables. If more than one `tableName` is
  provided, it must include `{table_name}`.

- name:

  Name of the new table. If `NULL`, a temporary table is returned.

- type:

  Type of the created column(s). Counts, days, age, and observation
  durations can be `"numeric"` or `"integer"`. Flag columns can also be
  `"logical"`. Field columns can use `"auto"` to preserve the source
  type, or can be converted to `"numeric"`, `"integer"`, `"logical"`, or
  `"character"`.

## Value

table with added columns with intersect information.

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
  addTableIntersectDays(tableName = "visit_occurrence")
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1         10 1982-03-31        1983-11-07     
#>  2                    2          8 1963-05-07        1985-07-22     
#>  3                    1          4 1932-05-02        1965-09-18     
#>  4                    1          7 1965-12-19        1975-02-22     
#>  5                    3          5 1952-09-23        1957-09-07     
#>  6                    1          9 1946-11-25        1947-02-08     
#>  7                    1          1 1968-01-29        1968-04-21     
#>  8                    2          2 1921-04-13        1929-05-27     
#>  9                    2          6 1945-12-07        1946-09-07     
#> 10                    1          3 1966-09-25        1966-11-04     
#> # ℹ 1 more variable: visit_occurrence_0_to_inf <dbl>

# }
```
