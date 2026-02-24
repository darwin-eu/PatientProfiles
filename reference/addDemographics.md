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

cdm$cohort1 |>
  addDemographics()
#> # Source:   table<og_119_1771936235> [?? x 8]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date   age sex  
#>                   <int>      <int> <date>            <date>          <int> <chr>
#>  1                    1          1 1948-03-04        1953-02-17         15 Male 
#>  2                    2          2 1960-02-16        1966-02-11          4 Fema…
#>  3                    1          3 1961-04-05        1964-04-13         15 Male 
#>  4                    1          4 1930-01-06        1936-03-04         17 Fema…
#>  5                    2          5 1925-03-26        1930-11-03          7 Fema…
#>  6                    1          6 2001-01-11        2008-12-22         28 Male 
#>  7                    3          7 1991-08-29        1999-07-04         11 Male 
#>  8                    2          8 1929-08-26        1946-08-29          9 Fema…
#>  9                    2          9 1965-01-22        1974-09-16         14 Fema…
#> 10                    2         10 2015-07-06        2015-09-23         42 Male 
#> # ℹ 2 more variables: prior_observation <int>, future_observation <int>

# }
```
