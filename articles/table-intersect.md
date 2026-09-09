# Adding table intersections

So far we’ve seen that we can add variables indicating intersections
based on cohorts or concept sets. One additional option we have is to
simply add an intersection based on a table.

In this example, `CohortConstructor` is used to create the ankle sprain
cohort. PatientProfiles then adds table intersections to the resulting
valid cohort table; it does not create or modify cohort definitions.

Let’s again create a cohort containing people with an ankle sprain.

``` r

library(CodelistGenerator)
library(PatientProfiles)
library(dplyr)
library(CohortConstructor)
library(ggplot2)
library(omock)

cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")

cdm$ankle_sprain <- conceptCohort(
  cdm = cdm,
  name = "ankle_sprain",
  conceptSet = list("ankle_sprain" = 81151)
)
cdm$ankle_sprain
#> # A query:  ?? x 4
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1022-azure:R 4.6.1//tmp/RtmpsUfPAj/file24131174275d.duckdb]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1        890 1992-10-30        1992-11-20     
#>  2                    1       3092 1956-05-22        1956-06-05     
#>  3                    1       4452 1958-08-16        1958-08-30     
#>  4                    1       4615 2011-04-24        2011-05-22     
#>  5                    1       4675 1961-04-13        1961-05-11     
#>  6                    1       4975 1999-01-01        1999-01-29     
#>  7                    1       5108 1967-08-20        1967-09-17     
#>  8                    1         38 1967-10-27        1967-11-17     
#>  9                    1        304 2004-03-22        2004-04-19     
#> 10                    1        882 2002-02-13        2002-03-20     
#> # ℹ more rows

cdm$ankle_sprain |>
  addTableIntersectFlag(
    tableName = "condition_occurrence",
    window = c(-30, -1)
  ) |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> $ cohort_definition_id           <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id                     <int> 38, 2778, 4745, 61, 119, 4121, 2294, 31…
#> $ cohort_start_date              <date> 1967-10-27, 1986-10-01, 1981-12-26, 19…
#> $ cohort_end_date                <date> 1967-11-17, 1986-10-22, 1982-01-16, 19…
#> $ condition_occurrence_m30_to_m1 <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
```

We can use table intersection functions to check whether someone had a
record in the drug exposure table in the 30 days before their ankle
sprain. If we set targetStartDate to “drug_exposure_start_date” and
targetEndDate to “drug_exposure_end_date” we are checking whether an
individual had an ongoing drug exposure record in the window.

``` r

cdm$ankle_sprain |>
  addTableIntersectFlag(
    tableName = "drug_exposure",
    indexDate = "cohort_start_date",
    targetStartDate = "drug_exposure_start_date",
    targetEndDate = "drug_exposure_end_date",
    window = c(-30, -1)
  ) |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> $ cohort_definition_id    <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ subject_id              <int> 4026, 4745, 61, 4121, 2935, 3047, 1335, 608, 3…
#> $ cohort_start_date       <date> 1992-04-18, 1981-12-26, 1983-12-03, 1925-11-1…
#> $ cohort_end_date         <date> 1992-05-09, 1982-01-16, 1984-01-07, 1925-12-0…
#> $ drug_exposure_m30_to_m1 <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
```

Meanwhile if we set we set targetStartDate to “drug_exposure_start_date”
and targetEndDate to “drug_exposure_start_date” we will instead be
checking whether they had a drug exposure record that started during the
window.

``` r

cdm$ankle_sprain |>
  addTableIntersectFlag(
    tableName = "drug_exposure",
    indexDate = "cohort_start_date",
    window = c(-30, -1)
  ) |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> $ cohort_definition_id    <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ subject_id              <int> 4026, 4745, 61, 4121, 2935, 3047, 1335, 608, 3…
#> $ cohort_start_date       <date> 1992-04-18, 1981-12-26, 1983-12-03, 1925-11-1…
#> $ cohort_end_date         <date> 1992-05-09, 1982-01-16, 1984-01-07, 1925-12-0…
#> $ drug_exposure_m30_to_m1 <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
```

As before, instead of a flag, we could also add count, date, or days
variables.

``` r

cdm$ankle_sprain |>
  addTableIntersectCount(
    tableName = "drug_exposure",
    indexDate = "cohort_start_date",
    window = c(-180, -1)
  ) |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> $ cohort_definition_id     <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id               <int> 3092, 4452, 2878, 4026, 225, 1447, 1689, 2319…
#> $ cohort_start_date        <date> 1956-05-22, 1958-08-16, 1984-03-06, 1992-04-…
#> $ cohort_end_date          <date> 1956-06-05, 1958-08-30, 1984-03-27, 1992-05-…
#> $ drug_exposure_m180_to_m1 <dbl> 2, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, …

cdm$ankle_sprain |>
  addTableIntersectDate(
    tableName = "drug_exposure",
    indexDate = "cohort_start_date",
    order = "last",
    window = c(-180, -1)
  ) |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> $ cohort_definition_id     <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id               <int> 3092, 4452, 2878, 4026, 225, 1447, 1689, 2319…
#> $ cohort_start_date        <date> 1956-05-22, 1958-08-16, 1984-03-06, 1992-04-…
#> $ cohort_end_date          <date> 1956-06-05, 1958-08-30, 1984-03-27, 1992-05-…
#> $ drug_exposure_m180_to_m1 <date> 1956-04-04, 1958-05-07, 1984-01-29, 1992-04-…


cdm$ankle_sprain |>
  addTableIntersectDate(
    tableName = "drug_exposure",
    indexDate = "cohort_start_date",
    order = "last",
    window = c(-180, -1)
  ) |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> $ cohort_definition_id     <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id               <int> 3092, 4452, 2878, 4026, 225, 1447, 1689, 2319…
#> $ cohort_start_date        <date> 1956-05-22, 1958-08-16, 1984-03-06, 1992-04-…
#> $ cohort_end_date          <date> 1956-06-05, 1958-08-30, 1984-03-27, 1992-05-…
#> $ drug_exposure_m180_to_m1 <date> 1956-04-04, 1958-05-07, 1984-01-29, 1992-04-…
```

In these examples we’ve been adding intersections using the entire drug
exposure concept table. However, we could have subsetted it before
adding our table intersection. For example, let’s say we want to add a
variable for acetaminophen use among our ankle sprain cohort. As we’ve
seen before we could use a cohort or concept set for this, but now we
have another option - subset the drug exposure table down to
acetaminophen records and add a table intersection.

``` r

acetaminophen_cs <- getDrugIngredientCodes(
  cdm = cdm,
  name = c("acetaminophen")
)

cdm$acetaminophen_records <- cdm$drug_exposure |>
  filter(drug_concept_id %in% !!acetaminophen_cs[[1]]) |>
  compute()

cdm$ankle_sprain |>
  addTableIntersectFlag(
    tableName = "acetaminophen_records",
    indexDate = "cohort_start_date",
    targetStartDate = "drug_exposure_start_date",
    targetEndDate = "drug_exposure_end_date",
    window = c(-Inf, Inf)
  ) |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> $ cohort_definition_id              <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id                        <int> 890, 3092, 4452, 4615, 4675, 4975, 5…
#> $ cohort_start_date                 <date> 1992-10-30, 1956-05-22, 1958-08-16,…
#> $ cohort_end_date                   <date> 1992-11-20, 1956-06-05, 1958-08-30,…
#> $ acetaminophen_records_minf_to_inf <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
```

Beyond this table intersection provides a means if implementing a wide
range of custom analyses. One more example to show this is provided
below, where we check whether individuals have a measurement or
procedure record on the date of their ankle sprain.

``` r

cdm$proc_or_meas <- union_all(
  cdm$procedure_occurrence |>
    select("person_id",
      "record_date" = "procedure_date"
    ),
  cdm$measurement |>
    select("person_id",
      "record_date" = "measurement_date"
    )
) |>
  compute()

cdm$ankle_sprain |>
  addTableIntersectFlag(
    tableName = "proc_or_meas",
    indexDate = "cohort_start_date",
    targetStartDate = "record_date",
    targetEndDate = "record_date",
    window = c(0, 0)
  ) |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> $ cohort_definition_id <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ subject_id           <int> 890, 3092, 4452, 4615, 4675, 4975, 5108, 38, 304,…
#> $ cohort_start_date    <date> 1992-10-30, 1956-05-22, 1958-08-16, 2011-04-24, …
#> $ cohort_end_date      <date> 1992-11-20, 1956-06-05, 1958-08-30, 2011-05-22, …
#> $ proc_or_meas_0_to_0  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
```
