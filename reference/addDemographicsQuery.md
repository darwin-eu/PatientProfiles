# Query to add demographic characteristics at a certain date

Same as
[`addDemographics()`](https://darwin-eu.github.io/PatientProfiles/reference/addDemographics.md),
except query is not computed to a table.

## Usage

``` r
addDemographicsQuery(
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
  addDemographicsQuery()
#> # A query:  ?? x 8
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date   age sex  
#>                   <int>      <int> <date>            <date>          <dbl> <chr>
#>  1                    2          1 1957-01-10        1964-03-22         29 Fema…
#>  2                    2          2 1943-03-28        1943-05-07         22 Male 
#>  3                    3          3 1941-04-02        1949-12-04          7 Fema…
#>  4                    3          4 1958-06-04        1971-07-22          0 Male 
#>  5                    2          5 1986-01-29        1988-07-05         10 Fema…
#>  6                    2          6 1958-12-31        1963-07-30         30 Male 
#>  7                    3          7 1950-11-30        1951-04-22         29 Fema…
#>  8                    1          8 1998-11-05        2000-09-10         18 Male 
#>  9                    3          9 1943-07-09        1947-04-18          0 Fema…
#> 10                    1         10 1930-09-02        1945-03-09          5 Male 
#> # ℹ 2 more variables: prior_observation <dbl>, future_observation <dbl>

# }
```
