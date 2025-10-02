test_that("check input length and type for each of the arguments", {
  skip_on_cran()
  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()

  expect_error(addFutureObservation("cdm$cohort1"))

  expect_error(addFutureObservation(cdm$cohort1, indexDate = "end_date"))

  dropCreatedTables(cdm = cdm)
})

test_that("check condition_occurrence and cohort1 work", {
  skip_on_cran()
  # mock data
  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()

  # check it works with cohort1 table in mockdb
  expect_true(typeof(cdm$cohort1 |> addFutureObservation() |> dplyr::collect()) == "list")
  expect_true("future_observation" %in% colnames(cdm$cohort1 |> addFutureObservation()))
  # check it works with condition_occurrence table in mockdb
  expect_true(typeof(cdm$condition_occurrence |> addFutureObservation(indexDate = "condition_start_date") |> dplyr::collect()) == "list")
  expect_true("future_observation" %in% colnames(cdm$condition_occurrence |> addFutureObservation(indexDate = "condition_start_date")))

  dropCreatedTables(cdm = cdm)
})

test_that("check working example with cohort1", {
  skip_on_cran()
  # create mock tables for testing
  cohort1 <- dplyr::tibble(
    cohort_definition_id = 1L,
    subject_id = c(1, 2, 3),
    cohort_start_date = as.Date(c("2010-03-03", "2010-03-01", "2010-02-01")),
    cohort_end_date = cohort_start_date
  )

  obs1 <- dplyr::tibble(
    observation_period_id = c(1, 2, 3),
    person_id = c(1, 2, 3),
    observation_period_start_date = as.Date(c(
      "2010-02-03", "2010-02-01", "2010-01-01"
    )),
    observation_period_end_date = as.Date(c(
      "2014-01-01", "2012-01-01", "2012-01-01"
    )),
    period_type_concept_id = 0L
  )

  set.seed(seed = 1)
  cdm <- mockPatientProfiles(
    cohort1 = cohort1,
    observation_period = obs1,
    cohort2 = cohort1,
    source = "local"
  ) |>
    copyCdm()

  result <- cdm$cohort1 |>
    addFutureObservation() |>
    dplyr::collect()

  expect_true(all(colnames(cohort1) %in% colnames(result)))

  expect_true(all(result |>
    dplyr::select("future_observation") ==
    dplyr::tibble(
      future_observation =
        c(
          as.numeric(difftime(as.Date("2014-01-01"),
            as.Date("2010-03-03"),
            units = "days"
          )),
          as.numeric(difftime(as.Date("2012-01-01"),
            as.Date("2010-03-01"),
            units = "days"
          )),
          as.numeric(difftime(as.Date("2012-01-01"),
            as.Date("2010-02-01"),
            units = "days"
          ))
        )
    )))

  dropCreatedTables(cdm = cdm)
})

test_that("check working example with condition_occurrence", {
  skip_on_cran()
  # create mock tables for testing
  condition_occurrence <- dplyr::tibble(
    condition_occurrence_id = 1L,
    person_id = 1:3,
    condition_concept_id = 0L,
    condition_type_concept_id = 0L,
    condition_start_date = as.Date(c("2010-03-03", "2010-03-01", "2010-02-01")),
    condition_end_date = as.Date(c("2015-01-01", "2013-01-01", "2013-01-01"))
  )

  obs1 <- dplyr::tibble(
    observation_period_id = 1:3,
    person_id = 1:3,
    observation_period_start_date = as.Date(c(
      "2010-02-03", "2010-02-01", "2010-01-01"
    )),
    observation_period_end_date = as.Date(c(
      "2014-01-01", "2012-01-01", "2012-01-01"
    )),
    period_type_concept_id = 0L
  )

  set.seed(seed = 1)
  cdm <- mockPatientProfiles(
    condition_occurrence = condition_occurrence,
    observation_period = obs1,
    source = "local"
  ) |>
    copyCdm()

  result <- cdm$condition_occurrence |>
    addFutureObservation(indexDate = "condition_start_date") |>
    dplyr::collect()

  expect_true(all(
    result |> dplyr::select("future_observation") ==
      dplyr::tibble(
        future_observation =
          c(
            as.numeric(difftime(as.Date("2014-01-01"),
              as.Date("2010-03-03"),
              units = "days"
            )),
            as.numeric(difftime(as.Date("2012-01-01"),
              as.Date("2010-03-01"),
              units = "days"
            )),
            as.numeric(difftime(as.Date("2012-01-01"),
              as.Date("2010-02-01"),
              units = "days"
            ))
          )
      )
  ))

  dropCreatedTables(cdm = cdm)
})

test_that("different name", {
  skip_on_cran()
  # create mock tables for testing
  condition_occurrence <- dplyr::tibble(
    condition_occurrence_id = 1L,
    person_id = 1:3,
    condition_start_date = as.Date(c("2010-03-03", "2010-03-01", "2010-02-01")),
    condition_end_date = as.Date(c("2015-01-01", "2013-01-01", "2013-01-01")),
    condition_concept_id = 0L,
    condition_type_concept_id = 0L
  )

  obs1 <- dplyr::tibble(
    observation_period_id = 1:3,
    person_id = 1:3,
    observation_period_start_date = as.Date(c(
      "2010-02-03", "2010-02-01", "2010-01-01"
    )),
    observation_period_end_date = as.Date(c(
      "2014-01-01", "2012-01-01", "2012-01-01"
    )),
    period_type_concept_id = 0L
  )

  set.seed(seed = 1)
  cdm <- mockPatientProfiles(
    condition_occurrence = condition_occurrence,
    observation_period = obs1,
    source = "local"
  ) |>
    copyCdm()

  cdm$condition_occurrence <- cdm$condition_occurrence |>
    addFutureObservation(
      indexDate = "condition_start_date", futureObservationName = "fh"
    )
  expect_true("fh" %in% colnames(cdm$condition_occurrence))

  x <- cdm$cohort1 |>
    addFutureObservation(futureObservationType = "days") |>
    addFutureObservation(
      futureObservationType = "date", futureObservationName = "col"
    ) |>
    dplyr::left_join(
      cdm$observation_period |>
        dplyr::select(
          "subject_id" = "person_id",
          "obs_end" = "observation_period_end_date"
        ),
      by = "subject_id"
    ) |>
    dplyr::mutate("diff" = clock::date_count_between(
      start = .data$cohort_start_date, end = .data$obs_end, precision = "day"
    )) |>
    dplyr::collect()

  expect_equal(x$future_observation, x$diff)
  expect_equal(x$col, x$obs_end)

  dropCreatedTables(cdm = cdm)
})

test_that("priorHistory and future_observation - outside of observation period", {
  skip_on_cran()
  # futureHistory should be NA if index date is outside of an observation period
  person <- dplyr::tibble(
    person_id = 1:2,
    gender_concept_id = 1L,
    year_of_birth = 1980L,
    month_of_birth = 1L,
    day_of_birth = 1L,
    race_concept_id = 0L,
    ethnicity_concept_id = 0L
  )
  observation_period <- dplyr::tibble(
    observation_period_id = 1:2,
    person_id = 1:2,
    observation_period_start_date = as.Date(c("2000-01-01", "2014-01-01")),
    observation_period_end_date = as.Date(c("2001-01-01", "2015-01-01")),
    period_type_concept_id = 0L
  )
  co <- dplyr::tibble(
    condition_occurrence_id = 1:2,
    person_id = 1:2,
    condition_start_date = as.Date(c("2012-02-01")),
    condition_end_date = as.Date(c("2013-02-01")),
    condition_concept_id = 0L,
    condition_type_concept_id = 0L
  )

  cdm <- mockPatientProfiles(
    person = person,
    observation_period = observation_period,
    condition_occurrence = co,
    source = "local"
  ) |>
    copyCdm()

  cdm$cohort1a <- cdm$condition_occurrence |>
    addFutureObservation(indexDate = "condition_start_date")
  # both should be NA
  expect_true(all(is.na(cdm$cohort1a |> dplyr::pull(future_observation))))

  dropCreatedTables(cdm = cdm)
})

test_that("multiple observation periods", {
  skip_on_cran()
  # with multiple observation periods,
  # future history should relate to the current observation period

  person <- dplyr::tibble(
    person_id = 1:2,
    gender_concept_id = 1L,
    year_of_birth = 1980,
    month_of_birth = 1L,
    day_of_birth = 1L,
    race_concept_id = 0L,
    ethnicity_concept_id = 0
  )
  observation_period <- dplyr::tibble(
    observation_period_id = 1:3,
    person_id = c(1, 1, 2),
    observation_period_start_date = as.Date(c(
      "2000-01-01", "2010-01-01", "2010-01-01"
    )),
    observation_period_end_date = as.Date(c(
      "2005-01-01", "2015-01-01", "2015-01-01"
    )),
    period_type_concept_id = 0L
  )
  cohort1 <- dplyr::tibble(
    cohort_definition_id = 1,
    subject_id = c(1, 2),
    cohort_start_date = as.Date(c("2012-02-01")),
    cohort_end_date = as.Date(c("2013-02-01"))
  )

  cdm <- mockPatientProfiles(
    person = person,
    observation_period = observation_period,
    cohort1 = cohort1,
    source = "local"
  ) |>
    copyCdm()

  cdm$cohort1a <- cdm$cohort1 |>
    addFutureObservation(indexDate = "cohort_start_date")

  expect_true(nrow(cdm$cohort1a |> dplyr::collect()) == 2)
  expect_true(all(cdm$cohort1a |> dplyr::pull(future_observation) ==
    as.numeric(difftime(as.Date("2015-01-01"),
      as.Date("2012-02-01"),
      units = "days"
    ))))

  # from cohort end date
  cdm$cohort1a <- cdm$cohort1 |>
    addFutureObservation(
      indexDate = "cohort_end_date",
      futureObservationName = "fh_from_c_end"
    )
  expect_true(all(cdm$cohort1a |> dplyr::pull("fh_from_c_end") ==
    as.numeric(difftime(as.Date("2015-01-01"),
      as.Date("2013-02-01"),
      units = "days"
    ))))

  dropCreatedTables(cdm = cdm)
})
