# Compute a flag intersect with an omop table

Compute a flag intersect with an omop table

## Usage

``` r
addTableIntersectFlag(
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
combination of window and table. The value of the column can either
indicate presence (1 or TRUE), no intersection (0 or FALSE), or NA if
the individual is not in observation at any time of the window. The
representation depends on `type`.

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
  addTableIntersectFlag(tableName = "visit_occurrence")
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1          8 1951-12-08        1967-06-26     
#>  2                    3          6 1976-01-01        1983-05-05     
#>  3                    1          9 1962-08-14        1969-08-08     
#>  4                    3          1 1940-11-06        1959-03-18     
#>  5                    1          4 1942-03-13        1960-12-05     
#>  6                    1          3 1912-01-10        1917-12-18     
#>  7                    3         10 1976-09-04        1977-12-25     
#>  8                    2          5 1944-02-26        1944-05-18     
#>  9                    3          2 2002-06-12        2003-09-20     
#> 10                    1          7 1947-05-30        1957-05-14     
#> # ℹ 1 more variable: visit_occurrence_0_to_inf <dbl>

# }
```
