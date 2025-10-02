test_that("test benchmark function", {
  skip_on_cran()
  cdm <- omock::mockCdmFromDataset(datasetName = "GiBleed", source = "local") |>
    copyCdm()

  result <- benchmarkPatientProfiles(cdm = cdm, n = 1000)

  expect_true(inherits(result, "summarised_result"))

  dropCreatedTables(cdm = cdm)
})
