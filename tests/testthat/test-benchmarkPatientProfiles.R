test_that("test benchmark function", {
  skip_on_cran()
  con <- duckdb::dbConnect(duckdb::duckdb(), CDMConnector::eunomiaDir())
  cdm <- CDMConnector::cdmFromCon(
    con = con, cdmSchema = "main", writeSchema = "main"
  )

  result <- benchmarkPatientProfiles(cdm = cdm, n = 1000)

  expect_true(inherits(result, "summarised_result"))

  omopgenerics::cdmDisconnect(cdm = cdm)
})
