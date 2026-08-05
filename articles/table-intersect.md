# Adding table intersections

So far we’ve seen that we can add variables indicating intersections
based on cohorts or concept sets. One additional option we have is to
simply add an intersection based on a table.

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
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1//tmp/RtmpiHZEZb/file24725c75c239.duckdb]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1        842 1992-02-02        1992-03-01     
#>  2                    1        921 1971-01-10        1971-02-07     
#>  3                    1       1318 1972-07-10        1972-07-31     
#>  4                    1       1635 1976-07-29        1976-08-19     
#>  5                    1       1846 2003-06-23        2003-07-14     
#>  6                    1       2184 2019-05-30        2019-05-30     
#>  7                    1       2409 1989-07-05        1989-07-19     
#>  8                    1       3410 1978-02-06        1978-03-06     
#>  9                    1       4480 1979-06-10        1979-07-01     
#> 10                    1       5046 1971-09-03        1971-10-08     
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
#> $ subject_id                     <int> 842, 1855, 3509, 859, 1776, 2781, 3638,…
#> $ cohort_start_date              <date> 1992-02-02, 1978-10-31, 1943-01-11, 19…
#> $ cohort_end_date                <date> 1992-03-01, 1978-11-14, 1943-02-01, 19…
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
#> $ subject_id              <int> 842, 3509, 3638, 5073, 2899, 719, 1568, 3403, …
#> $ cohort_start_date       <date> 1992-02-02, 1943-01-11, 1976-04-23, 1937-06-0…
#> $ cohort_end_date         <date> 1992-03-01, 1943-02-01, 1976-05-07, 1937-06-2…
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
#> $ subject_id              <int> 842, 3509, 3638, 5073, 2899, 719, 1568, 3403, …
#> $ cohort_start_date       <date> 1992-02-02, 1943-01-11, 1976-04-23, 1937-06-0…
#> $ cohort_end_date         <date> 1992-03-01, 1943-02-01, 1976-05-07, 1937-06-2…
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
#> $ subject_id               <int> 842, 3509, 1971, 3638, 5073, 4021, 3849, 778,…
#> $ cohort_start_date        <date> 1992-02-02, 1943-01-11, 1981-08-08, 1976-04-…
#> $ cohort_end_date          <date> 1992-03-01, 1943-02-01, 1981-08-22, 1976-05-…
#> $ drug_exposure_m180_to_m1 <dbl> 2, 1, 1, 2, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 3, …

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
#> $ subject_id               <int> 842, 3509, 1971, 5073, 4021, 3849, 778, 3011,…
#> $ cohort_start_date        <date> 1992-02-02, 1943-01-11, 1981-08-08, 1937-06-…
#> $ cohort_end_date          <date> 1992-03-01, 1943-02-01, 1981-08-22, 1937-06-…
#> $ drug_exposure_m180_to_m1 <date> 1992-01-28, 1942-12-12, 1981-05-12, 1937-05-…


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
#> $ subject_id               <int> 842, 3509, 1971, 5073, 4021, 3849, 778, 3011,…
#> $ cohort_start_date        <date> 1992-02-02, 1943-01-11, 1981-08-08, 1937-06-…
#> $ cohort_end_date          <date> 1992-03-01, 1943-02-01, 1981-08-22, 1937-06-…
#> $ drug_exposure_m180_to_m1 <date> 1992-01-28, 1942-12-12, 1981-05-12, 1937-05-…
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
#> $ subject_id                        <int> 842, 921, 1318, 1635, 1846, 2184, 24…
#> $ cohort_start_date                 <date> 1992-02-02, 1971-01-10, 1972-07-10,…
#> $ cohort_end_date                   <date> 1992-03-01, 1971-02-07, 1972-07-31,…
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
#> $ subject_id           <int> 842, 921, 1318, 1635, 1846, 2184, 2409, 3410, 448…
#> $ cohort_start_date    <date> 1992-02-02, 1971-01-10, 1972-07-10, 1976-07-29, …
#> $ cohort_end_date      <date> 1992-03-01, 1971-02-07, 1972-07-31, 1976-08-19, …
#> $ proc_or_meas_0_to_0  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
```
