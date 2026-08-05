test_that("all column-creating functions expose type", {
  skip_on_cran()
  functions <- c(
    "addAge", "addAgeQuery",
    "addCohortEventDays", "addConceptEventDays",
    "addCohortIntersectFlag", "addTableIntersectFlag",
    "addConceptIntersectFlag", "addDeathFlag",
    "addCohortIntersectCount", "addTableIntersectCount",
    "addConceptIntersectCount",
    "addCohortIntersectDays", "addTableIntersectDays",
    "addConceptIntersectDays", "addDeathDays",
    "addCohortIntersectField", "addTableIntersectField",
    "addConceptIntersectField",
    "addDemographics", "addDemographicsQuery",
    "addFutureObservation", "addFutureObservationQuery",
    "addPriorObservation", "addPriorObservationQuery",
    "addInObservation", "addInObservationQuery"
  )

  purrr::walk(functions, \(fun) {
    expect_true(
      "type" %in% names(formals(getExportedValue("PatientProfiles", fun))),
      info = fun
    )
  })
})

test_that("type is validated before table work in internal functions", {
  skip_on_cran()
  functions <- list(
    addIntersect = \(type) {
      .addIntersect(NULL, value = "flag", type = type)
    },
    addEvent = \(type) {
      .addEvent(NULL, output = "days", type = type)
    },
    addCohortEvent = \(type) {
      .addCohortEvent(NULL, output = "days", type = type)
    },
    addConceptEvent = \(type) {
      .addConceptEvent(NULL, output = "days", type = type)
    },
    addConceptIntersect = \(type) {
      .addConceptIntersect(NULL, value = "flag", type = type)
    },
    addTableIntersect = \(type) {
      .addTableIntersect(NULL, value = "flag", type = type)
    },
    addDeath = \(type) {
      addDeath(NULL, value = "flag", type = type)
    },
    addDemographicsQuery = \(type) {
      .addDemographicsQuery(NULL, type = type)
    },
    addInObservationQuery = \(type) {
      .addInObservationQuery(NULL, type = type)
    }
  )

  purrr::iwalk(functions, \(fun, name) {
    expect_error(fun("invalid"), "`type`", info = name)
  })

  expect_identical(
    validateColumnType("character", c("field_1", "field_2")),
    "character"
  )
  expect_error(
    validateColumnType("integer", c("flag", "date")),
    "`type`"
  )
})

test_that("created columns can be converted consistently", {
  skip_on_cran()
  withr::local_seed(2)
  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()

  flag <- cdm$cohort1 |>
    addCohortIntersectFlag(
      targetCohortTable = "cohort2",
      type = "logical"
    ) |>
    dplyr::collect()
  expect_type(flag$cohort_2_0_to_inf, "logical")

  count <- cdm$cohort1 |>
    addTableIntersectCount(
      tableName = "visit_occurrence",
      type = "integer"
    ) |>
    dplyr::collect()
  expect_type(count$visit_occurrence_0_to_inf, "integer")

  days <- cdm$cohort1 |>
    addCohortIntersectDays(
      targetCohortTable = "cohort2",
      type = "integer"
    ) |>
    dplyr::collect()
  expect_type(days$cohort_2_0_to_inf, "integer")

  field <- cdm$cohort1 |>
    addCohortIntersectField(
      targetCohortTable = "cohort2",
      field = "cohort_definition_id",
      type = "character"
    ) |>
    dplyr::collect()
  expect_type(
    field$cohort_2_cohort_definition_id_0_to_inf,
    "character"
  )

  age <- cdm$cohort1 |>
    addAgeQuery(type = "numeric") |>
    dplyr::collect()
  expect_type(age$age, "double")

  prior <- cdm$cohort1 |>
    addPriorObservationQuery(type = "integer") |>
    dplyr::collect()
  expect_type(prior$prior_observation, "integer")

  future <- cdm$cohort1 |>
    addFutureObservationQuery(type = "integer") |>
    dplyr::collect()
  expect_type(future$future_observation, "integer")

  inObservation <- cdm$cohort1 |>
    addInObservationQuery(type = "logical") |>
    dplyr::collect()
  expect_type(inObservation$in_observation, "logical")

  event <- cdm$cohort1 |>
    addCohortEventDays(
      targetCohortTable = "cohort2",
      type = "integer"
    ) |>
    dplyr::collect()
  expect_type(event$days_0_to_inf, "integer")

  death <- cdm$cohort1 |>
    addDeathFlag(type = "logical") |>
    dplyr::collect()
  expect_type(death$death, "logical")

  dropCreatedTables(cdm = cdm)
})

test_that("type choices are constrained by output semantics", {
  skip_on_cran()
  withr::local_seed(2)
  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()

  expect_error(
    cdm$cohort1 |>
      addCohortIntersectCount(
        targetCohortTable = "cohort2",
        type = "logical"
      )
  )
  expect_error(
    cdm$cohort1 |>
      addCohortIntersectField(
        targetCohortTable = "cohort2",
        field = "cohort_definition_id",
        type = "date"
      )
  )

  dropCreatedTables(cdm = cdm)
})
