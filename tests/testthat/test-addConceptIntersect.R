test_that("addConceptIntersect", {
  skip_on_cran()
  cdm <- omock::mockCdmFromDataset(datasetName = "GiBleed", source = "local") |>
    copyCdm()

  # create a cohort
  cdm$my_cohort <- CohortConstructor::conceptCohort(
    cdm = cdm,
    conceptSet =  list("sinusitis" = c(4294548L, 40481087L, 257012L)),
    name = "my_cohort"
  )

  codelist <- list(
    "statin" = cdm$concept |>
      dplyr::filter(grepl("statin", concept_name, ignore.case = T)) |>
      dplyr::pull("concept_id"),
    "serum_measurement" = cdm$concept |>
      dplyr::filter(grepl("serum", concept_name, ignore.case = T)) |>
      dplyr::pull("concept_id"),
    "allergy" = cdm$concept |>
      dplyr::filter(grepl("allergy", concept_name, ignore.case = T)) |>
      dplyr::pull("concept_id"),
    "bypass" = cdm$concept |>
      dplyr::filter(grepl("bypass", concept_name, ignore.case = T)) |>
      dplyr::pull("concept_id"),
    "laceration" = cdm$concept |>
      dplyr::filter(grepl("laceration", concept_name, ignore.case = T)) |>
      dplyr::pull("concept_id")
  )

  expect_no_error(
    cdm$my_cohort |>
      addConceptIntersectCount(conceptSet = codelist)
  )

  expect_no_error(
    cdm$my_cohort |>
      addConceptIntersectFlag(conceptSet = codelist)
  )

  expect_no_error(
    cdm$my_cohort |>
      addConceptIntersectDate(conceptSet = codelist)
  )

  # test input
  expect_error(
    cdm$my_cohort |>
      addConceptIntersectCount(
        conceptSet = codelist, targetStartDate = "cohort_start_date"
      )
  )
  expect_error(
    cdm$my_cohort |>
      addConceptIntersectCount(
        conceptSet = codelist, targetEndDate = "cohort_start_date"
      )
  )

  expect_no_error(
    cdm$my_cohort |>
      addConceptIntersectDays(
        conceptSet = codelist, targetDate = "event_end_date"
      )
  )

  expect_no_error(
    cdm$my_cohort |>
      addConceptIntersectDate(
        conceptSet = codelist, targetDate = "event_end_date"
      )
  )

  expect_no_error(
    cdm$my_cohort |>
      addConceptIntersectCount(
        conceptSet = codelist, targetStartDate = "event_end_date"
      )
  )

  expect_error(
    cdm$my_cohort |>
      addConceptIntersectCount(
        conceptSet = codelist, targetStartDate = NULL
      )
  )

  cdm$condition_occurrence <- NULL
  expect_no_error(
    cdm$my_cohort |>
      addConceptIntersectCount(
        conceptSet = list(concept1 = c(0L, 4294548L, 9201L))
      )
  )

  dropCreatedTables(cdm = cdm)
})

test_that("conceptSetExpression", {
  skip_on_cran()
  skip_if_not_installed("omopgenerics", minimum_version = "1.1.0")
  cdm <- omock::mockCdmFromDataset(datasetName = "GiBleed", source = "local") |>
    copyCdm()

  # create a cohort
  cdm$my_cohort <- CohortConstructor::conceptCohort(
    cdm = cdm,
    conceptSet = list("sinusitis" = c(4294548L, 40481087L, 257012L)),
    name = "my_cohort"
  )

  # get as codelist
  codelist <- cdm$concept_ancestor |>
    dplyr::filter(.data$ancestor_concept_id == 1125315) |>
    dplyr::pull("descendant_concept_id") |>
    list() |>
    rlang::set_names("acetaminophen")
  conceptSetExpression <- list(
    acetaminophen = dplyr::tibble(
      concept_id = 1125315,
      descendants = TRUE,
      excluded = FALSE,
      mapped = FALSE
    )
  ) |>
    omopgenerics::newConceptSetExpression()

  # windows
  windows <- list(c(-Inf, -366), c(-365, -1), c(0, 0), c(1, 365), c(366, Inf))

  expect_no_error(
    x1 <- cdm$my_cohort |>
      addConceptIntersectCount(conceptSet = codelist, window = windows)
  )
  expect_no_error(
    x2 <- cdm$my_cohort |>
      addConceptIntersectCount(conceptSet = conceptSetExpression, window = windows)
  )
  prepareData <- function(x) {
    ord <- sort(colnames(x))
    x |>
      dplyr::collect() |>
      dplyr::select(dplyr::all_of(ord)) |>
      dplyr::arrange(dplyr::across(dplyr::all_of(ord)))
  }
  expect_identical(prepareData(x1), prepareData(x2))

  dropCreatedTables(cdm = cdm)
})

test_that("unsupported domain name", {
  skip_on_cran()
  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()

  concept <- dplyr::tibble(
    concept_id = c(1125315),
    domain_id = "random",
    concept_class_id = NA_character_,
    vocabulary_id = NA_character_,
    concept_code = NA_character_,
    valid_start_date = as.Date("1900-01-01"),
    valid_end_date = as.Date("2099-01-01"),
    invalid_reason = NA_character_
  ) |>
    dplyr::mutate(concept_name = paste0("concept: ", .data$concept_id))
  cdm <- omopgenerics::insertTable(cdm = cdm, name = "concept", table = concept)

  expect_no_warning(result <- cdm$cohort1 |>
    addConceptIntersectFlag(
      conceptSet = list("random" = 1125315L)
    ) |>
    dplyr::collect())

  expect_true(
    "random_0_to_inf" %in%
      (result |>
        colnames())
  )

  expect_no_error(
    cdm$cohort1a <- cdm$cohort1 |>
    addConceptIntersectFlag(
      conceptSet = list("not_in_concept_table" = 99L),
      nameStyle = "new_col"
    )
  )
 expect_true(all(cdm$cohort1a |>
    dplyr::pull("new_col") == 0L))

 dropCreatedTables(cdm = cdm)
})

test_that("NA domain name", {
  skip_on_cran()
  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()

  concept <- dplyr::tibble(
    concept_id = c(1125315),
    domain_id = NA_character_,
    concept_class_id = NA_character_,
    vocabulary_id = NA_character_,
    concept_code = NA_character_,
    valid_start_date = as.Date("1900-01-01"),
    valid_end_date = as.Date("2099-01-01"),
    invalid_reason = NA_character_
  ) |>
    dplyr::mutate(concept_name = paste0("concept: ", .data$concept_id))
  cdm <- omopgenerics::insertTable(cdm = cdm, name = "concept", table = concept)

  expect_no_warning(result <- cdm$cohort1 |>
    addConceptIntersectFlag(
      conceptSet = list("random2" = 1125315L)
    ) |>
    dplyr::collect())

  expect_true(
    "random2_0_to_inf" %in%
      (result |>
        colnames())
  )

  dropCreatedTables(cdm = cdm)
})

test_that("domain name not in cdm", {
  skip_on_cran()
  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()

  concept <- dplyr::tibble(
    concept_id = c(1125315L),
    domain_id = "device",
    concept_class_id = NA_character_,
    vocabulary_id = NA_character_,
    concept_code = NA_character_,
    valid_start_date = as.Date("1900-01-01"),
    valid_end_date = as.Date("2099-01-01"),
    invalid_reason = NA_character_
  ) |>
    dplyr::mutate(concept_name = paste0("concept: ", .data$concept_id))
  cdm <- omopgenerics::insertTable(cdm = cdm, name = "concept", table = concept)

  expect_no_warning(result <- cdm$cohort1 |>
    addConceptIntersectFlag(
      conceptSet = list("random3" = 1125315L)
    ) |>
    dplyr::collect())

  expect_true(
    "random3_0_to_inf" %in%
      (result |>
        colnames())
  )

  dropCreatedTables(cdm = cdm)
})

test_that("missing event end date", {
  skip_on_cran()
  cdm <- omock::mockCdmFromDataset(datasetName = "GiBleed", source = "local") |>
    copyCdm()

  cohort <- dplyr::tibble(
    cohort_definition_id = 1L,
    subject_id = 273L,
    cohort_start_date = as.Date("2012-10-10"),
    cohort_end_date = as.Date("2013-10-10")
  )
  cdm <- omopgenerics::insertTable(cdm = cdm, name = "cohort", table = cohort)
  cdm$cohort <- omopgenerics::newCohortTable(table = cdm$cohort)

  for (nm in names(cdm)) {
    if ("person_id" %in% colnames(cdm[[nm]])) {
      cdm[[nm]] <- cdm[[nm]] |>
        dplyr::filter(.data$person_id == 273L)
    }
  }

  expect_true(cdm$cohort |>
    addConceptIntersectFlag(
      conceptSet = list(a = 192671L),
      window = c(-Inf, 0)
    ) |>
    dplyr::pull("a_minf_to_0") == 1)


  dropCreatedTables(cdm = cdm)
})

test_that("records out of observation", {

  cdm <- mockPatientProfiles(
    observation_period = dplyr::tibble(
      observation_period_id = 1L,
      person_id = 1L,
      observation_period_start_date = as.Date("2000-01-01"),
      observation_period_end_date  = as.Date("2010-01-01"),
      period_type_concept_id = 1L
    ),
    my_cohort = dplyr::tibble(
      cohort_definition_id = 1L,
      subject_id = 1L,
      cohort_start_date = as.Date("2000-01-01"),
      cohort_end_date = as.Date("2010-01-01")
    ),
    concept = dplyr::tibble(
      concept_id = 99L,
      concept_name = "concept",
      domain_id = "condition",
      vocabulary_id = "test",
      concept_class_id = "1",
      concept_code = "99",
      valid_start_date = as.Date("1900-01-01"),
      valid_end_date = as.Date("2099-01-01")
    ),
    condition_occurrence = dplyr::tibble(
      condition_occurrence_id = c(1L, 2L),
      person_id = c(1L, 1L),
      condition_concept_id = c(99L, 99L),
      condition_start_date = as.Date(c("1990-01-01", "1991-01-01")),
      condition_end_date= as.Date(c("1990-01-01", "1991-01-01")),
      condition_type_concept_id = c(1L, 1L)
    ),
    source = "local"
  ) |>
    copyCdm()

  # default - record out of observation will be excluded
  cdm$my_cohort <- cdm$my_cohort |>
   addConceptIntersectFlag(conceptSet = list(a = 99L),
                           window = list(c(-Inf, Inf)),
                           inObservation = TRUE,
                           nameStyle = "intersect")
  expect_true(cdm$my_cohort |>
    dplyr::pull("intersect") == 0)

  # include records out of observation
  cdm$my_cohort <- cdm$my_cohort |>
    addConceptIntersectFlag(conceptSet = list(a = 99L),
                            window = list(c(-Inf, Inf)),
                            inObservation = FALSE,
                            nameStyle = "intersect")
  expect_true(cdm$my_cohort |>
                dplyr::pull("intersect") == 1)
  # not if outside of window
  cdm$my_cohort <- cdm$my_cohort |>
    addConceptIntersectFlag(conceptSet = list(a = 99L),
                            window = list(c(0, Inf)),
                            inObservation = FALSE,
                            nameStyle = "intersect")
  expect_true(cdm$my_cohort |>
                dplyr::pull("intersect") == 0)

  expect_error(cdm$my_cohort |>
    addConceptIntersectFlag(conceptSet = list(a = 99L),
                            window = list(c(-Inf, Inf)),
                            inObservation = "not_logical", # should cause error
                            nameStyle = "intersect"))

  # count
  cdm$my_cohort <- cdm$my_cohort |>
    addConceptIntersectCount(conceptSet = list(a = 99L),
                            window = list(c(-Inf, Inf)),
                            inObservation = FALSE,
                            nameStyle = "intersect")
  expect_true(cdm$my_cohort |>
                dplyr::pull("intersect") == 2)

  # date
  cdm$my_cohort <- cdm$my_cohort |>
    addConceptIntersectDate(conceptSet = list(a = 99L),
                             window = list(c(-Inf, Inf)),
                             inObservation = FALSE,
                              order = "first",
                             nameStyle = "intersect")
  expect_true(cdm$my_cohort |>
                dplyr::pull("intersect") == "1990-01-01")

  cdm$my_cohort <- cdm$my_cohort |>
    addConceptIntersectDate(conceptSet = list(a = 99L),
                            window = list(c(-Inf, Inf)),
                            inObservation = FALSE,
                            order = "last",
                            nameStyle = "intersect")
  expect_true(cdm$my_cohort |>
                dplyr::pull("intersect") == "1991-01-01")

   # days
  cdm$my_cohort <- cdm$my_cohort |>
    addConceptIntersectDays(conceptSet = list(a = 99L),
                            window = list(c(-Inf, Inf)),
                            inObservation = FALSE,
                            order = "last",
                            nameStyle = "intersect")
  expect_true(cdm$my_cohort |>
                dplyr::pull("intersect") ==
                as.integer(difftime(as.Date("1991-01-01"),
                         as.Date("2000-01-01"))))

  cdm$my_cohort <- cdm$my_cohort |>
    addConceptIntersectDays(conceptSet = list(a = 99L),
                            window = list(c(-Inf, Inf)),
                            inObservation = FALSE,
                            order = "first",
                            nameStyle = "intersect")
  expect_true(cdm$my_cohort |>
                dplyr::pull("intersect") ==
                as.integer(difftime(as.Date("1990-01-01"),
                                    as.Date("2000-01-01"))))

  dropCreatedTables(cdm = cdm)
})

test_that("validate concept set names", {
  cs <- list("concept_1" = c(1, 2))
  expect_no_error(validateConceptNames(cs))
  expect_identical(validateConceptNames(cs), cs)

  cs <- list("concept 1" = 1, "nWx{]4" = 2)
  expect_message(ncs <- validateConceptNames(cs))
  expect_identical(names(ncs), c("concept_1", "nwx_4"))

  cs <- list("concept_1" = 1, "nWx{]4" = 2)
  expect_message(ncs <- validateConceptNames(cs))
  expect_identical(names(ncs), c("concept_1", "nwx_4"))

  cs <- list("concept 1" = 1, "concept_1" = 2)
  expect_error(expect_message(ncs <- validateConceptNames(cs)))
})
