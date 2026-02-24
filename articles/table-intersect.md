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
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpKTJczE/file236614828c4b.duckdb]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1       2097 1982-11-04        1982-12-02     
#>  2                    1       2406 1958-01-20        1958-02-17     
#>  3                    1       2437 2018-04-04        2018-05-02     
#>  4                    1       2651 1951-06-24        1951-07-29     
#>  5                    1       3219 1990-08-24        1990-09-28     
#>  6                    1       4649 1978-08-22        1978-09-05     
#>  7                    1       5056 2013-09-30        2013-10-14     
#>  8                    1       1545 2013-06-25        2013-07-23     
#>  9                    1       2915 1974-01-12        1974-01-26     
#> 10                    1       3218 1966-01-09        1966-01-30     
#> # ℹ more rows

cdm$ankle_sprain |>
  addTableIntersectFlag(
    tableName = "condition_occurrence",
    window = c(-30, -1)
  ) |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpKTJczE/file236614828c4b.duckdb]
#> $ cohort_definition_id           <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id                     <int> 2097, 2651, 1545, 3486, 412, 3537, 1356…
#> $ cohort_start_date              <date> 1982-11-04, 1951-06-24, 2013-06-25, 19…
#> $ cohort_end_date                <date> 1982-12-02, 1951-07-29, 2013-07-23, 19…
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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpKTJczE/file236614828c4b.duckdb]
#> $ cohort_definition_id    <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ subject_id              <int> 2097, 2651, 3820, 1602, 2287, 4572, 5200, 1107…
#> $ cohort_start_date       <date> 1982-11-04, 1951-06-24, 1989-08-16, 2013-04-1…
#> $ cohort_end_date         <date> 1982-12-02, 1951-07-29, 1989-09-20, 2013-05-2…
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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpKTJczE/file236614828c4b.duckdb]
#> $ cohort_definition_id    <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ subject_id              <int> 2097, 2651, 3820, 1602, 2287, 4572, 5200, 1107…
#> $ cohort_start_date       <date> 1982-11-04, 1951-06-24, 1989-08-16, 2013-04-1…
#> $ cohort_end_date         <date> 1982-12-02, 1951-07-29, 1989-09-20, 2013-05-2…
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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpKTJczE/file236614828c4b.duckdb]
#> $ cohort_definition_id     <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id               <int> 2097, 2651, 4222, 3268, 3820, 412, 1636, 2498…
#> $ cohort_start_date        <date> 1982-11-04, 1951-06-24, 1998-07-29, 1970-07-…
#> $ cohort_end_date          <date> 1982-12-02, 1951-07-29, 1998-08-26, 1970-08-…
#> $ drug_exposure_m180_to_m1 <dbl> 3, 5, 1, 1, 1, 2, 1, 1, 1, 1, 3, 1, 1, 3, 2, …

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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpKTJczE/file236614828c4b.duckdb]
#> $ cohort_definition_id     <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id               <int> 2097, 2651, 4222, 3268, 412, 1636, 2498, 3059…
#> $ cohort_start_date        <date> 1982-11-04, 1951-06-24, 1998-07-29, 1970-07-…
#> $ cohort_end_date          <date> 1982-12-02, 1951-07-29, 1998-08-26, 1970-08-…
#> $ drug_exposure_m180_to_m1 <date> 1982-09-24, 1951-05-25, 1998-05-19, 1970-03-…


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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpKTJczE/file236614828c4b.duckdb]
#> $ cohort_definition_id     <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id               <int> 2097, 2651, 4222, 3268, 412, 1636, 2498, 3059…
#> $ cohort_start_date        <date> 1982-11-04, 1951-06-24, 1998-07-29, 1970-07-…
#> $ cohort_end_date          <date> 1982-12-02, 1951-07-29, 1998-08-26, 1970-08-…
#> $ drug_exposure_m180_to_m1 <date> 1982-09-24, 1951-05-25, 1998-05-19, 1970-03-…
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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpKTJczE/file236614828c4b.duckdb]
#> $ cohort_definition_id              <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id                        <int> 2097, 2406, 2437, 2651, 3219, 4649, …
#> $ cohort_start_date                 <date> 1982-11-04, 1958-01-20, 2018-04-04,…
#> $ cohort_end_date                   <date> 1982-12-02, 1958-02-17, 2018-05-02,…
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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.11.0-1018-azure:R 4.5.2//tmp/RtmpKTJczE/file236614828c4b.duckdb]
#> $ cohort_definition_id <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ subject_id           <int> 2097, 2406, 2437, 2651, 3219, 4649, 5056, 1545, 2…
#> $ cohort_start_date    <date> 1982-11-04, 1958-01-20, 2018-04-04, 1951-06-24, …
#> $ cohort_end_date      <date> 1982-12-02, 1958-02-17, 2018-05-02, 1951-07-29, …
#> $ proc_or_meas_0_to_0  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
```
