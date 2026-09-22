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
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1022-azure:R 4.6.1//tmp/Rtmp0T49fV/file24914c3c85c.duckdb]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1        140 1976-05-20        1976-06-17     
#>  2                    1        369 1993-11-19        1993-12-03     
#>  3                    1        580 1930-06-03        1930-07-01     
#>  4                    1       1902 2000-06-01        2000-06-29     
#>  5                    1       3208 1986-04-07        1986-05-12     
#>  6                    1       3298 2018-06-28        2018-06-28     
#>  7                    1       3832 1985-11-02        1985-11-16     
#>  8                    1       3967 1966-01-30        1966-02-20     
#>  9                    1       5045 1979-05-23        1979-06-06     
#> 10                    1       5215 2008-08-06        2008-09-10     
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
#> $ subject_id                     <int> 580, 3967, 5215, 1882, 2836, 1294, 4713…
#> $ cohort_start_date              <date> 1930-06-03, 1966-01-30, 2008-08-06, 19…
#> $ cohort_end_date                <date> 1930-07-01, 1966-02-20, 2008-09-10, 19…
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
#> $ subject_id              <int> 3208, 5045, 5215, 5207, 4713, 4081, 2821, 5022…
#> $ cohort_start_date       <date> 1986-04-07, 1979-05-23, 2008-08-06, 1980-12-0…
#> $ cohort_end_date         <date> 1986-05-12, 1979-06-06, 2008-09-10, 1980-12-2…
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
#> $ subject_id              <int> 3208, 5045, 5215, 5207, 4713, 4081, 2821, 5022…
#> $ cohort_start_date       <date> 1986-04-07, 1979-05-23, 2008-08-06, 1980-12-0…
#> $ cohort_end_date         <date> 1986-05-12, 1979-06-06, 2008-09-10, 1980-12-2…
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
#> $ subject_id               <int> 580, 3208, 3967, 5045, 5215, 5207, 525, 4713,…
#> $ cohort_start_date        <date> 1930-06-03, 1986-04-07, 1966-01-30, 1979-05-…
#> $ cohort_end_date          <date> 1930-07-01, 1986-05-12, 1966-02-20, 1979-06-…
#> $ drug_exposure_m180_to_m1 <dbl> 1, 2, 2, 1, 1, 1, 1, 1, 2, 2, 1, 2, 4, 1, 1, …

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
#> $ subject_id               <int> 580, 3208, 3967, 5045, 5215, 525, 195, 239, 4…
#> $ cohort_start_date        <date> 1930-06-03, 1986-04-07, 1966-01-30, 1979-05-…
#> $ cohort_end_date          <date> 1930-07-01, 1986-05-12, 1966-02-20, 1979-06-…
#> $ drug_exposure_m180_to_m1 <date> 1930-03-05, 1985-12-18, 1965-09-02, 1979-03-…


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
#> $ subject_id               <int> 580, 3208, 3967, 5045, 5215, 525, 195, 239, 4…
#> $ cohort_start_date        <date> 1930-06-03, 1986-04-07, 1966-01-30, 1979-05-…
#> $ cohort_end_date          <date> 1930-07-01, 1986-05-12, 1966-02-20, 1979-06-…
#> $ drug_exposure_m180_to_m1 <date> 1930-03-05, 1985-12-18, 1965-09-02, 1979-03-…
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
#> $ subject_id                        <int> 140, 369, 580, 1902, 3208, 3298, 383…
#> $ cohort_start_date                 <date> 1976-05-20, 1993-11-19, 1930-06-03,…
#> $ cohort_end_date                   <date> 1976-06-17, 1993-12-03, 1930-07-01,…
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
#> $ subject_id           <int> 140, 369, 580, 1902, 3208, 3298, 3832, 3967, 5045…
#> $ cohort_start_date    <date> 1976-05-20, 1993-11-19, 1930-06-03, 2000-06-01, …
#> $ cohort_end_date      <date> 1976-06-17, 1993-12-03, 1930-07-01, 2000-06-29, …
#> $ proc_or_meas_0_to_0  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
```
