# Add the birth day of an individual to a table

**\[experimental\]** Same as
[`addBirthday()`](https://darwin-eu.github.io/PatientProfiles/reference/addBirthday.md),
except query is not computed to a table.

The function accounts for leap years and corrects the invalid dates to
the next valid date.

## Usage

``` r
addBirthdayQuery(
  x,
  birthdayName = "birthday",
  birthday = 0,
  ageMissingMonth = 1,
  ageMissingDay = 1,
  ageImposeMonth = FALSE,
  ageImposeDay = FALSE
)
```

## Arguments

- x:

  Table with individuals in the cdm.

- birthdayName:

  Birth day variable name.

- birthday:

  Number of birth day.

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

## Value

The table with a query that add the new column containing the birth day.

## Examples

``` r
# \donttest{
library(PatientProfiles)
library(dplyr)

cdm <- mockPatientProfiles(source = "duckdb")

cdm$cohort1 |>
  addBirthdayQuery() |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#> $ cohort_definition_id <int> 2, 1, 2, 3, 1, 1, 3, 3, 1, 3
#> $ subject_id           <int> 1, 9, 10, 6, 7, 4, 5, 2, 3, 8
#> $ cohort_start_date    <date> 1936-02-12, 1930-11-29, 1982-10-08, 1940-09-08, 1…
#> $ cohort_end_date      <date> 1948-01-09, 1941-07-03, 1983-05-21, 1965-11-10, 1…
#> $ birthday             <date> 1918-01-01, 1911-01-01, 1952-01-01, 1929-01-01, …

cdm$cohort1 |>
  addBirthdayQuery(birthday = 5) |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2/:memory:]
#> $ cohort_definition_id <int> 2, 1, 2, 3, 1, 1, 3, 3, 1, 3
#> $ subject_id           <int> 1, 9, 10, 6, 7, 4, 5, 2, 3, 8
#> $ cohort_start_date    <date> 1936-02-12, 1930-11-29, 1982-10-08, 1940-09-08, 1…
#> $ cohort_end_date      <date> 1948-01-09, 1941-07-03, 1983-05-21, 1965-11-10, 1…
#> $ birthday             <date> 1923-01-01, 1916-01-01, 1957-01-01, 1934-01-01, …
# }
```
