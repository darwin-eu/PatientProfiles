test_that("errors for mock", {
  skip_on_cran()
  expect_no_error(cdm <- mockPatientProfiles(source = "local"))

  expect_true(all(c(
    "concept", "vocabulary", "concept_relationship", "concept_synonym",
    "concept_ancestor", "drug_strength"
  ) %in% names(cdm)))
  conceptIds <- cdm$concept |>
    dplyr::pull("concept_id")
  expect_true(all(cdm$drug_exposure |>
    dplyr::pull("drug_concept_id") %in% conceptIds))
  expect_true(all(cdm$condition_occurrence |>
    dplyr::pull("condition_concept_id") %in% conceptIds))

  expect_no_error(cdm <- mockPatientProfiles(source = "duckdb"))
  expect_true(inherits(cdm, "cdm_reference"))
})
