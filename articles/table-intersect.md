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
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1022-azure:R 4.6.1//tmp/RtmpLel19W/file2256172e91c0.duckdb]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1         86 1952-04-03        1952-05-02     
#>  2                    1       1776 1931-08-23        1931-09-13     
#>  3                    1       3623 2012-03-01        2012-04-05     
#>  4                    1        196 1970-12-21        1971-01-25     
#>  5                    1       1542 1992-11-16        1992-12-21     
#>  6                    1       1971 1981-08-08        1981-08-22     
#>  7                    1       2781 1988-10-12        1988-10-26     
#>  8                    1       3896 1987-09-06        1987-10-11     
#>  9                    1        304 1968-10-01        1968-11-05     
#> 10                    1        757 1988-10-13        1988-11-17     
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
#> $ subject_id                     <int> 1776, 2781, 859, 4021, 1391, 1517, 842,…
#> $ cohort_start_date              <date> 1931-08-23, 1988-10-12, 1969-01-28, 20…
#> $ cohort_end_date                <date> 1931-09-13, 1988-10-26, 1969-02-25, 20…
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
#> $ subject_id              <int> 842, 3638, 5073, 3509, 719, 3403, 2899, 387, 1…
#> $ cohort_start_date       <date> 1992-02-02, 1976-04-23, 1937-06-01, 1943-01-1…
#> $ cohort_end_date         <date> 1992-03-01, 1976-05-07, 1937-06-22, 1943-02-0…
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
#> $ subject_id              <int> 842, 3638, 5073, 3509, 719, 3403, 2899, 387, 1…
#> $ cohort_start_date       <date> 1992-02-02, 1976-04-23, 1937-06-01, 1943-01-1…
#> $ cohort_end_date         <date> 1992-03-01, 1976-05-07, 1937-06-22, 1943-02-0…
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
#> $ subject_id               <int> 1971, 4021, 3011, 842, 3638, 5073, 3849, 778,…
#> $ cohort_start_date        <date> 1981-08-08, 2016-06-21, 1978-01-19, 1992-02-…
#> $ cohort_end_date          <date> 1981-08-22, 2016-07-05, 1978-02-02, 1992-03-…
#> $ drug_exposure_m180_to_m1 <dbl> 1, 1, 1, 2, 2, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, …

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
#> $ subject_id               <int> 1971, 4021, 3011, 842, 5073, 3849, 778, 3509,…
#> $ cohort_start_date        <date> 1981-08-08, 2016-06-21, 1978-01-19, 1992-02-…
#> $ cohort_end_date          <date> 1981-08-22, 2016-07-05, 1978-02-02, 1992-03-…
#> $ drug_exposure_m180_to_m1 <date> 1981-05-12, 2016-04-13, 1977-12-13, 1992-01-…


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
#> $ subject_id               <int> 1971, 4021, 3011, 842, 5073, 3849, 778, 3509,…
#> $ cohort_start_date        <date> 1981-08-08, 2016-06-21, 1978-01-19, 1992-02-…
#> $ cohort_end_date          <date> 1981-08-22, 2016-07-05, 1978-02-02, 1992-03-…
#> $ drug_exposure_m180_to_m1 <date> 1981-05-12, 2016-04-13, 1977-12-13, 1992-01-…
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
#> $ subject_id                        <int> 86, 1776, 3623, 196, 1542, 1971, 278…
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
#> $ subject_id           <int> 86, 1776, 3623, 196, 1542, 1971, 2781, 3896, 304,…
#> $ cohort_start_date    <date> 1952-04-03, 1931-08-23, 2012-03-01, 1970-12-21, …
#> $ cohort_end_date      <date> 1952-05-02, 1931-09-13, 2012-04-05, 1971-01-25, …
#> $ proc_or_meas_0_to_0  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
```
