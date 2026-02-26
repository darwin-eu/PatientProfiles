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
  name = NULL
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- indexDate:

  Variable in x that contains the window origin.

- censorDate:

  Name of a column to stop followup.

- window:

  window to consider events over.

- deathFlagName:

  name of the new column to be added.

- name:

  Name of the new table, if NULL a temporary table is returned.

## Value

table x with the added column with death information added.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addDeathFlag()
#> # Source:   table<og_120_1772095736> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date death
#>                   <int>      <int> <date>            <date>          <dbl>
#>  1                    1          5 1951-06-17        1952-01-02          0
#>  2                    2          8 1920-07-09        1927-03-22          0
#>  3                    3          6 1954-03-10        1955-06-01          0
#>  4                    3          2 1963-02-28        1975-08-04          0
#>  5                    2          9 1946-11-19        1949-04-28          0
#>  6                    2         10 1962-11-23        1973-11-07          0
#>  7                    2          3 1926-10-01        1928-10-24          0
#>  8                    2          7 2001-04-05        2001-12-14          0
#>  9                    2          4 1986-09-28        1993-10-09          0
#> 10                    1          1 1999-08-13        2000-05-16          0

# }
```
