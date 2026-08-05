# Compute demographic characteristics at a certain date

Compute demographic characteristics at a certain date

## Usage

``` r
addDemographics(
  x,
  indexDate = "cohort_start_date",
  age = TRUE,
  ageName = "age",
  ageMissingMonth = 1,
  ageMissingDay = 1,
  ageImposeMonth = FALSE,
  ageImposeDay = FALSE,
  ageUnit = "years",
  ageGroup = NULL,
  missingAgeGroupValue = "None",
  sex = TRUE,
  sexName = "sex",
  missingSexValue = "None",
  priorObservation = TRUE,
  priorObservationName = "prior_observation",
  priorObservationType = "days",
  futureObservation = TRUE,
  futureObservationName = "future_observation",
  futureObservationType = "days",
  dateOfBirth = FALSE,
  dateOfBirthName = "date_of_birth",
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

- age:

  If `TRUE`, age is calculated relative to `indexDate`.

- ageName:

  Name of the age column to add.

- ageMissingMonth:

  Month of the year assigned when month of birth is missing.

- ageMissingDay:

  Day of the month assigned when day of birth is missing.

- ageImposeMonth:

  If `TRUE`, month of birth is treated as missing for all individuals.

- ageImposeDay:

  If `TRUE`, day of birth is treated as missing for all individuals.

- ageUnit:

  Unit in which to express age: `"years"`, `"months"`, or `"days"`.

- ageGroup:

  If not `NULL`, a list of age-group vectors.

- missingAgeGroupValue:

  Value to use when age is missing.

- sex:

  If `TRUE`, sex is identified.

- sexName:

  Name of the sex column to add.

- missingSexValue:

  Value to use when sex is missing.

- priorObservation:

  If `TRUE`, the time between the start of the current observation
  period and `indexDate` is calculated.

- priorObservationName:

  Name of the prior-observation column to add.

- priorObservationType:

  Whether to return a `"date"` or a number of `"days"`.

- futureObservation:

  If `TRUE`, the time between `indexDate` and the end of the current
  observation period is calculated.

- futureObservationName:

  Name of the future-observation column to add.

- futureObservationType:

  Whether to return a `"date"` or a number of `"days"`.

- dateOfBirth:

  If `TRUE`, date of birth is returned.

- dateOfBirthName:

  Name of the date-of-birth column to add.

- name:

  Name of the new table. If `NULL`, a temporary table is returned.

- type:

  Type of the created column(s). Counts, days, age, and observation
  durations can be `"numeric"` or `"integer"`. Flag columns can also be
  `"logical"`. Field columns can use `"auto"` to preserve the source
  type, or can be converted to `"numeric"`, `"integer"`, `"logical"`, or
  `"character"`.

## Value

cohort table with the added demographic information columns.

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
  addDemographics()
#> # A query:  ?? x 8
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date   age sex  
#>                   <int>      <int> <date>            <date>          <dbl> <chr>
#>  1                    3          1 1963-12-07        1968-08-16         34 Male 
#>  2                    3          2 1931-07-22        1939-11-03         21 Male 
#>  3                    2          3 1987-12-07        2005-11-04          9 Fema…
#>  4                    2          4 1985-01-21        1998-12-18         28 Male 
#>  5                    1          5 1939-02-14        1952-04-29          2 Fema…
#>  6                    3          6 1981-10-07        1989-11-11         11 Male 
#>  7                    1          7 1990-04-23        2004-03-22         25 Fema…
#>  8                    1          8 1969-11-05        1971-09-14          0 Fema…
#>  9                    1          9 1909-11-03        1913-04-16          5 Male 
#> 10                    1         10 1909-03-17        1926-08-21          3 Male 
#> # ℹ 2 more variables: prior_observation <dbl>, future_observation <dbl>

cdm$cohort1 |>
  addDemographics(indexDate = as.Date("2010-01-01"))
#> # A query:  ?? x 8
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date   age sex  
#>                   <int>      <int> <date>            <date>          <dbl> <chr>
#>  1                    3          1 1963-12-07        1968-08-16         81 Male 
#>  2                    3          2 1931-07-22        1939-11-03        100 Male 
#>  3                    2          3 1987-12-07        2005-11-04         32 Fema…
#>  4                    2          4 1985-01-21        1998-12-18         53 Male 
#>  5                    1          5 1939-02-14        1952-04-29         73 Fema…
#>  6                    3          6 1981-10-07        1989-11-11         40 Male 
#>  7                    1          7 1990-04-23        2004-03-22         45 Fema…
#>  8                    1          8 1969-11-05        1971-09-14         41 Fema…
#>  9                    1          9 1909-11-03        1913-04-16        106 Male 
#> 10                    1         10 1909-03-17        1926-08-21        104 Male 
#> # ℹ 2 more variables: prior_observation <dbl>, future_observation <dbl>

# }
```
