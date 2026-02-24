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
#> # Source:   table<results.test_ankle_sprain> [?? x 4]
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpDmL4Mr/file22fc6517f324.duckdb]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1         95 2002-08-01        2002-08-29     
#>  2                    1        863 1923-07-09        1923-07-23     
#>  3                    1       1046 1983-04-06        1983-05-11     
#>  4                    1       2798 1967-11-27        1967-12-25     
#>  5                    1       3092 2007-06-08        2007-06-22     
#>  6                    1       3263 2011-06-03        2011-06-24     
#>  7                    1       3624 1963-11-30        1963-12-14     
#>  8                    1       3932 1994-01-08        1994-01-22     
#>  9                    1       5229 1973-06-27        1973-07-11     
#> 10                    1        572 2001-02-13        2001-03-20     
#> # ℹ more rows

cdm$ankle_sprain |>
  addTableIntersectFlag(
    tableName = "condition_occurrence",
    window = c(-30, -1)
  ) |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpDmL4Mr/file22fc6517f324.duckdb]
#> $ cohort_definition_id           <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id                     <int> 863, 3624, 5229, 2747, 2402, 673, 5215,…
#> $ cohort_start_date              <date> 1923-07-09, 1963-11-30, 1973-06-27, 20…
#> $ cohort_end_date                <date> 1923-07-23, 1963-12-14, 1973-07-11, 20…
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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpDmL4Mr/file22fc6517f324.duckdb]
#> $ cohort_definition_id    <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ subject_id              <int> 2731, 4352, 5215, 5022, 1072, 4991, 863, 4909,…
#> $ cohort_start_date       <date> 1975-07-14, 2015-08-07, 2008-08-06, 2010-01-2…
#> $ cohort_end_date         <date> 1975-08-11, 2015-08-28, 2008-09-10, 2010-02-2…
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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpDmL4Mr/file22fc6517f324.duckdb]
#> $ cohort_definition_id    <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ subject_id              <int> 2731, 4352, 5215, 5022, 1072, 4991, 863, 4909,…
#> $ cohort_start_date       <date> 1975-07-14, 2015-08-07, 2008-08-06, 2010-01-2…
#> $ cohort_end_date         <date> 1975-08-11, 2015-08-28, 2008-09-10, 2010-02-2…
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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpDmL4Mr/file22fc6517f324.duckdb]
#> $ cohort_definition_id     <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id               <int> 95, 863, 3263, 264, 2731, 4352, 5334, 5215, 2…
#> $ cohort_start_date        <date> 2002-08-01, 1923-07-09, 2011-06-03, 1977-07-…
#> $ cohort_end_date          <date> 2002-08-29, 1923-07-23, 2011-06-24, 1977-08-…
#> $ drug_exposure_m180_to_m1 <dbl> 1, 2, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, …

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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpDmL4Mr/file22fc6517f324.duckdb]
#> $ cohort_definition_id     <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id               <int> 95, 863, 3263, 4352, 5334, 5215, 3701, 5022, …
#> $ cohort_start_date        <date> 2002-08-01, 1923-07-09, 2011-06-03, 2015-08-…
#> $ cohort_end_date          <date> 2002-08-29, 1923-07-23, 2011-06-24, 2015-08-…
#> $ drug_exposure_m180_to_m1 <date> 2002-03-18, 1923-04-14, 2011-02-22, 2015-07-…


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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpDmL4Mr/file22fc6517f324.duckdb]
#> $ cohort_definition_id     <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id               <int> 95, 863, 3263, 4352, 5334, 5215, 3701, 5022, …
#> $ cohort_start_date        <date> 2002-08-01, 1923-07-09, 2011-06-03, 2015-08-…
#> $ cohort_end_date          <date> 2002-08-29, 1923-07-23, 2011-06-24, 2015-08-…
#> $ drug_exposure_m180_to_m1 <date> 2002-03-18, 1923-04-14, 2011-02-22, 2015-07-…
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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpDmL4Mr/file22fc6517f324.duckdb]
#> $ cohort_definition_id              <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id                        <int> 95, 863, 1046, 2798, 3092, 3263, 362…
#> $ cohort_start_date                 <date> 2002-08-01, 1923-07-09, 1983-04-06,…
#> $ cohort_end_date                   <date> 2002-08-29, 1923-07-23, 1983-05-11,…
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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpDmL4Mr/file22fc6517f324.duckdb]
#> $ cohort_definition_id <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ subject_id           <int> 95, 863, 1046, 2798, 3092, 3263, 3624, 3932, 5229…
#> $ cohort_start_date    <date> 2002-08-01, 1923-07-09, 1983-04-06, 1967-11-27, …
#> $ cohort_end_date      <date> 2002-08-29, 1923-07-23, 1983-05-11, 1967-12-25, …
#> $ proc_or_meas_0_to_0  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
```
