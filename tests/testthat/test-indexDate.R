test_that("demographic functions accept a single date as indexDate", {
  skip_on_cran()
  set.seed(11)
  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()
  indexDate <- as.Date("2000-01-01")

  withDateColumn <- cdm$cohort1 |>
    dplyr::mutate("index_date" = .env$indexDate)

  expect_equal(
    cdm$cohort1 |>
      addAgeQuery(indexDate = indexDate) |>
      dplyr::collect(),
    withDateColumn |>
      addAgeQuery(indexDate = "index_date") |>
      dplyr::select(-"index_date") |>
      dplyr::collect(),
    ignore_attr = TRUE
  )
  expect_equal(
    cdm$cohort1 |>
      addPriorObservationQuery(indexDate = indexDate) |>
      dplyr::collect(),
    withDateColumn |>
      addPriorObservationQuery(indexDate = "index_date") |>
      dplyr::select(-"index_date") |>
      dplyr::collect(),
    ignore_attr = TRUE
  )
  expect_equal(
    cdm$cohort1 |>
      addFutureObservationQuery(indexDate = indexDate) |>
      dplyr::collect(),
    withDateColumn |>
      addFutureObservationQuery(indexDate = "index_date") |>
      dplyr::select(-"index_date") |>
      dplyr::collect(),
    ignore_attr = TRUE
  )
  expect_equal(
    cdm$cohort1 |>
      addInObservationQuery(indexDate = indexDate) |>
      dplyr::collect(),
    withDateColumn |>
      addInObservationQuery(indexDate = "index_date") |>
      dplyr::select(-"index_date") |>
      dplyr::collect(),
    ignore_attr = TRUE
  )

  dropCreatedTables(cdm = cdm)
})

test_that("observation functions accept a single date as indexDate", {
  skip_on_cran()
  set.seed(11)
  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()
  indexDate <- as.Date("2000-01-01")

  withDateColumn <- cdm$cohort1 |>
    dplyr::mutate("index_date" = .env$indexDate)

  expect_equal(
    cdm$cohort1 |>
      addObservationPeriodIdQuery(indexDate = indexDate) |>
      dplyr::collect(),
    withDateColumn |>
      addObservationPeriodIdQuery(indexDate = "index_date") |>
      dplyr::select(-"index_date") |>
      dplyr::collect(),
    ignore_attr = TRUE
  )
  expect_equal(
    cdm$cohort1 |>
      filterInObservation(indexDate = indexDate) |>
      dplyr::collect(),
    withDateColumn |>
      filterInObservation(indexDate = "index_date") |>
      dplyr::select(-"index_date") |>
      dplyr::collect(),
    ignore_attr = TRUE
  )

  dropCreatedTables(cdm = cdm)
})

test_that("intersection functions accept a single date as indexDate", {
  skip_on_cran()
  set.seed(11)
  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()
  indexDate <- as.Date("2000-01-01")

  withDateColumn <- cdm$cohort1 |>
    dplyr::mutate("index_date" = .env$indexDate)

  expect_equal(
    cdm$cohort1 |>
      addTableIntersectCount(
        tableName = "drug_exposure", indexDate = indexDate
      ) |>
      dplyr::collect(),
    withDateColumn |>
      addTableIntersectCount(
        tableName = "drug_exposure", indexDate = "index_date"
      ) |>
      dplyr::select(-"index_date") |>
      dplyr::collect(),
    ignore_attr = TRUE
  )
  expect_equal(
    cdm$cohort1 |>
      addDeathFlag(indexDate = indexDate) |>
      dplyr::collect(),
    withDateColumn |>
      addDeathFlag(indexDate = "index_date") |>
      dplyr::select(-"index_date") |>
      dplyr::collect(),
    ignore_attr = TRUE
  )

  dropCreatedTables(cdm = cdm)
})

test_that("a literal indexDate must be one non-missing date", {
  skip_on_cran()
  set.seed(11)
  cdm <- mockPatientProfiles(source = "local")

  expect_error(
    addAgeQuery(cdm$cohort1, indexDate = as.Date(c("2000-01-01", "2001-01-01"))),
    "single non-missing date"
  )
  expect_error(
    addAgeQuery(cdm$cohort1, indexDate = as.Date(NA)),
    "single non-missing date"
  )
})
