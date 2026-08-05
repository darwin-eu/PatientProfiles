cohortEventTestCdm <- function() {
  cohort1 <- dplyr::tibble(
    cohort_definition_id = 1L,
    subject_id = 1:5,
    cohort_start_date = as.Date(c(
      "2020-01-10", "2020-01-10", "2020-01-10",
      "2020-01-10", "2020-01-10"
    )),
    cohort_end_date = as.Date(c(
      "2020-01-10", "2020-01-10", "2020-01-10",
      "2020-01-10", "2020-01-10"
    )),
    censor_date = as.Date(c(
      "2020-01-14", "2020-01-14", "2020-01-20",
      "2020-01-14", "2020-01-14"
    ))
  )
  cohort2 <- dplyr::tibble(
    cohort_definition_id = c(2L, 1L, 2L, 1L, 1L, 2L, 1L),
    subject_id = c(1L, 1L, 1L, 3L, 4L, 4L, 5L),
    cohort_start_date = as.Date(c(
      "2020-01-12", "2020-01-12", "2020-01-15", "2020-01-20",
      "2020-01-14", "2020-01-15", "2020-01-08"
    )),
    cohort_end_date = as.Date(c(
      "2020-01-12", "2020-01-12", "2020-01-15", "2020-01-20",
      "2020-01-14", "2020-01-15", "2020-01-08"
    ))
  )
  observationPeriod <- dplyr::tibble(
    observation_period_id = 1:5,
    person_id = 1:5,
    observation_period_start_date = as.Date("2020-01-01"),
    observation_period_end_date = as.Date("2020-01-20"),
    period_type_concept_id = 0L
  )

  suppressWarnings(
    mockPatientProfiles(
      cohort1 = cohort1,
      cohort2 = cohort2,
      observation_period = observationPeriod,
      source = "local"
    ) |>
      copyCdm()
  )
}

test_that("event days returns events and observation boundaries", {
  cdm <- cohortEventTestCdm()

  result <- cdm$cohort1 |>
    addCohortEventDays(
      targetCohortTable = "cohort2", multipleEvents = TRUE
    ) |>
    dplyr::collect()

  expect_equal(
    result$event_0_to_inf[result$subject_id == 1],
    "cohort_1; cohort_2"
  )
  expect_equal(result$days_0_to_inf[result$subject_id == 1], 2)
  expect_equal(
    result$event_0_to_inf[result$subject_id == 2],
    "end_of_observation"
  )
  expect_equal(result$days_0_to_inf[result$subject_id == 2], 10)

  singleEvent <- cdm$cohort1 |>
    addCohortEventDays(targetCohortTable = "cohort2") |>
    dplyr::collect()
  expect_equal(
    singleEvent$event_0_to_inf[singleEvent$subject_id == 1],
    "cohort_1"
  )

  # An event at the end of observation wins over the observation boundary.
  expect_equal(result$event_0_to_inf[result$subject_id == 3], "cohort_1")
  expect_equal(result$days_0_to_inf[result$subject_id == 3], 10)

  outsideObservation <- cdm$cohort1 |>
    dplyr::mutate(
      cohort_start_date = as.Date("2020-01-25"),
      cohort_end_date = as.Date("2020-01-25")
    ) |>
    addCohortEventDays(targetCohortTable = "cohort2") |>
    dplyr::collect()
  expect_true(all(is.na(outsideObservation$event_0_to_inf)))
  expect_true(all(is.na(outsideObservation$days_0_to_inf)))

  dropCreatedTables(cdm)
})

test_that("censor date is a fallback and does not co-occur with events", {
  skip_on_cran()
  cdm <- cohortEventTestCdm()

  result <- cdm$cohort1 |>
    addCohortEventDays(
      targetCohortTable = "cohort2",
      censorDate = "censor_date"
    ) |>
    dplyr::collect()

  expect_equal(result$event_0_to_inf[result$subject_id == 2], "censor")
  expect_equal(result$days_0_to_inf[result$subject_id == 2], 4)
  expect_equal(result$event_0_to_inf[result$subject_id == 4], "cohort_1")
  expect_equal(result$days_0_to_inf[result$subject_id == 4], 4)

  windowCensor <- cdm$cohort1 |>
    addCohortEventDays(
      targetCohortTable = "cohort2",
      window = c(0, 5)
    ) |>
    dplyr::collect()
  expect_equal(
    windowCensor$event_0_to_5[windowCensor$subject_id == 2],
    "censor"
  )
  expect_equal(windowCensor$days_0_to_5[windowCensor$subject_id == 2], 5)

  dropCreatedTables(cdm)
})

test_that("event date and explicit event priority work", {
  skip_on_cran()
  cdm <- cohortEventTestCdm()

  result <- cdm$cohort1 |>
    addCohortEventDate(
      targetCohortTable = "cohort2",
      multipleEvents = c("cohort_2", "cohort_1")
    ) |>
    dplyr::collect()

  expect_equal(result$event_0_to_inf[result$subject_id == 1], "cohort_2")
  expect_equal(
    result$date_0_to_inf[result$subject_id == 1], as.Date("2020-01-12")
  )
  expect_equal(
    result$event_0_to_inf[result$subject_id == 2],
    "end_of_observation"
  )
  expect_equal(
    result$date_0_to_inf[result$subject_id == 2], as.Date("2020-01-20")
  )

  dropCreatedTables(cdm)
})

test_that("last event searches backwards to the start boundary", {
  skip_on_cran()
  cdm <- cohortEventTestCdm()

  result <- cdm$cohort1 |>
    addCohortEventDays(
      targetCohortTable = "cohort2",
      order = "last",
      window = c(-Inf, 0),
      censorDate = "censor_date"
    ) |>
    dplyr::collect()

  expect_equal(result$event_minf_to_0[result$subject_id == 5], "cohort_1")
  expect_equal(result$days_minf_to_0[result$subject_id == 5], -2)
  expect_equal(
    result$event_minf_to_0[result$subject_id == 2],
    "end_of_observation"
  )
  expect_equal(result$days_minf_to_0[result$subject_id == 2], -9)

  dropCreatedTables(cdm)
})

test_that("more than five events are resolved with a lookup table", {
  skip_on_cran()
  cohort1 <- dplyr::tibble(
    cohort_definition_id = 1L,
    subject_id = 1L,
    cohort_start_date = as.Date("2020-01-10"),
    cohort_end_date = as.Date("2020-01-10")
  )
  cohort2 <- dplyr::tibble(
    cohort_definition_id = 1:6,
    subject_id = 1L,
    cohort_start_date = as.Date("2020-01-12"),
    cohort_end_date = as.Date("2020-01-12")
  )
  observationPeriod <- dplyr::tibble(
    observation_period_id = 1L,
    person_id = 1L,
    observation_period_start_date = as.Date("2020-01-01"),
    observation_period_end_date = as.Date("2020-01-20"),
    period_type_concept_id = 0L
  )
  cdm <- suppressWarnings(
    mockPatientProfiles(
      cohort1 = cohort1,
      cohort2 = cohort2,
      observation_period = observationPeriod,
      source = "local"
    ) |>
      copyCdm()
  )

  combined <- cdm$cohort1 |>
    addCohortEventDays(
      targetCohortTable = "cohort2", multipleEvents = TRUE
    ) |>
    dplyr::collect()
  expect_equal(
    combined$event_0_to_inf,
    paste(paste0("cohort_", 1:6), collapse = "; ")
  )

  prioritised <- cdm$cohort1 |>
    addCohortEventDays(
      targetCohortTable = "cohort2", multipleEvents = "cohort_6"
    ) |>
    dplyr::collect()
  expect_equal(prioritised$event_0_to_inf, "cohort_6")

  dropCreatedTables(cdm)
})

test_that("event functions validate naming and tie priority", {
  skip_on_cran()
  cdm <- cohortEventTestCdm()

  expect_error(
    addCohortEventDays(
      cdm$cohort1,
      targetCohortTable = "cohort2", nameStyle = "event"
    ),
    "value"
  )
  partialPriority <- addCohortEventDays(
    cdm$cohort1,
    targetCohortTable = "cohort2",
    multipleEvents = "cohort_1"
  ) |>
    dplyr::collect()
  expect_equal(
    partialPriority$event_0_to_inf[partialPriority$subject_id == 1],
    "cohort_1"
  )

  result <- addCohortEventDays(
    cdm$cohort1,
    targetCohortTable = "cohort2",
    window = list(before = c(-Inf, 0), after = c(0, Inf))
  )
  expect_true(all(c(
    "event_before", "days_before", "event_after", "days_after"
  ) %in% colnames(result)))

  dropCreatedTables(cdm)
})
