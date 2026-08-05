# Compute number of intersect with an omop table.

Compute number of intersect with an omop table.

## Usage

``` r
addTableIntersectCount(
  x,
  tableName,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  window = list(c(0, Inf)),
  targetStartDate = startDateColumn(tableName),
  targetEndDate = endDateColumn(tableName),
  inObservation = TRUE,
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

- targetStartDate:

  Name or names of start-date columns in the target tables to use for
  the intersection.

- targetEndDate:

  Name or names of end-date columns in the target tables to use for the
  intersection. If `NULL`, the target is treated as a point event.

- inObservation:

  If `TRUE`, only records that occur during an observation period are
  considered.

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

The original table (`x`) with one added column per intersection with the
desired table in a specific window. One column will be created for each
combination of window and table. The value of the column will be the
number of intersections in the desired window, or NA if the individual
is not in observation at any time in the window.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/RtmpIdk5b4/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

cdm$cohort1 |>
  addTableIntersectCount(tableName = "visit_occurrence")
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    2          8 1939-01-14        1974-06-21     
#>  2                    1          6 1990-07-23        1992-11-26     
#>  3                    2          9 1911-08-28        1914-07-23     
#>  4                    1          2 1955-03-08        1959-11-24     
#>  5                    2         10 1914-10-30        1917-06-26     
#>  6                    3          3 1928-12-30        1932-05-28     
#>  7                    1          5 1959-09-25        1960-05-01     
#>  8                    1          4 1961-08-11        1973-10-17     
#>  9                    3          7 1933-05-28        1934-02-07     
#> 10                    1          1 1929-09-04        1937-08-25     
#> # ℹ 1 more variable: visit_occurrence_0_to_inf <dbl>

# }
```
