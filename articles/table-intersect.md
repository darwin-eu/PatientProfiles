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
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1022-azure:R 4.6.1//tmp/RtmpyomLiK/file238a1e34b51.duckdb]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1        759 1973-12-23        1974-01-06     
#>  2                    1        950 1985-05-26        1985-06-16     
#>  3                    1        971 1965-08-20        1965-09-17     
#>  4                    1       1281 2008-10-31        2008-11-28     
#>  5                    1       2709 1942-12-20        1943-01-17     
#>  6                    1       3811 1985-10-05        1985-11-09     
#>  7                    1        327 1985-11-05        1985-12-10     
#>  8                    1        691 1971-07-20        1971-08-03     
#>  9                    1       1057 1963-03-12        1963-03-26     
#> 10                    1       1118 1996-07-26        1996-08-16     
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
#> $ subject_id                     <int> 1057, 2749, 225, 3353, 2902, 3580, 1328…
#> $ cohort_start_date              <date> 1963-03-12, 1974-04-08, 1973-08-09, 19…
#> $ cohort_end_date                <date> 1963-03-26, 1974-04-29, 1973-08-30, 19…
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
#> $ subject_id              <int> 1057, 2749, 1107, 1258, 1053, 1764, 2131, 4523…
#> $ cohort_start_date       <date> 1963-03-12, 1974-04-08, 1980-08-19, 1983-05-1…
#> $ cohort_end_date         <date> 1963-03-26, 1974-04-29, 1980-09-02, 1983-06-0…
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
#> $ subject_id              <int> 1057, 2749, 1107, 1258, 1053, 1764, 2131, 4523…
#> $ cohort_start_date       <date> 1963-03-12, 1974-04-08, 1980-08-19, 1983-05-1…
#> $ cohort_end_date         <date> 1963-03-26, 1974-04-29, 1980-09-02, 1983-06-0…
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
#> $ subject_id               <int> 950, 1057, 1118, 859, 3899, 300, 2749, 680, 3…
#> $ cohort_start_date        <date> 1985-05-26, 1963-03-12, 1996-07-26, 2007-08-…
#> $ cohort_end_date          <date> 1985-06-16, 1963-03-26, 1996-08-16, 2007-09-…
#> $ drug_exposure_m180_to_m1 <dbl> 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 3, …

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
#> $ subject_id               <int> 950, 1057, 859, 3899, 300, 2749, 680, 3876, 3…
#> $ cohort_start_date        <date> 1985-05-26, 1963-03-12, 2007-08-10, 1985-05-…
#> $ cohort_end_date          <date> 1985-06-16, 1963-03-26, 2007-09-07, 1985-06-…
#> $ drug_exposure_m180_to_m1 <date> 1984-12-20, 1963-02-11, 2007-04-09, 1984-12-…


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
#> $ subject_id               <int> 950, 1057, 859, 3899, 300, 2749, 680, 3876, 3…
#> $ cohort_start_date        <date> 1985-05-26, 1963-03-12, 2007-08-10, 1985-05-…
#> $ cohort_end_date          <date> 1985-06-16, 1963-03-26, 2007-09-07, 1985-06-…
#> $ drug_exposure_m180_to_m1 <date> 1984-12-20, 1963-02-11, 2007-04-09, 1984-12-…
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
#> $ subject_id                        <int> 759, 950, 971, 1281, 2709, 3811, 327…
#> $ cohort_start_date                 <date> 1973-12-23, 1985-05-26, 1965-08-20,…
#> $ cohort_end_date                   <date> 1974-01-06, 1985-06-16, 1965-09-17,…
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
#> $ subject_id           <int> 759, 950, 971, 1281, 2709, 3811, 327, 691, 1057, …
#> $ cohort_start_date    <date> 1973-12-23, 1985-05-26, 1965-08-20, 2008-10-31, …
#> $ cohort_end_date      <date> 1974-01-06, 1985-06-16, 1965-09-17, 2008-11-28, …
#> $ proc_or_meas_0_to_0  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
```
