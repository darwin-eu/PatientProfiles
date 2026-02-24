# Add flag for death for individuals. Only death within the same observation period than \`indexDate\` will be observed.

Add flag for death for individuals. Only death within the same
observation period than \`indexDate\` will be observed.

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
#> # Source:   table<og_108_1771936231> [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date death
#>                   <int>      <int> <date>            <date>          <dbl>
#>  1                    1          7 1952-05-17        1978-12-05          0
#>  2                    1          4 1990-01-13        1995-08-10          0
#>  3                    2          2 1965-10-06        1997-09-15          0
#>  4                    3          3 1993-03-17        1995-03-09          0
#>  5                    3          8 1919-08-31        1936-04-13          0
#>  6                    2          9 1981-12-14        1981-12-15          0
#>  7                    3          5 1928-05-20        1928-06-17          0
#>  8                    3          6 1937-03-12        1955-02-21          0
#>  9                    3          1 1972-02-02        1972-03-11          0
#> 10                    3         10 1949-11-12        1952-02-27          0

# }
```
