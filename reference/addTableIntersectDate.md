# Compute date of intersect with an omop table.

Compute date of intersect with an omop table.

## Usage

``` r
addTableIntersectDate(
  x,
  tableName,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  window = list(c(0, Inf)),
  targetDate = startDateColumn(tableName),
  inObservation = TRUE,
  order = "first",
  nameStyle = "{table_name}_{window_name}",
  name = NULL
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

## Value

table with added columns with intersect information.

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
  addTableIntersectDate(tableName = "visit_occurrence")
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1022-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          4 1938-09-12        1939-07-18     
#>  2                    2          6 1959-02-26        1969-03-03     
#>  3                    2          2 1953-01-05        1964-01-13     
#>  4                    2          5 1939-08-12        1941-11-05     
#>  5                    2          3 2007-11-23        2008-03-28     
#>  6                    2          8 1968-07-19        1968-10-20     
#>  7                    3          9 1989-05-01        1999-06-15     
#>  8                    2          1 1997-06-01        2007-12-27     
#>  9                    1         10 1937-01-14        1937-06-27     
#> 10                    2          7 1965-03-19        1971-03-03     
#> # ℹ 1 more variable: visit_occurrence_0_to_inf <date>

# }
```
