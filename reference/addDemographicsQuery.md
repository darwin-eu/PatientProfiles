# Query to add demographic characteristics at a certain date

\`r lifecycle::badge("experimental")\` Same as \`addDemographics()\`,
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

cdm$cohort1 |>
  addDemographicsQuery()
#> # Source:   SQL [?? x 8]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2/:memory:]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date   age sex  
#>                   <int>      <int> <date>            <date>          <int> <chr>
#>  1                    1          1 1971-10-23        1979-03-22         15 Fema…
#>  2                    1          2 1920-03-11        1933-10-14          5 Fema…
#>  3                    2          3 1908-04-11        1910-04-27          5 Fema…
#>  4                    1          4 1954-03-15        1955-08-02          0 Fema…
#>  5                    3          5 1986-08-29        1987-05-05         15 Male 
#>  6                    1          6 1966-03-21        1968-12-27          5 Male 
#>  7                    2          7 1937-08-24        1943-05-16          6 Fema…
#>  8                    2          8 1928-07-03        1930-02-28          6 Fema…
#>  9                    1          9 1981-06-17        1991-02-28         28 Male 
#> 10                    1         10 1966-08-12        1969-02-08         11 Fema…
#> # ℹ 2 more variables: prior_observation <int>, future_observation <int>

# }
```
