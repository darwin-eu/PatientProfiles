
#' Benchmark intersections and demographics functions for a certain source
#' (cdm).
#'
#' @param cdm A cdm_reference object.
#' @param n Size of the synthetic cohorts used to benchmark.
#' @param iterations Number of iterations to run the benchmark.
#'
#' @return A summarise_result object with the summary statistics.
#' @export
#'
benchmarkPatientProfiles <- function(cdm,
                                     n = 50000,
                                     iterations = 1) {
  rlang::check_installed("CDMConnector", version = "2.0.0")

  # initial check
  cdm <- omopgenerics::validateCdmArgument(cdm = cdm)
  omopgenerics::assertNumeric(n, integerish = TRUE, min = 1, length = 1)
  omopgenerics::assertNumeric(iterations, integerish = TRUE, min = 1, length = 1)

  # create synthetic cdm
  cli::cli_inform(c("i" = "Generating synthetic data"))
  person <- personTable(n = n)
  observationPeriod <- observationPeriodTable(person)
  cohort1 <- indexCohort(observationPeriod, 2* n)
  cohort2 <- targetCohort(observationPeriod, 4 * n)

  cdmLocal <- omopgenerics::cdmFromTables(
    tables = list(person = person, observation_period = observationPeriod),
    cdmName = "synthetic cdm",
    cohortTables = list(cohort1 = cohort1, cohort2 = cohort2),
    cdmVersion = "5.3"
  )

  # insert cdm object
  cdm2 <- omopgenerics::insertCdmTo(cdm = cdmLocal, to = cdm)

  # intersect function
  analysis <- c("count", "flag", "date", "days", "test_result")
  intersectFunction <- function(value, window, prefix) {
    t0 <- Sys.time()
    x <- cdm2$cohort1 |>
      .addIntersect(
        tableName = "cohort2",
        value = value,
        filterVariable = "cohort_definition_id",
        filterId = c(1L, 2L),
        idName = c("var_1", "var_2"),
        window = window,
        indexDate = "cohort_start_date",
        censorDate = NULL,
        targetStartDate = "cohort_start_date",
        targetEndDate = "cohort_end_date",
        inObservation = TRUE,
        order = "first",
        nameStyle = "{id_name}_{window_name}",
        name = omopgenerics::uniqueTableName(prefix = prefix)
      )
    as.numeric(Sys.time() - t0)
  }

  # demographics function
  demographics <- c("age", "sex", "age_group", "prior_observation", "future_observation", "all")
  demographicsFunciton <- function(value, prefix) {
    ageGroups <- list(c(0, 19), c(20, 39), c(40, 59), c(60, 79), c(80, Inf))
    vals <- switch(value,
                   "age" = list(T, F, NULL, F, F),
                   "sex" = list(F, T, NULL, F, F),
                   "age_group" = list(F, F, ageGroups, F, F),
                   "prior_observation" = list(F, F, NULL, T, F),
                   "future_observation" = list(F, F, NULL, F, T),
                   "all" = list(T, T, ageGroups, T, T))
    t0 <- Sys.time()
    x <- cdm2$cohort1 |>
      .addDemographicsQuery(
        indexDate = "cohort_start_date",
        age = vals[[1]],
        ageName = "age",
        ageMissingMonth = 1L,
        ageMissingDay = 1L,
        ageImposeMonth = FALSE,
        ageImposeDay = FALSE,
        ageGroup = vals[[3]],
        missingAgeGroupValue = "none",
        sex = vals[[2]],
        sexName = "sex",
        missingSexValue = "none",
        priorObservation = vals[[4]],
        priorObservationName = "prior_obs",
        priorObservationType = "date",
        futureObservation = vals[[5]],
        futureObservationName = "future_obs",
        futureObservationType = "days",
        dateOfBirth = FALSE,
        dateOfBirthName = NULL
      ) |>
      dplyr::compute(name = omopgenerics::uniqueTableName(prefix = prefix))
    as.numeric(Sys.time() - t0)
  }

  # TODO add index to person_id

  # iterate over
  result <- purrr::map_df(seq_len(iterations), \(it) {
    cli::cli_inform(c("Iteration {.pkg {it}} of {iterations}"))
    prefix <- omopgenerics::tmpPrefix()

    result <- list(
      # intersect one window
      purrr::map_df(analysis, \(x) {
        dplyr::tibble(
          task = glue::glue("Intersect {x} with one window"),
          estimate_value = intersectFunction(x, c(0, 365), prefix)
        )
      }),
      # intersect three windows
      purrr::map_df(analysis, \(x) {
        window <- list(c(-365, -1), c(0, 0), c(1, 365))
        dplyr::tibble(
          task = glue::glue("Intersect {x} with three windows"),
          estimate_value = intersectFunction(x, window, prefix)
        )
      }),
      # demographics
      purrr::map_df(demographics, \(x) {
        dplyr::tibble(
          task = glue::glue("Demographics: {x}"),
          estimate_value = demographicsFunciton(x, prefix)
        )
      })
    ) |>
      dplyr::bind_rows()

    # delete created tables
    omopgenerics::dropSourceTable(cdm = cdm2, name = dplyr::starts_with(prefix))

    result |>
      dplyr::mutate(iteration = .env$it)
  })

  # clean cdm2
  omopgenerics::dropSourceTable(cdm = cdm2, name = c(
    "person", "observation_period", "cohort1", "cohort2"
  ))

  # create result object
  result |>
    dplyr::union_all(
      result |>
        dplyr::group_by(.data$task) |>
        dplyr::summarise(estimate_value = sum(.data$estimate_value)) |>
        dplyr::mutate(iteration = NA_real_)
    ) |>
    omopgenerics::uniteGroup(cols = "task") |>
    omopgenerics::uniteStrata(cols = "iteration") |>
    omopgenerics::uniteAdditional() |>
    dplyr::mutate(
      result_id = 1L,
      cdm_name = omopgenerics::cdmName(cdm),
      variable_name = "overall",
      variable_level = "overall",
      estimate_name = "time_seconds",
      estimate_type = "numeric",
      estimate_value = sprintf("%.2f", .data$estimate_value)
    ) |>
    omopgenerics::newSummarisedResult(settings = dplyr::tibble(
      result_id = 1L,
      package_name = "PatientProfiles",
      package_version = as.character(utils::packageVersion("PatientProfiles")),
      result_type = "benckmark_patientprofiles",
      sample_size = as.character(.env$n)
    ))
}
personTable <- function(n) {
  dplyr::tibble(
    person_id = as.integer(seq_len(.env$n)),
    gender_concept_id = sample(c(8507L, 8532L), size = .env$n, replace = TRUE),
    year_of_birth = sample(1990:2000L, size = .env$n, replace = TRUE),
    month_of_birth = sample(c(NA_integer_, 1:12L), size = .env$n, replace = TRUE),
    day_of_birth = sample(c(NA_integer_, 1:28L), size = .env$n, replace = TRUE, prob = c(20, rep(1, 28))),
    birth_datetime = as.Date(NA),
    race_concept_id = 0L,
    ethnicity_concept_id = 0L,
    location_id = 0L,
    provider_id = 0L,
    care_site_id = 0L,
    person_source_value = NA_character_,
    gender_source_value = NA_character_,
    gender_source_concept_id = 0L,
    race_source_value = NA_character_,
    race_source_concept_id = 0L,
    ethnicity_source_value = NA_character_,
    ethnicity_source_concept_id = 0L
  )
}
observationPeriodTable <- function(person) {
  n <- nrow(person)
  dplyr::tibble(
    observation_period_id = person$person_id,
    person_id = person$person_id,
    observation_period_start_date = as.Date("2001-01-01") + round(3500 * stats::runif(.env$n)),
    observation_period_end_date = .data$observation_period_start_date + 100 + round(5000 * stats::runif(.env$n)),
    period_type_concept_id = 0L
  )
}
indexCohort <- function(observationPeriod, n) {
  id <- as.integer(sample(nrow(observationPeriod), size = n, replace = TRUE))
  observationPeriod[id,] |>
    dplyr::select(
      "person_id",
      "start" = "observation_period_start_date",
      "end" = "observation_period_end_date"
    ) |>
    dplyr::mutate(
      cohort_definition_id = sample(1:4L, size = .env$n, replace = TRUE),
      duration = as.integer(.data$end - .data$start),
      prev_time = 1 + 10 * stats::runif(n = .env$n),
      duration_time = 15 + 100 * stats::runif(n = .env$n),
      end_time = 1 + 10 * stats::runif(n = .env$n)
    ) |>
    dplyr::group_by(.data$cohort_definition_id, .data$person_id) |>
    dplyr::mutate(
      id = dplyr::row_number(),
      end_time = dplyr::if_else(.data$id == max(.data$id), .data$end_time, 0),
      total_time = sum(.data$prev_time) + sum(.data$duration_time) + sum(.data$end_time)
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      prev_time = round(.data$duration * .data$prev_time / .data$total_time) + 1L,
      duration_time = round(.data$duration * .data$duration_time / .data$total_time),
      end_time = round(.data$duration * .data$end_time / .data$total_time),
      total_time = .data$prev_time + .data$duration_time + .data$end_time
    ) |>
    dplyr::group_by(.data$cohort_definition_id, .data$person_id) |>
    dplyr::mutate(
      prev_time = dplyr::coalesce(dplyr::lag(cumsum(.data$total_time), order_by = .data$id), 0) + .data$prev_time
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      cohort_start_date = .data$start + as.integer(.data$prev_time),
      cohort_end_date = .data$cohort_start_date + as.integer(.data$duration_time),
      cohort_start_date = pmin(.data$end, .data$cohort_start_date),
      cohort_end_date = pmin(.data$end, .data$cohort_end_date)
    ) |>
    dplyr::rename(subject_id = "person_id") |>
    dplyr::select(dplyr::all_of(omopgenerics::cohortColumns("cohort")))
}
targetCohort <- function(observationPeriod, n) {
  indexCohort(observationPeriod = observationPeriod, n = n) |>
    dplyr::mutate(test_result = sample(x = c("A", "B", "C"), size = n, replace = TRUE))
}
