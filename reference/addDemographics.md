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
  name = NULL
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- indexDate:

  Variable in x that contains the date to compute the demographics
  characteristics.

- age:

  TRUE or FALSE. If TRUE, age will be calculated relative to indexDate.

- ageName:

  Age variable name.

- ageMissingMonth:

  Month of the year assigned to individuals with missing month of birth.

- ageMissingDay:

  day of the month assigned to individuals with missing day of birth.

- ageImposeMonth:

  TRUE or FALSE. Whether the month of the date of birth will be
  considered as missing for all the individuals.

- ageImposeDay:

  TRUE or FALSE. Whether the day of the date of birth will be considered
  as missing for all the individuals.

- ageUnit:

  Unit for age it can either be 'years', 'months' or 'days'.

- ageGroup:

  if not NULL, a list of ageGroup vectors.

- missingAgeGroupValue:

  Value to include if missing age.

- sex:

  TRUE or FALSE. If TRUE, sex will be identified.

- sexName:

  Sex variable name.

- missingSexValue:

  Value to include if missing sex.

- priorObservation:

  TRUE or FALSE. If TRUE, days of between the start of the current
  observation period and the indexDate will be calculated.

- priorObservationName:

  Prior observation variable name.

- priorObservationType:

  Whether to return a "date" or the number of "days".

- futureObservation:

  TRUE or FALSE. If TRUE, days between the indexDate and the end of the
  current observation period will be calculated.

- futureObservationName:

  Future observation variable name.

- futureObservationType:

  Whether to return a "date" or the number of "days".

- dateOfBirth:

  TRUE or FALSE, if true the date of birth will be return.

- dateOfBirthName:

  dateOfBirth column name.

- name:

  Name of the new table, if NULL a temporary table is returned.

## Value

cohort table with the added demographic information columns.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
#> Warning: There are observation period end dates after the current date: 2026-02-26
#> ℹ The latest max observation period end date found is 2029-12-15

cdm$cohort1 |>
  addDemographics()
#> # Source:   table<og_131_1772095740> [?? x 8]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date   age sex  
#>                   <int>      <int> <date>            <date>          <int> <chr>
#>  1                    2          1 2023-05-14        2026-11-25         50 Male 
#>  2                    1          2 1986-09-20        1994-11-19         20 Fema…
#>  3                    2          3 2004-07-17        2005-03-13         29 Fema…
#>  4                    2          4 1927-05-24        1929-10-09          3 Male 
#>  5                    1          5 1981-07-13        1985-02-11         37 Male 
#>  6                    2          6 1958-09-05        1979-02-08         14 Fema…
#>  7                    1          7 1922-03-10        1958-02-03          2 Male 
#>  8                    3          8 1931-09-03        1932-12-27         18 Male 
#>  9                    1          9 1942-04-30        1961-10-14         13 Fema…
#> 10                    2         10 1936-02-16        1936-06-10         29 Fema…
#> # ℹ 2 more variables: prior_observation <int>, future_observation <int>

# }
```
