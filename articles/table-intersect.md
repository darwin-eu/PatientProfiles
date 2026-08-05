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
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1//tmp/RtmpYC8P8l/file24e31f159fe4.duckdb]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1         86 1952-04-03        1952-05-02     
#>  2                    1       1776 1931-08-23        1931-09-13     
#>  3                    1       3623 2012-03-01        2012-04-05     
#>  4                    1        821 1969-08-12        1969-09-02     
#>  5                    1       3509 1943-01-11        1943-02-01     
#>  6                    1       3558 1964-01-01        1964-01-15     
#>  7                    1       4130 1998-11-19        1998-12-24     
#>  8                    1       4459 1982-05-20        1982-06-10     
#>  9                    1        859 1969-01-28        1969-02-25     
#> 10                    1       1602 1967-05-26        1967-06-30     
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
#> $ subject_id                     <int> 1776, 3509, 859, 1391, 1517, 842, 349, …
#> $ cohort_start_date              <date> 1931-08-23, 1943-01-11, 1969-01-28, 19…
#> $ cohort_end_date                <date> 1931-09-13, 1943-02-01, 1969-02-25, 19…
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
#> $ subject_id              <int> 3509, 842, 3638, 5073, 12, 4724, 160, 374, 440…
#> $ cohort_start_date       <date> 1943-01-11, 1992-02-02, 1976-04-23, 1937-06-0…
#> $ cohort_end_date         <date> 1943-02-01, 1992-03-01, 1976-05-07, 1937-06-2…
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
#> $ subject_id              <int> 3509, 842, 3638, 5073, 12, 4724, 160, 374, 440…
#> $ cohort_start_date       <date> 1943-01-11, 1992-02-02, 1976-04-23, 1937-06-0…
#> $ cohort_end_date         <date> 1943-02-01, 1992-03-01, 1976-05-07, 1937-06-2…
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
#> $ subject_id               <int> 3509, 3011, 842, 4021, 778, 1971, 3638, 5073,…
#> $ cohort_start_date        <date> 1943-01-11, 1978-01-19, 1992-02-02, 2016-06-…
#> $ cohort_end_date          <date> 1943-02-01, 1978-02-02, 1992-03-01, 2016-07-…
#> $ drug_exposure_m180_to_m1 <dbl> 1, 1, 2, 1, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1, …

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
#> $ subject_id               <int> 3509, 3011, 842, 4021, 778, 1971, 5073, 3849,…
#> $ cohort_start_date        <date> 1943-01-11, 1978-01-19, 1992-02-02, 2016-06-…
#> $ cohort_end_date          <date> 1943-02-01, 1978-02-02, 1992-03-01, 2016-07-…
#> $ drug_exposure_m180_to_m1 <date> 1942-12-12, 1977-12-13, 1992-01-28, 2016-04-…


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
#> $ subject_id               <int> 3509, 3011, 842, 4021, 778, 1971, 5073, 3849,…
#> $ cohort_start_date        <date> 1943-01-11, 1978-01-19, 1992-02-02, 2016-06-…
#> $ cohort_end_date          <date> 1943-02-01, 1978-02-02, 1992-03-01, 2016-07-…
#> $ drug_exposure_m180_to_m1 <date> 1942-12-12, 1977-12-13, 1992-01-28, 2016-04-…
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
#> $ subject_id                        <int> 86, 1776, 3623, 821, 3509, 3558, 413…
#> $ cohort_start_date                 <date> 1952-04-03, 1931-08-23, 2012-03-01,…
#> $ cohort_end_date                   <date> 1952-05-02, 1931-09-13, 2012-04-05,…
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
#> $ subject_id           <int> 86, 1776, 3623, 821, 3509, 3558, 4130, 4459, 859,…
#> $ cohort_start_date    <date> 1952-04-03, 1931-08-23, 2012-03-01, 1969-08-12, …
#> $ cohort_end_date      <date> 1952-05-02, 1931-09-13, 2012-04-05, 1969-09-02, …
#> $ proc_or_meas_0_to_0  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
```
