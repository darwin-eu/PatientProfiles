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
#> # Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2//tmp/RtmpFcBILs/file20c15822d4c7.duckdb]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1        140 2015-11-09        2015-11-23     
#>  2                    1        340 2007-10-29        2007-11-26     
#>  3                    1        412 1958-03-20        1958-04-03     
#>  4                    1        580 1946-02-07        1946-02-28     
#>  5                    1       1636 1967-05-13        1967-06-10     
#>  6                    1       1778 2015-01-14        2015-02-04     
#>  7                    1       2445 1969-01-28        1969-02-11     
#>  8                    1       2498 1972-08-03        1972-08-17     
#>  9                    1       3537 1974-12-05        1975-01-02     
#> 10                    1       3832 2001-01-26        2001-02-09     
#> # ℹ more rows

cdm$ankle_sprain |>
  addTableIntersectFlag(
    tableName = "condition_occurrence",
    window = c(-30, -1)
  ) |>
  glimpse()
#> Rows: ??
#> Columns: 5
#> Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2//tmp/RtmpFcBILs/file20c15822d4c7.duckdb]
#> $ cohort_definition_id           <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id                     <int> 412, 3537, 1545, 5200, 3486, 578, 1408,…
#> $ cohort_start_date              <date> 1958-03-20, 1974-12-05, 2013-06-25, 19…
#> $ cohort_end_date                <date> 1958-04-03, 1975-01-02, 2013-07-23, 19…
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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2//tmp/RtmpFcBILs/file20c15822d4c7.duckdb]
#> $ cohort_definition_id    <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ subject_id              <int> 2287, 4572, 5200, 1107, 3820, 2097, 2651, 1602…
#> $ cohort_start_date       <date> 1987-12-12, 1977-11-08, 1960-08-20, 2000-02-2…
#> $ cohort_end_date         <date> 1988-01-09, 1977-12-13, 1960-09-03, 2000-03-0…
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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2//tmp/RtmpFcBILs/file20c15822d4c7.duckdb]
#> $ cohort_definition_id    <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ subject_id              <int> 2287, 4572, 5200, 1107, 3820, 2097, 2651, 1602…
#> $ cohort_start_date       <date> 1987-12-12, 1977-11-08, 1960-08-20, 2000-02-2…
#> $ cohort_end_date         <date> 1988-01-09, 1977-12-13, 1960-09-03, 2000-03-0…
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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2//tmp/RtmpFcBILs/file20c15822d4c7.duckdb]
#> $ cohort_definition_id     <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id               <int> 412, 1636, 2498, 4222, 1231, 652, 2287, 4572,…
#> $ cohort_start_date        <date> 1958-03-20, 1967-05-13, 1972-08-03, 1998-07-…
#> $ cohort_end_date          <date> 1958-04-03, 1967-06-10, 1972-08-17, 1998-08-…
#> $ drug_exposure_m180_to_m1 <dbl> 2, 1, 1, 1, 1, 3, 1, 1, 3, 2, 1, 1, 1, 1, 1, …

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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2//tmp/RtmpFcBILs/file20c15822d4c7.duckdb]
#> $ cohort_definition_id     <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id               <int> 412, 1636, 2498, 4222, 1231, 652, 4572, 5200,…
#> $ cohort_start_date        <date> 1958-03-20, 1967-05-13, 1972-08-03, 1998-07-…
#> $ cohort_end_date          <date> 1958-04-03, 1967-06-10, 1972-08-17, 1998-08-…
#> $ drug_exposure_m180_to_m1 <date> 1957-10-10, 1966-12-07, 1972-03-18, 1998-05-…


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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2//tmp/RtmpFcBILs/file20c15822d4c7.duckdb]
#> $ cohort_definition_id     <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id               <int> 412, 1636, 2498, 4222, 1231, 652, 4572, 5200,…
#> $ cohort_start_date        <date> 1958-03-20, 1967-05-13, 1972-08-03, 1998-07-…
#> $ cohort_end_date          <date> 1958-04-03, 1967-06-10, 1972-08-17, 1998-08-…
#> $ drug_exposure_m180_to_m1 <date> 1957-10-10, 1966-12-07, 1972-03-18, 1998-05-…
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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2//tmp/RtmpFcBILs/file20c15822d4c7.duckdb]
#> $ cohort_definition_id              <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ subject_id                        <int> 140, 340, 412, 580, 1636, 1778, 2445…
#> $ cohort_start_date                 <date> 2015-11-09, 2007-10-29, 1958-03-20,…
#> $ cohort_end_date                   <date> 2015-11-23, 2007-11-26, 1958-04-03,…
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
#> Database: DuckDB 1.4.4 [unknown@Linux 6.14.0-1017-azure:R 4.5.2//tmp/RtmpFcBILs/file20c15822d4c7.duckdb]
#> $ cohort_definition_id <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ subject_id           <int> 140, 340, 412, 580, 1636, 1778, 2445, 2498, 3537,…
#> $ cohort_start_date    <date> 2015-11-09, 2007-10-29, 1958-03-20, 1946-02-07, …
#> $ cohort_end_date      <date> 2015-11-23, 2007-11-26, 1958-04-03, 1946-02-28, …
#> $ proc_or_meas_0_to_0  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
```
