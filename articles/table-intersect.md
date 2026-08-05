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
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1//tmp/RtmpJ5Km0p/file24412e593270.duckdb]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1       1357 2000-05-19        2000-06-09     
#>  2                    1       2233 1987-01-13        1987-02-17     
#>  3                    1       2439 1989-10-25        1989-11-08     
#>  4                    1       2975 2000-01-19        2000-02-16     
#>  5                    1       3942 2004-09-05        2004-10-10     
#>  6                    1       3997 1979-06-07        1979-06-21     
#>  7                    1       4678 2017-12-01        2017-12-22     
#>  8                    1       5117 2017-12-09        2017-12-30     
#>  9                    1       5172 1956-08-24        1956-09-21     
#> 10                    1       2461 1976-01-13        1976-01-27     
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
#> $ subject_id                     <int> 5165, 260, 4348, 97, 1486, 4847, 4847, …
#> $ cohort_start_date              <date> 2008-03-21, 1971-06-02, 2000-11-01, 19…
#> $ cohort_end_date                <date> 2008-04-04, 1971-06-16, 2000-11-15, 19…
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
#> $ subject_id              <int> 3064, 5165, 564, 97, 4942, 3869, 608, 1335, 30…
#> $ cohort_start_date       <date> 1997-01-30, 2008-03-21, 2006-08-19, 1992-09-0…
#> $ cohort_end_date         <date> 1997-03-06, 2008-04-04, 2006-09-09, 1992-10-0…
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
#> $ subject_id              <int> 3064, 5165, 564, 97, 4942, 3869, 608, 1335, 30…
#> $ cohort_start_date       <date> 1997-01-30, 2008-03-21, 2006-08-19, 1992-09-0…
#> $ cohort_end_date         <date> 1997-03-06, 2008-04-04, 2006-09-09, 1992-10-0…
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
#> $ subject_id               <int> 5172, 3064, 5165, 260, 1099, 1808, 564, 2002,…
#> $ cohort_start_date        <date> 1956-08-24, 1997-01-30, 2008-03-21, 1971-06-…
#> $ cohort_end_date          <date> 1956-09-21, 1997-03-06, 2008-04-04, 1971-06-…
#> $ drug_exposure_m180_to_m1 <dbl> 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, …

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
#> $ subject_id               <int> 5172, 3064, 5165, 260, 1099, 1808, 564, 2002,…
#> $ cohort_start_date        <date> 1956-08-24, 1997-01-30, 2008-03-21, 1971-06-…
#> $ cohort_end_date          <date> 1956-09-21, 1997-03-06, 2008-04-04, 1971-06-…
#> $ drug_exposure_m180_to_m1 <date> 1956-06-23, 1997-01-23, 2008-02-20, 1971-03-…


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
#> $ subject_id               <int> 5172, 3064, 5165, 260, 1099, 1808, 564, 2002,…
#> $ cohort_start_date        <date> 1956-08-24, 1997-01-30, 2008-03-21, 1971-06-…
#> $ cohort_end_date          <date> 1956-09-21, 1997-03-06, 2008-04-04, 1971-06-…
#> $ drug_exposure_m180_to_m1 <date> 1956-06-23, 1997-01-23, 2008-02-20, 1971-03-…
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
#> $ subject_id                        <int> 1357, 2233, 2439, 2975, 3942, 3997, …
#> $ cohort_start_date                 <date> 2000-05-19, 1987-01-13, 1989-10-25,…
#> $ cohort_end_date                   <date> 2000-06-09, 1987-02-17, 1989-11-08,…
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
#> $ subject_id           <int> 1357, 2233, 2439, 2975, 3942, 3997, 4678, 5117, 5…
#> $ cohort_start_date    <date> 2000-05-19, 1987-01-13, 1989-10-25, 2000-01-19, …
#> $ cohort_end_date      <date> 2000-06-09, 1987-02-17, 1989-11-08, 2000-02-16, …
#> $ proc_or_meas_0_to_0  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
```
