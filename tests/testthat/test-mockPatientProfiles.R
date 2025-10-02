test_that("errors for mock", {
  skip_on_cran()
  expect_no_error(cdm <- mockPatientProfiles(source = "local"))
  expect_no_error(cdm <- mockPatientProfiles(source = "duckdb"))
  expect_true(inherits(cdm, "cdm_reference"))
})
