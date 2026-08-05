# Intersecting the cohort with columns of an OMOP table of user's choice. It will add an extra column to the cohort, indicating the intersected entries with the target columns in a window of the user's choice.

Intersecting the cohort with columns of an OMOP table of user's choice.
It will add an extra column to the cohort, indicating the intersected
entries with the target columns in a window of the user's choice.

## Usage

``` r
addTableIntersectField(
  x,
  tableName,
  field,
  indexDate = "cohort_start_date",
  censorDate = NULL,
  window = list(c(0, Inf)),
  targetDate = startDateColumn(tableName),
  inObservation = TRUE,
  order = "first",
  allowDuplicates = FALSE,
  nameStyle = "{table_name}_{field}_{window_name}",
  name = NULL,
  type = "auto"
)
```

## Arguments

- x:

  A table containing individuals in a CDM reference.

- tableName:

  Names of one or more OMOP CDM tables to intersect with.

- field:

  Name or names of columns in the target tables to add to `x`.

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

- allowDuplicates:

  Whether to allow multiple records for the same person, target, and
  date. If `TRUE`, multiple values are collapsed into a
  semicolon-separated character value; otherwise, duplicates result in
  an error.

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
#> ℹ /tmp/RtmpB2T0r9/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

cdm$cohort1 |>
  addTableIntersectField(
    tableName = "visit_occurrence",
    field = "visit_concept_id",
    order = "last",
    window = c(-Inf, -1)
  )
#> # A query:  ?? x 5
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    3          6 1952-05-23        1971-10-17     
#>  2                    3          7 1942-02-06        1950-12-18     
#>  3                    1          8 1996-04-15        2001-01-09     
#>  4                    2          1 1978-08-04        1986-09-28     
#>  5                    3          5 1953-12-28        1966-06-06     
#>  6                    2          4 1968-03-30        1969-11-07     
#>  7                    3          2 1933-06-10        1933-09-17     
#>  8                    3         10 1975-05-14        1979-12-04     
#>  9                    3          3 1985-08-10        2003-06-29     
#> 10                    3          9 1972-01-17        1985-07-05     
#> # ℹ 1 more variable: visit_occurrence_visit_concept_id_minf_to_m1 <int>

# }
```
