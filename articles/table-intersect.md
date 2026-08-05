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
#> # Database: DuckDB 1.5.5 [unknown@Linux 6.17.0-1020-azure:R 4.6.1//tmp/RtmpJOolLa/file24f51bd6a74f.duckdb]
#>    cohort_definition_id subject_id cohort_start_date cohort_end_date
#>                   <int>      <int> <date>            <date>         
#>  1                    1         86 2014-12-28        2015-01-25     
#>  2                    1        187 1999-04-21        1999-05-26     
#>  3                    1        756 1982-09-04        1982-09-18     
#>  4                    1       1357 1976-01-21        1976-02-25     
#>  5                    1       1776 1920-09-07        1920-10-05     
#>  6                    1       2702 1999-09-18        1999-10-09     
#>  7                    1       2846 1978-03-26        1978-04-09     
#>  8                    1       3686 2016-10-01        2016-10-29     
#>  9                    1        152 2017-02-26        2017-03-19     
#> 10                    1       1947 1954-03-20        1954-04-03     
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
#> $ subject_id                     <int> 2846, 152, 2574, 1739, 1793, 388, 685, …
#> $ cohort_start_date              <date> 1978-03-26, 2017-02-26, 1973-01-30, 19…
#> $ cohort_end_date                <date> 1978-04-09, 2017-03-19, 1973-03-06, 19…
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
#> $ subject_id              <int> 152, 3442, 2287, 1107, 1602, 2588, 1764, 1053,…
#> $ cohort_start_date       <date> 2017-02-26, 2011-07-15, 1987-12-12, 2000-02-2…
#> $ cohort_end_date         <date> 2017-03-19, 2011-08-19, 1988-01-09, 2000-03-0…
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
#> $ subject_id              <int> 152, 3442, 2287, 1107, 1602, 2588, 1764, 1053,…
#> $ cohort_start_date       <date> 2017-02-26, 2011-07-15, 1987-12-12, 2000-02-2…
#> $ cohort_end_date         <date> 2017-03-19, 2011-08-19, 1988-01-09, 2000-03-0…
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
#> $ subject_id               <int> 756, 1357, 2846, 152, 3442, 3232, 3625, 3469,…
#> $ cohort_start_date        <date> 1982-09-04, 1976-01-21, 1978-03-26, 2017-02-…
#> $ cohort_end_date          <date> 1982-09-18, 1976-02-25, 1978-04-09, 2017-03-…
#> $ drug_exposure_m180_to_m1 <dbl> 1, 1, 2, 1, 2, 2, 1, 1, 1, 1, 2, 1, 1, 1, 2, …

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
#> $ subject_id               <int> 1357, 2846, 152, 3442, 3232, 3625, 3469, 4077…
#> $ cohort_start_date        <date> 1976-01-21, 1978-03-26, 2017-02-26, 2011-07-…
#> $ cohort_end_date          <date> 1976-02-25, 1978-04-09, 2017-03-19, 2011-08-…
#> $ drug_exposure_m180_to_m1 <date> 1975-09-05, 1977-10-11, 2017-01-26, 2011-06-…


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
#> $ subject_id               <int> 1357, 2846, 152, 3442, 3232, 3625, 3469, 4077…
#> $ cohort_start_date        <date> 1976-01-21, 1978-03-26, 2017-02-26, 2011-07-…
#> $ cohort_end_date          <date> 1976-02-25, 1978-04-09, 2017-03-19, 2011-08-…
#> $ drug_exposure_m180_to_m1 <date> 1975-09-05, 1977-10-11, 2017-01-26, 2011-06-…
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
#> $ subject_id                        <int> 86, 187, 756, 1357, 1776, 2702, 2846…
#> $ cohort_start_date                 <date> 2014-12-28, 1999-04-21, 1982-09-04,…
#> $ cohort_end_date                   <date> 2015-01-25, 1999-05-26, 1982-09-18,…
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
#> $ subject_id           <int> 86, 187, 756, 1357, 1776, 2702, 2846, 3686, 152, …
#> $ cohort_start_date    <date> 2014-12-28, 1999-04-21, 1982-09-04, 1976-01-21, …
#> $ cohort_end_date      <date> 2015-01-25, 1999-05-26, 1982-09-18, 1976-02-25, …
#> $ proc_or_meas_0_to_0  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
```
