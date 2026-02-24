# Query to add the age of the individuals at a certain date

\`r lifecycle::badge("experimental")\` Same as \`addAge()\`, except
query is not computed to a table.

## Usage

``` r
addAgeQuery(
  x,
  indexDate = "cohort_start_date",
  ageName = "age",
  ageGroup = NULL,
  ageMissingMonth = 1,
  ageMissingDay = 1,
  ageImposeMonth = FALSE,
  ageImposeDay = FALSE,
  missingAgeGroupValue = "None"
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- indexDate:

  Variable in x that contains the date to compute the age.

- ageName:

  Name of the new column that contains age.

- ageGroup:

  List of age groups to be added.

- ageMissingMonth:

  Month of the year assigned to individuals with missing month of birth.
  By default: 1.

- ageMissingDay:

  day of the month assigned to individuals with missing day of birth. By
  default: 1.

- ageImposeMonth:

  Whether the month of the date of birth will be considered as missing
  for all the individuals.

- ageImposeDay:

  Whether the day of the date of birth will be considered as missing for
  all the individuals.

- missingAgeGroupValue:

  Value to include if missing age.

## Value

tibble with the age column added.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addAgeQuery()
#> # Source:   SQL [?? x 5]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date   age
#>                   <int>      <int> <date>            <date>          <int>
#>  1                    1         10 1917-06-03        1937-12-10          3
#>  2                    2          6 1984-02-06        1987-03-02         10
#>  3                    3          1 1931-04-29        1934-01-30          8
#>  4                    1          3 1961-06-21        1962-05-08         44
#>  5                    3          2 1958-12-05        1959-08-21         24
#>  6                    2          4 1949-06-03        1957-07-27          0
#>  7                    3          5 1966-05-15        1968-02-08         25
#>  8                    2          8 1971-10-10        1971-11-08         42
#>  9                    3          9 1995-07-20        1996-10-31         20
#> 10                    2          7 1973-01-29        1986-06-15         14

# }
```
