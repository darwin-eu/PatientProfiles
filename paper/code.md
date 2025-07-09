Code for the md
================

``` r
library(CDMConnector)
library(duckdb)
```

    ## Loading required package: DBI

``` r
con <- dbConnect(duckdb(), eunomiaDir())
cdm <- cdmFromCon(con = con, cdmSchema = "main", writeSchema = "main") |>
  generateConceptCohortSet(
    conceptSet = list(gibleed = 192671), 
    name = "gibleed") |>
  generateConceptCohortSet(
    conceptSet = list(asthma = 317009, ulcerative_colitis = 81893), 
    name = "conditions")
```

    ## Note: method with signature 'DBIConnection#Id' chosen for function 'dbExistsTable',
    ##  target signature 'duckdb_connection#Id'.
    ##  "duckdb_connection#ANY" would also be valid

    ## Warning: ! 3 casted column in gibleed (cohort_attrition) as do not match expected column
    ##   type:
    ## • `reason_id` from numeric to integer
    ## • `excluded_records` from numeric to integer
    ## • `excluded_subjects` from numeric to integer

    ## Warning: ! 1 casted column in gibleed (cohort_codelist) as do not match expected column
    ##   type:
    ## • `concept_id` from numeric to integer

    ## Warning: ! 3 casted column in conditions (cohort_attrition) as do not match expected
    ##   column type:
    ## • `reason_id` from numeric to integer
    ## • `excluded_records` from numeric to integer
    ## • `excluded_subjects` from numeric to integer

    ## Warning: ! 1 casted column in conditions (cohort_codelist) as do not match expected
    ##   column type:
    ## • `concept_id` from numeric to integer

``` r
cdm
```

    ## 

    ## ── # OMOP CDM reference (duckdb) of Synthea synthetic health database ──────────

    ## • omop tables: person, observation_period, visit_occurrence, visit_detail,
    ## condition_occurrence, drug_exposure, procedure_occurrence, device_exposure,
    ## measurement, observation, death, note, note_nlp, specimen, fact_relationship,
    ## location, care_site, provider, payer_plan_period, cost, drug_era, dose_era,
    ## condition_era, metadata, cdm_source, concept, vocabulary, domain,
    ## concept_class, concept_relationship, relationship, concept_synonym,
    ## concept_ancestor, source_to_concept_map, drug_strength

    ## • cohort tables: gibleed, conditions

    ## • achilles tables: -

    ## • other tables: -

``` r
library(PatientProfiles)
cdm$gibleed |>
  addDemographics(
    indexDate = "cohort_start_date", 
    ageGroup = list("children" = c(0, 17), "adult" = c(18, Inf))
  ) |>
  dplyr::glimpse()
```

    ## Rows: ??
    ## Columns: 9
    ## Database: DuckDB v1.0.0 [root@Darwin 23.6.0:R 4.4.1//private/var/folders/pl/k11lm9710hlgl02nvzx4z9wr0000gp/T/RtmpB2rF80/file2c3a7053b02b.duckdb]
    ## $ cohort_definition_id <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
    ## $ subject_id           <int> 962, 1158, 4462, 351, 3556, 320, 1965, 2105, 2594…
    ## $ cohort_start_date    <date> 1995-07-09, 2016-12-27, 1990-10-23, 2018-06-28, …
    ## $ cohort_end_date      <date> 2019-06-14, 2017-02-15, 2018-04-27, 2018-06-29, …
    ## $ age                  <int> 44, 37, 35, 40, 35, 39, 37, 38, 40, 38, 38, 41, 3…
    ## $ age_group            <chr> "adult", "adult", "adult", "adult", "adult", "adu…
    ## $ sex                  <chr> "Male", "Female", "Female", "Female", "Male", "Fe…
    ## $ prior_observation    <int> 16312, 13658, 13045, 14821, 12874, 14487, 13633, …
    ## $ future_observation   <int> 8741, 50, 10048, 1, 1742, 8564, 3188, 2165, 1482,…

``` r
cdm$gibleed |>
  addInObservation(
    indexDate = "cohort_start_date",
    window = list("obs_index_date" = c(0, 0), "in_1_year" = c(365, 365)),
    nameStyle = "{window_name}"
  ) |>
  addObservationPeriodId() |>
  dplyr::glimpse()
```

    ## Rows: ??
    ## Columns: 7
    ## Database: DuckDB v1.0.0 [root@Darwin 23.6.0:R 4.4.1//private/var/folders/pl/k11lm9710hlgl02nvzx4z9wr0000gp/T/RtmpB2rF80/file2c3a7053b02b.duckdb]
    ## $ cohort_definition_id  <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
    ## $ subject_id            <int> 962, 1158, 4462, 351, 3556, 320, 1965, 2105, 259…
    ## $ cohort_start_date     <date> 1995-07-09, 2016-12-27, 1990-10-23, 2018-06-28,…
    ## $ cohort_end_date       <date> 2019-06-14, 2017-02-15, 2018-04-27, 2018-06-29,…
    ## $ obs_index_date        <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
    ## $ in_1_year             <int> 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, …
    ## $ observation_period_id <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …

``` r
cdm$gibleed |>
  addTableIntersectCount(
    tableName = "visit_occurrence",
    window = c(-365, 0),
    nameStyle = "number_visits"
  ) |>
  addCohortIntersectFlag(
    targetCohortTable = "conditions",
    targetCohortId = 1,
    window = c(-Inf, 0),
    nameStyle = "prior_asthma"
  ) |>
  dplyr::glimpse()
```

    ## Rows: ??
    ## Columns: 6
    ## Database: DuckDB v1.0.0 [root@Darwin 23.6.0:R 4.4.1//private/var/folders/pl/k11lm9710hlgl02nvzx4z9wr0000gp/T/RtmpB2rF80/file2c3a7053b02b.duckdb]
    ## $ cohort_definition_id <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
    ## $ subject_id           <int> 962, 351, 3556, 320, 1965, 2105, 2594, 5316, 99, …
    ## $ cohort_start_date    <date> 1995-07-09, 2018-06-28, 2013-10-15, 1995-10-19, …
    ## $ cohort_end_date      <date> 2019-06-14, 2018-06-29, 2018-07-23, 2019-03-31, …
    ## $ number_visits        <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
    ## $ prior_asthma         <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…

``` r
cdm$gibleed |>
  addCohortIntersectDate(
    targetCohortTable = "conditions",
    targetCohortId = 2,
    window = c(1, Inf), 
    nameStyle = "next_uc"
  ) |>
  dplyr::glimpse()
```

    ## Rows: ??
    ## Columns: 5
    ## Database: DuckDB v1.0.0 [root@Darwin 23.6.0:R 4.4.1//private/var/folders/pl/k11lm9710hlgl02nvzx4z9wr0000gp/T/RtmpB2rF80/file2c3a7053b02b.duckdb]
    ## $ cohort_definition_id <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
    ## $ subject_id           <int> 962, 1158, 4462, 351, 1850, 1962, 3556, 320, 1965…
    ## $ cohort_start_date    <date> 1995-07-09, 2016-12-27, 1990-10-23, 2018-06-28, …
    ## $ cohort_end_date      <date> 2019-06-14, 2017-02-15, 2018-04-27, 2018-06-29, …
    ## $ next_uc              <date> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …

``` r
cdm$gibleed <- cdm$gibleed |>
  addDemographics() |>
  addTableIntersectCount(
    tableName = "visit_occurrence",
    window = c(-365, 0),
    nameStyle = "number_visits"
  ) |>
  addCohortIntersectFlag(
    targetCohortTable = "conditions",
    targetCohortId = 1,
    window = c(-Inf, 0),
    nameStyle = "prior_asthma"
  ) |>
  addCohortIntersectDate(
    targetCohortTable = "conditions",
    targetCohortId = 2,
    window = c(1, Inf),
    nameStyle = "next_uc"
  ) 
cdm$gibleed |>
  addCohortName() |>
  summariseResult(
    group = "cohort_name",
    strata = list("sex", c("sex", "prior_asthma")),
    variables = list(c("number_visits", "age"), c("next_uc"), "age_group"),
    estimates = list(c("median", "q25", "q75"), c("min", "max"), "count")
  ) |>
  dplyr::glimpse()
```

    ## ℹ The following estimates will be computed:
    ## • number_visits: median, q25, q75
    ## • age: median, q25, q75
    ## • next_uc: min, max
    ## ! Table is collected to memory as not all requested estimates are supported on
    ##   the database side
    ## → Start summary of data, at 2024-10-12 16:08:32.659782
    ## 
    ## ✔ Summary finished, at 2024-10-12 16:08:32.815224

    ## Rows: 50
    ## Columns: 13
    ## $ result_id        <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
    ## $ cdm_name         <chr> "Synthea synthetic health database", "Synthea synthet…
    ## $ group_name       <chr> "cohort_name", "cohort_name", "cohort_name", "cohort_…
    ## $ group_level      <chr> "gibleed", "gibleed", "gibleed", "gibleed", "gibleed"…
    ## $ strata_name      <chr> "overall", "overall", "overall", "overall", "overall"…
    ## $ strata_level     <chr> "overall", "overall", "overall", "overall", "overall"…
    ## $ variable_name    <chr> "number records", "number subjects", "age", "age", "a…
    ## $ variable_level   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ estimate_name    <chr> "count", "count", "median", "q25", "q75", "median", "…
    ## $ estimate_type    <chr> "integer", "integer", "integer", "integer", "integer"…
    ## $ estimate_value   <chr> "479", "479", "38", "36", "41", "1", "1", "1", NA, NA…
    ## $ additional_name  <chr> "overall", "overall", "overall", "overall", "overall"…
    ## $ additional_level <chr> "overall", "overall", "overall", "overall", "overall"…
