test_that("filterCohortId", {
  skip_on_cran()
  set.seed(seed = 1)
  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()

  expect_no_error(x1 <- cdm$cohort1 |> filterCohortId())
  expect_no_error(x2 <- cdm$cohort1 |> filterCohortId(cohortId = 1L))
  expect_no_error(x3 <- cdm$cohort1 |> filterCohortId(cohortId = c(1L, 2L, 3L)))

  expect_identical(cdm$cohort1, x1)
  expect_identical(x1, x3)

  if (dbToTest != "local") {
    expect_true(dbplyr::remote_name(cdm$cohort1) == "pp_test_cohort1")
    expect_true(dbplyr::remote_name(x1) == "pp_test_cohort1")
    expect_true(is.null(dbplyr::remote_name(x2)))
    expect_true(dbplyr::remote_name(x3) == "pp_test_cohort1")

    expect_true(cdm$cohort1 |> dplyr::show_query() |> capture.output() |> length() == 3)
    expect_true(x1 |> dplyr::show_query() |> capture.output() |> length() == 3)
    expect_true(x2 |> dplyr::show_query() |> capture.output() |> length() == 4)
    expect_true(x3 |> dplyr::show_query() |> capture.output() |> length() == 3)
  }

  dropCreatedTables(cdm = cdm)
})
