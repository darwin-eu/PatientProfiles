conceptEventTestCdm <- function() {
  cohort1 <- dplyr::tibble(
    cohort_definition_id = 1L,
    subject_id = 1:5,
    cohort_start_date = as.Date("2020-01-10"),
    cohort_end_date = as.Date("2020-01-10"),
    censor_date = as.Date(c(
      "2020-01-14", "2020-01-14", "2020-01-20",
      "2020-01-14", "2020-01-14"
    ))
  )
  observationPeriod <- dplyr::tibble(
    observation_period_id = 1:5,
    person_id = 1:5,
    observation_period_start_date = as.Date("2020-01-01"),
    observation_period_end_date = as.Date("2020-01-20"),
    period_type_concept_id = 0L
  )
  concept <- dplyr::tibble(
    concept_id = c(101L, 102L),
    concept_name = c("event a", "event b"),
    domain_id = "Condition",
    vocabulary_id = NA_character_,
    concept_class_id = "Clinical Finding",
    standard_concept = "S",
    concept_code = NA_character_,
    valid_start_date = as.Date("1900-01-01"),
    valid_end_date = as.Date("2099-12-31"),
    invalid_reason = NA_character_
  )
  conditionOccurrence <- dplyr::tibble(
    condition_occurrence_id = 1:7,
    person_id = c(1L, 1L, 1L, 3L, 4L, 4L, 5L),
    condition_concept_id = c(102L, 101L, 102L, 101L, 101L, 102L, 101L),
    condition_start_date = as.Date(c(
      "2020-01-12", "2020-01-12", "2020-01-15", "2020-01-20",
      "2020-01-14", "2020-01-15", "2020-01-08"
    )),
    condition_end_date = as.Date(c(
      "2020-01-12", "2020-01-12", "2020-01-15", "2020-01-20",
      "2020-01-14", "2020-01-15", "2020-01-08"
    )),
    condition_type_concept_id = 0L
  )

  suppressWarnings(
    mockPatientProfiles(
      cohort1 = cohort1,
      observation_period = observationPeriod,
      concept = concept,
      condition_occurrence = conditionOccurrence,
      source = "local"
    ) |>
      copyCdm()
  )
}

test_that("concept event days combines ties and returns observation boundary", {
  cdm <- conceptEventTestCdm()
  conceptSet <- list(event_b = 102L, event_a = 101L)

  result <- cdm$cohort1 |>
    addConceptEventDays(
      conceptSet = conceptSet, multipleEvents = TRUE
    ) |>
    dplyr::collect()

  expect_equal(
    result$event_0_to_inf[result$subject_id == 1],
    "event_a; event_b"
  )
  expect_equal(result$days_0_to_inf[result$subject_id == 1], 2)
  expect_equal(
    result$event_0_to_inf[result$subject_id == 2],
    "end_of_observation"
  )
  expect_equal(result$days_0_to_inf[result$subject_id == 2], 10)
  expect_equal(result$event_0_to_inf[result$subject_id == 3], "event_a")

  dropCreatedTables(cdm)
})

test_that("concept event date respects priority and censor boundary", {
  skip_on_cran()
  cdm <- conceptEventTestCdm()
  conceptSet <- list("event b" = 102L, "event a" = 101L)

  result <- cdm$cohort1 |>
    addConceptEventDate(
      conceptSet = conceptSet,
      censorDate = "censor_date",
      multipleEvents = c("event b", "event a")
    ) |>
    dplyr::collect()

  expect_equal(result$event_0_to_inf[result$subject_id == 1], "event_b")
  expect_equal(
    result$date_0_to_inf[result$subject_id == 1], as.Date("2020-01-12")
  )
  expect_equal(result$event_0_to_inf[result$subject_id == 2], "censor")
  expect_equal(
    result$date_0_to_inf[result$subject_id == 2], as.Date("2020-01-14")
  )
  expect_equal(result$event_0_to_inf[result$subject_id == 4], "event_a")

  dropCreatedTables(cdm)
})

test_that("concept event days can search backwards", {
  skip_on_cran()
  cdm <- conceptEventTestCdm()

  result <- cdm$cohort1 |>
    addConceptEventDays(
      conceptSet = list(event_a = 101L, event_b = 102L),
      order = "last",
      window = c(-Inf, 0)
    ) |>
    dplyr::collect()

  expect_equal(result$event_minf_to_0[result$subject_id == 5], "event_a")
  expect_equal(result$days_minf_to_0[result$subject_id == 5], -2)
  expect_equal(
    result$event_minf_to_0[result$subject_id == 2],
    "end_of_observation"
  )
  expect_equal(result$days_minf_to_0[result$subject_id == 2], -9)

  dropCreatedTables(cdm)
})
