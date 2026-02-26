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
  dateOfBirthName = "date_of_birth"
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

## Value

cohort table with the added demographic information columns.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles(source = "duckdb")
#> Warning: There are observation period end dates after the current date: 2026-02-26
#> ℹ The latest max observation period end date found is 2027-11-18

cdm$cohort1 |>
  addDemographicsQuery()
#> # Source:   SQL [?? x 8]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date   age sex  
#>                   <int>      <int> <date>            <date>          <int> <chr>
#>  1                    3          1 1915-06-02        1939-03-28         11 Male 
#>  2                    2          2 1984-03-23        1992-03-22         14 Male 
#>  3                    3          3 1949-02-01        1951-12-15         35 Male 
#>  4                    2          4 1939-03-11        1949-08-22         15 Fema…
#>  5                    1          5 1942-01-14        1944-05-30         15 Fema…
#>  6                    1          6 1923-12-07        1931-08-16         12 Fema…
#>  7                    2          7 1964-09-24        1968-09-16         10 Male 
#>  8                    1          8 2011-06-05        2020-06-01         31 Male 
#>  9                    3          9 1959-03-10        1989-01-01          1 Male 
#> 10                    2         10 1988-10-01        1994-02-05         21 Fema…
#> # ℹ 2 more variables: prior_observation <int>, future_observation <int>

# }
```
