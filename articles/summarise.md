# Summarise result

## Introduction

In previous vignettes we have seen how to add patient level demographics
(age, sex, prior observation, …) or intersections with cohorts ,
concepts and tables.

Once we have added several columns to our table of interest we may want
to summarise all this data into a `summarised_result` object using
several different estimates.

### Variables type

We support different types of variables, variable type is assigned using
[`dplyr::type_sum`](https://pillar.r-lib.org/reference/type_sum.html):

- Date: `date` or `dttm`.

- Numeric: `dbl` or `drtn`.

- Integer: `int` or `int64`.

- Categorical: `chr`, `fct` or `ord`.

- Logical: `lgl`.

### Estimates names

We can summarise this data using different estimates:

| Estimate name           | Description                                                                                      | Estimate type |
|-------------------------|--------------------------------------------------------------------------------------------------|---------------|
| date                    |                                                                                                  |               |
| mean                    | mean of the variable of interest.                                                                | date          |
| sd                      | standard deviation of the variable of interest.                                                  | numeric       |
| median                  | median of the variable of interest.                                                              | date          |
| qXX                     | qualtile of XX% the variable of interest.                                                        | date          |
| min                     | minimum of the variable of interest.                                                             | date          |
| max                     | maximum of the variable of interest.                                                             | date          |
| count_missing           | number of missing values.                                                                        | integer       |
| percentage_missing      | percentage of missing values                                                                     | percentage    |
| density                 | density distribution                                                                             | multiple      |
| numeric                 |                                                                                                  |               |
| sum                     | sum of all the values for the variable of interest.                                              | numeric       |
| mean                    | mean of the variable of interest.                                                                | numeric       |
| sd                      | standard deviation of the variable of interest.                                                  | numeric       |
| median                  | median of the variable of interest.                                                              | numeric       |
| qXX                     | qualtile of XX% the variable of interest.                                                        | numeric       |
| min                     | minimum of the variable of interest.                                                             | numeric       |
| max                     | maximum of the variable of interest.                                                             | numeric       |
| count_missing           | number of missing values.                                                                        | integer       |
| percentage_missing      | percentage of missing values                                                                     | percentage    |
| count                   | count number of \`1\`. Only allowed for binary numeric variables.                                | integer       |
| percentage              | percentage of occurrences of \`1\` (NA are excluded). Only allowed for binary numeric variables. | percentage    |
| count_0                 | count number of \`1\`.                                                                           | integer       |
| percentage_0            | percentage of occurrences of \`0\` (NA are excluded).                                            | percentage    |
| count_negative          | count negative values.                                                                           | integer       |
| percentage_negative     | percentage of negative values.                                                                   | percentage    |
| count_positive          | count positive values.                                                                           | integer       |
| percentage_positive     | percentage of positive values.                                                                   | percentage    |
| count_not_negative      | count not negative values.                                                                       | integer       |
| percentage_not_negative | percentage of not negative values.                                                               | percentage    |
| count_not_positive      | count not positive values.                                                                       | integer       |
| percentage_not_positive | percentage of not positive values.                                                               | percentage    |
| density                 | density distribution                                                                             | multiple      |
| integer                 |                                                                                                  |               |
| sum                     | sum of all the values for the variable of interest.                                              | integer       |
| mean                    | mean of the variable of interest.                                                                | numeric       |
| sd                      | standard deviation of the variable of interest.                                                  | numeric       |
| median                  | median of the variable of interest.                                                              | integer       |
| qXX                     | qualtile of XX% the variable of interest.                                                        | integer       |
| min                     | minimum of the variable of interest.                                                             | integer       |
| max                     | maximum of the variable of interest.                                                             | integer       |
| count_missing           | number of missing values.                                                                        | integer       |
| percentage_missing      | percentage of missing values                                                                     | percentage    |
| count                   | count number of \`1\`. Only allowed for binary numeric variables.                                | integer       |
| percentage              | percentage of occurrences of \`1\` (NA are excluded). Only allowed for binary numeric variables. | percentage    |
| count_0                 | count number of \`1\`.                                                                           | integer       |
| percentage_0            | percentage of occurrences of \`0\` (NA are excluded).                                            | percentage    |
| count_negative          | count negative values.                                                                           | integer       |
| percentage_negative     | percentage of negative values.                                                                   | percentage    |
| count_positive          | count positive values.                                                                           | integer       |
| percentage_positive     | percentage of positive values.                                                                   | percentage    |
| count_not_negative      | count not negative values.                                                                       | integer       |
| percentage_not_negative | percentage of not negative values.                                                               | percentage    |
| count_not_positive      | count not positive values.                                                                       | integer       |
| percentage_not_positive | percentage of not positive values.                                                               | percentage    |
| density                 | density distribution                                                                             | multiple      |
| categorical             |                                                                                                  |               |
| count                   | number of times that each category is observed.                                                  | integer       |
| percentage              | percentage of individuals with that category.                                                    | percentage    |
| count_person            | distinct counts of \`person_id\`.                                                                | integer       |
| count_subject           | distinct counts of \`subject_id\`.                                                               | integer       |
| logical                 |                                                                                                  |               |
| count                   | count number of \`TRUE\`.                                                                        | integer       |
| percentage              | percentage of occurrences of \`TRUE\` (NA are excluded).                                         | percentage    |

## Summarise our first table

Lets get started creating our data that we are going to summarise:

``` r
library(PatientProfiles)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(CohortConstructor)
library(CodelistGenerator)
library(omock)

cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#> ℹ Loading bundled GiBleed tables from package data.
#> ℹ Adding drug_strength table.
#> ℹ Creating local <cdm_reference> object.
#> ℹ Inserting <cdm_reference> into duckdb.

cdm$my_cohort <- conceptCohort(
  cdm = cdm,
  conceptSet = list("sinusitis" = c(4294548, 4283893, 40481087, 257012)),
  name = "my_cohort"
) |>
  requireIsFirstEntry()
#> Warning: ! `codelist` casted to integers.
#> ℹ Subsetting table condition_occurrence using 4 concepts with domain:
#>   condition.
#> ℹ Combining tables.
#> ℹ Creating cohort attributes.
#> ℹ Applying cohort requirements.
#> ℹ Merging overlapping records.
#> ✔ Cohort my_cohort created.

cdm$drugs <- conceptCohort(
  cdm = cdm,
  conceptSet = getDrugIngredientCodes(cdm = cdm, name = c("morphine", "aspirin", "oxycodone")),
  name = "drugs"
)
#> ℹ Subsetting table drug_exposure using 6 concepts with domain: drug.
#> ℹ Combining tables.
#> ℹ Creating cohort attributes.
#> ℹ Applying cohort requirements.
#> ℹ Merging overlapping records.
#> ✔ Cohort drugs created.

x <- cdm$my_cohort |>
  # add demographics variables
  addDemographics() |>
  # add number of counts per ingredient before and after index date
  addCohortIntersectCount(
    targetCohortTable = "drugs",
    window = list("prior" = c(-Inf, -1), "future" = c(1, Inf)),
    nameStyle = "{window_name}_{cohort_name}"
  ) |>
  # add a flag regarding if they had a prior occurrence of pharyngitis
  addConceptIntersectFlag(
    conceptSet = list(pharyngitis = 4112343),
    window = c(-Inf, -1),
    nameStyle = "pharyngitis_before"
  ) |>
  # date fo the first visit for that individual
  addTableIntersectDate(
    tableName = "visit_occurrence",
    window = c(-Inf, Inf),
    nameStyle = "first_visit"
  ) |>
  # time till the next visit after sinusitis
  addTableIntersectDays(
    tableName = "visit_occurrence",
    window = c(1, Inf),
    nameStyle = "days_to_next_visit"
  )
#> Warning: ! `codelist` casted to integers.

x |>
  glimpse()
#> Rows: ??
#> Columns: 17
#> Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2//tmp/RtmpqQVnxN/file2080343b0212.duckdb]
#> $ cohort_definition_id  <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id            <int> 42, 187, 96, 32, 5, 222, 1, 176, 116, 236, 101, …
#> $ cohort_start_date     <date> 1926-05-12, 1953-02-18, 1933-11-16, 1967-01-29,…
#> $ cohort_end_date       <date> 1926-05-19, 1953-03-04, 1933-12-07, 1967-07-02,…
#> $ age                   <int> 16, 7, 8, 23, 9, 6, 18, 4, 12, 6, 4, 2, 23, 4, 3…
#> $ sex                   <chr> "Female", "Male", "Male", "Male", "Male", "Femal…
#> $ prior_observation     <int> 6034, 2767, 3246, 8495, 3308, 2379, 6696, 1537, …
#> $ future_observation    <int> 33908, 24015, 23088, 17496, 14990, 22191, 18987,…
#> $ future_1191_aspirin   <dbl> 3, 2, 2, 0, 1, 2, 2, 1, 1, 0, 3, 1, 0, 3, 1, 0, …
#> $ prior_1191_aspirin    <dbl> 2, 3, 1, 3, 0, 2, 0, 0, 3, 1, 0, 2, 0, 2, 0, 2, …
#> $ prior_7804_oxycodone  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, …
#> $ prior_7052_morphine   <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
#> $ future_7804_oxycodone <dbl> 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, …
#> $ future_7052_morphine  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
#> $ pharyngitis_before    <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ first_visit           <date> 1933-10-30, 1985-02-09, 1985-04-13, 1987-06-09,…
#> $ days_to_next_visit    <dbl> 2728, 11679, 18776, 7436, 4619, 10966, 5194, 229…
```

In this table (`x`) we have a cohort of first occurrences of sinusitis,
and then we added: demographics; the counts of 3 ingredients, any time
prior and any time after the index date; a flag indicating if they had
pharyngitis before; date of the first visit; and, finally, time to next
visit.

If we want to summarise the age stratified by sex we could use tidyverse
functions like:

``` r
x |>
  group_by(sex) |>
  summarise(mean_age = mean(age), sd_age = sd(age))
#> Warning: Missing values are always removed in SQL aggregation functions.
#> Use `na.rm = TRUE` to silence this warning
#> This warning is displayed once every 8 hours.
#> # Source:   SQL [?? x 3]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2//tmp/RtmpqQVnxN/file2080343b0212.duckdb]
#>   sex    mean_age sd_age
#>   <chr>     <dbl>  <dbl>
#> 1 Female     7.51   7.46
#> 2 Male       7.72   8.14
```

This would give us a first insight of the differences of age. But the
output is not going to be in an standardised format.

In PatientProfiles we have built a function that:

- Allow you to get the standardised output.

- You have a wide range of estimates that you can get.

- You don’t have to worry which of the functions are supported in the
  database side (e.g. not all dbms support quantile function).

For example we could get the same information like before using:

``` r
x |>
  summariseResult(
    strata = "sex",
    variables = "age",
    estimates = c("mean", "sd"),
    counts = FALSE
  ) |>
  select(strata_name, strata_level, variable_name, estimate_value)
#> ℹ The following estimates will be calculated:
#> • age: mean, sd
#> → Start summary of data, at 2026-02-26 08:45:18.631012
#> 
#> ✔ Summary finished, at 2026-02-26 08:45:19.042693
#> # A tibble: 6 × 4
#>   strata_name strata_level variable_name estimate_value  
#>   <chr>       <chr>        <chr>         <chr>           
#> 1 overall     overall      age           7.61212346597248
#> 2 overall     overall      age           7.79743654397838
#> 3 sex         Female       age           7.5127644055434 
#> 4 sex         Male         age           7.7154779969651 
#> 5 sex         Female       age           7.45793686970358
#> 6 sex         Male         age           8.13712697581575
```

You can stratify the results also by “pharyngitis_before”:

``` r
x |>
  summariseResult(
    strata = list("sex", "pharyngitis_before"),
    variables = "age",
    estimates = c("mean", "sd"),
    counts = FALSE
  ) |>
  select(strata_name, strata_level, variable_name, estimate_value)
#> ℹ The following estimates will be calculated:
#> • age: mean, sd
#> → Start summary of data, at 2026-02-26 08:45:19.724277
#> 
#> ✔ Summary finished, at 2026-02-26 08:45:20.367177
#> # A tibble: 10 × 4
#>    strata_name        strata_level variable_name estimate_value  
#>    <chr>              <chr>        <chr>         <chr>           
#>  1 overall            overall      age           7.61212346597248
#>  2 overall            overall      age           7.79743654397838
#>  3 sex                Female       age           7.5127644055434 
#>  4 sex                Male         age           7.7154779969651 
#>  5 sex                Female       age           7.45793686970358
#>  6 sex                Male         age           8.13712697581575
#>  7 pharyngitis_before 0            age           4.95620875824835
#>  8 pharyngitis_before 1            age           11.9442270058708
#>  9 pharyngitis_before 0            age           5.61220818358422
#> 10 pharyngitis_before 1            age           8.85279666294611
```

Note that the interaction term was not included, if we want to include
it we have to specify it as follows:

``` r
x |>
  summariseResult(
    strata = list("sex", "pharyngitis_before", c("sex", "pharyngitis_before")),
    variables = "age",
    estimates = c("mean", "sd"),
    counts = FALSE
  ) |>
  select(strata_name, strata_level, variable_name, estimate_value) |>
  print(n = Inf)
#> ℹ The following estimates will be calculated:
#> • age: mean, sd
#> → Start summary of data, at 2026-02-26 08:45:21.058681
#> 
#> ✔ Summary finished, at 2026-02-26 08:45:21.973162
#> # A tibble: 18 × 4
#>    strata_name                strata_level variable_name estimate_value  
#>    <chr>                      <chr>        <chr>         <chr>           
#>  1 overall                    overall      age           7.61212346597248
#>  2 overall                    overall      age           7.79743654397838
#>  3 sex                        Female       age           7.5127644055434 
#>  4 sex                        Male         age           7.7154779969651 
#>  5 sex                        Female       age           7.45793686970358
#>  6 sex                        Male         age           8.13712697581575
#>  7 pharyngitis_before         0            age           4.95620875824835
#>  8 pharyngitis_before         1            age           11.9442270058708
#>  9 pharyngitis_before         0            age           5.61220818358422
#> 10 pharyngitis_before         1            age           8.85279666294611
#> 11 sex &&& pharyngitis_before Female &&& 0 age           4.97596153846154
#> 12 sex &&& pharyngitis_before Female &&& 1 age           11.4285714285714
#> 13 sex &&& pharyngitis_before Male &&& 0   age           4.93652694610778
#> 14 sex &&& pharyngitis_before Male &&& 1   age           12.51966873706  
#> 15 sex &&& pharyngitis_before Female &&& 0 age           5.61023639284453
#> 16 sex &&& pharyngitis_before Female &&& 1 age           8.22838499965833
#> 17 sex &&& pharyngitis_before Male &&& 0   age           5.61746547644658
#> 18 sex &&& pharyngitis_before Male &&& 1   age           9.47682947960302
```

You can remove overall strata with the includeOverallStrata option:

``` r
x |>
  summariseResult(
    includeOverallStrata = FALSE,
    strata = list("sex", "pharyngitis_before"),
    variables = "age",
    estimates = c("mean", "sd"),
    counts = FALSE
  ) |>
  select(strata_name, strata_level, variable_name, estimate_value) |>
  print(n = Inf)
#> ℹ The following estimates will be calculated:
#> • age: mean, sd
#> → Start summary of data, at 2026-02-26 08:45:22.66419
#> 
#> ✔ Summary finished, at 2026-02-26 08:45:23.179052
#> # A tibble: 8 × 4
#>   strata_name        strata_level variable_name estimate_value  
#>   <chr>              <chr>        <chr>         <chr>           
#> 1 sex                Female       age           7.5127644055434 
#> 2 sex                Male         age           7.7154779969651 
#> 3 sex                Female       age           7.45793686970358
#> 4 sex                Male         age           8.13712697581575
#> 5 pharyngitis_before 0            age           4.95620875824835
#> 6 pharyngitis_before 1            age           11.9442270058708
#> 7 pharyngitis_before 0            age           5.61220818358422
#> 8 pharyngitis_before 1            age           8.85279666294611
```

The results model has two levels of grouping (group and strata), you can
specify them independently:

``` r
x |>
  addCohortName() |>
  summariseResult(
    group = "cohort_name",
    includeOverallGroup = FALSE,
    strata = list("sex", "pharyngitis_before"),
    includeOverallStrata = TRUE,
    variables = "age",
    estimates = c("mean", "sd"),
    counts = FALSE
  ) |>
  select(group_name, group_level, strata_name, strata_level, variable_name, estimate_value) |>
  print(n = Inf)
#> ℹ The following estimates will be calculated:
#> • age: mean, sd
#> → Start summary of data, at 2026-02-26 08:45:24.083789
#> 
#> ✔ Summary finished, at 2026-02-26 08:45:24.936301
#> # A tibble: 10 × 6
#>    group_name  group_level strata_name strata_level variable_name estimate_value
#>    <chr>       <chr>       <chr>       <chr>        <chr>         <chr>         
#>  1 cohort_name sinusitis   overall     overall      age           7.61212346597…
#>  2 cohort_name sinusitis   overall     overall      age           7.79743654397…
#>  3 cohort_name sinusitis   sex         Female       age           7.51276440554…
#>  4 cohort_name sinusitis   sex         Male         age           7.71547799696…
#>  5 cohort_name sinusitis   sex         Female       age           7.45793686970…
#>  6 cohort_name sinusitis   sex         Male         age           8.13712697581…
#>  7 cohort_name sinusitis   pharyngiti… 0            age           4.95620875824…
#>  8 cohort_name sinusitis   pharyngiti… 1            age           11.9442270058…
#>  9 cohort_name sinusitis   pharyngiti… 0            age           5.61220818358…
#> 10 cohort_name sinusitis   pharyngiti… 1            age           8.85279666294…
```

We can add or remove number subjects and records (if a person identifier
is found) counts with the counts parameter:

``` r
x |>
  summariseResult(
    variables = "age",
    estimates = c("mean", "sd"),
    counts = TRUE
  ) |>
  select(strata_name, strata_level, variable_name, estimate_value) |>
  print(n = Inf)
#> ℹ The following estimates will be calculated:
#> • age: mean, sd
#> → Start summary of data, at 2026-02-26 08:45:25.627222
#> 
#> ✔ Summary finished, at 2026-02-26 08:45:25.875288
#> # A tibble: 4 × 4
#>   strata_name strata_level variable_name   estimate_value  
#>   <chr>       <chr>        <chr>           <chr>           
#> 1 overall     overall      number records  2689            
#> 2 overall     overall      number subjects 2689            
#> 3 overall     overall      age             7.61212346597248
#> 4 overall     overall      age             7.79743654397838
```

If you want to specify different groups of estimates per different
groups of variables you can use lists:

``` r
x |>
  summariseResult(
    strata = "pharyngitis_before",
    includeOverallStrata = FALSE,
    variables = list(c("age", "prior_observation"), "sex"),
    estimates = list(c("mean", "sd"), c("count", "percentage")),
    counts = FALSE
  ) |>
  select(strata_name, strata_level, variable_name, estimate_value) |>
  print(n = Inf)
#> ℹ The following estimates will be calculated:
#> • age: mean, sd
#> • prior_observation: mean, sd
#> • sex: count, percentage
#> → Start summary of data, at 2026-02-26 08:45:26.577447
#> 
#> ✔ Summary finished, at 2026-02-26 08:45:27.032814
#> # A tibble: 16 × 4
#>    strata_name        strata_level variable_name     estimate_value  
#>    <chr>              <chr>        <chr>             <chr>           
#>  1 pharyngitis_before 0            age               4.95620875824835
#>  2 pharyngitis_before 1            age               11.9442270058708
#>  3 pharyngitis_before 0            age               5.61220818358422
#>  4 pharyngitis_before 1            age               8.85279666294611
#>  5 pharyngitis_before 0            sex               832             
#>  6 pharyngitis_before 1            sex               539             
#>  7 pharyngitis_before 0            sex               835             
#>  8 pharyngitis_before 1            sex               483             
#>  9 pharyngitis_before 0            sex               49.9100179964007
#> 10 pharyngitis_before 1            sex               52.7397260273973
#> 11 pharyngitis_before 0            sex               50.0899820035993
#> 12 pharyngitis_before 1            sex               47.2602739726027
#> 13 pharyngitis_before 0            prior_observation 1986.83443311338
#> 14 pharyngitis_before 1            prior_observation 4542.85812133072
#> 15 pharyngitis_before 0            prior_observation 2053.24325390978
#> 16 pharyngitis_before 1            prior_observation 3228.06460521218
```

An example of a complete analysis would be:

``` r
drugs <- settings(cdm$drugs)$cohort_name
x |>
  addCohortName() |>
  summariseResult(
    group = "cohort_name",
    includeOverallGroup = FALSE,
    strata = list("pharyngitis_before"),
    includeOverallStrata = TRUE,
    variables = list(
      c(
        "age", "prior_observation", "future_observation", paste0("prior_", drugs),
        paste0("future_", drugs), "days_to_next_visit"
      ),
      c("sex", "pharyngitis_before"),
      c("first_visit", "cohort_start_date", "cohort_end_date")
    ),
    estimates = list(
      c("median", "q25", "q75"),
      c("count", "percentage"),
      c("median", "q25", "q75", "min", "max")
    ),
    counts = TRUE
  ) |>
  select(group_name, group_level, strata_name, strata_level, variable_name, estimate_value)
#> ℹ The following estimates will be calculated:
#> • age: median, q25, q75
#> • prior_observation: median, q25, q75
#> • future_observation: median, q25, q75
#> • prior_1191_aspirin: median, q25, q75
#> • prior_7052_morphine: median, q25, q75
#> • prior_7804_oxycodone: median, q25, q75
#> • future_1191_aspirin: median, q25, q75
#> • future_7052_morphine: median, q25, q75
#> • future_7804_oxycodone: median, q25, q75
#> • days_to_next_visit: median, q25, q75
#> • sex: count, percentage
#> • pharyngitis_before: count, percentage
#> • first_visit: median, q25, q75, min, max
#> • cohort_start_date: median, q25, q75, min, max
#> • cohort_end_date: median, q25, q75, min, max
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-26 08:45:28.03559
#> 
#> ✔ Summary finished, at 2026-02-26 08:45:28.328182
#> # A tibble: 159 × 6
#>    group_name  group_level strata_name strata_level variable_name estimate_value
#>    <chr>       <chr>       <chr>       <chr>        <chr>         <chr>         
#>  1 cohort_name sinusitis   overall     overall      number recor… 2689          
#>  2 cohort_name sinusitis   overall     overall      number subje… 2689          
#>  3 cohort_name sinusitis   overall     overall      cohort_start… 1968-05-06    
#>  4 cohort_name sinusitis   overall     overall      cohort_start… 1956-07-05    
#>  5 cohort_name sinusitis   overall     overall      cohort_start… 1978-09-04    
#>  6 cohort_name sinusitis   overall     overall      cohort_start… 1908-10-30    
#>  7 cohort_name sinusitis   overall     overall      cohort_start… 2018-02-13    
#>  8 cohort_name sinusitis   overall     overall      cohort_end_d… 1968-05-27    
#>  9 cohort_name sinusitis   overall     overall      cohort_end_d… 1956-07-28    
#> 10 cohort_name sinusitis   overall     overall      cohort_end_d… 1978-10-31    
#> # ℹ 149 more rows
```
