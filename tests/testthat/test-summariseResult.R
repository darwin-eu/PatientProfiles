test_that("test all functions", {
  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()

  x <- dplyr::tibble(
    s = c("g1", "g1", "g2", "g12", "g2", "g12"),
    v_1 = c(1, 2, 3, 4, 6, 3),
    v_2 = c("a", "b", "a", "b", "0", "0"),
    v_3 = c(0, 1, 0, 1, 1, 0),
    v_4 = as.Date(c(
      "2021-05-12", "2012-05-15", "2023-11-30", "2015-12-10", "2014-01-12",
      "1993-04-190"
    ))
  )

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = x)
  x <- cdm$test_table

  s1 <- summariseResult(x)
  s2 <- summariseResult(x, strata = list("s"))
  s3 <- summariseResult(
    x,
    strata = list("s"),
  )
  s4 <- summariseResult(
    x,
    strata = list(c("s", "v_2"), group2 = "s")
  )

  x <- dplyr::tibble(
    cohort_definition_id = c(1, 1, 1),
    subject_id = c(1, 1, 2),
    cohort_start_date = as.Date(c("1990-04-19", "1991-04-19", "2010-11-14")),
    cohort_end_date = as.Date(c("1990-04-19", "1991-04-19", "2010-11-14")),
    acetaminophen_m365_to_0 = c(1, 1, 0),
    ibuprophen_m365_to_0 = c(0, 0, 0),
    naloxone_m365_to_0 = c(0, 0, 0),
    headache_minf_to_0 = c(0, 1, 0),
    covid_minf_to_0 = c(1, 1, 0)
  )

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = x)
  x <- cdm$test_table

  expect_no_error(
    x1 <- summariseResult(
      x,
      strata = list()
    ))

  x <- x |>
    dplyr::collect() |>
    dplyr::mutate(w = c(0.5, 0.25, 0.25))
  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = x)
  x <- cdm$test_table

  expect_no_error(
    x2 <- summariseResult(table = x, strata = list(), weights = "w")
  )
  expect_true(nrow(x1) == nrow(x2))

  expect_no_error(
    emptySR <- summariseResult(
      x,
      variables = list(),
      estimates = list(),
      counts = FALSE
    )
  )
  expect_true(nrow(emptySR) == 0)
  expect_true(inherits(emptySR, "summarised_result"))

  expect_no_error(
    emptySR <- summariseResult(
      dplyr::tibble(),
      variables = list(),
      estimates = list(),
      counts = FALSE
    )
  )
  expect_true(nrow(emptySR) == 0)
  expect_true(inherits(emptySR, "summarised_result"))

  cohort <- dplyr::tibble(
    cohort_definition_id = c(1, 1, 1, 2),
    subject_id = c(1, 1, 2, 3),
    age = c(39, 40, 27, 7),
    sex = c("Male", "Male", "Female", "Male"),
    prior_history = c(365, 25, 14, 48),
    number_visits = c(0, 1, 0, 0)
  )

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = cohort)
  cohort <- cdm$test_table

  variables <- c("age", "number_visits", "prior_history", "sex")
  functions <- c(
    "mean", "sd", "median", "q25", "q75", "count_missing", "percentage_missing",
    "count", "percentage", "density"
  )
  expect_no_error(
    result <- summariseResult(
      table = cohort, variables = variables, estimates = functions
    )
  )

  cohort <- cohort |>
    dplyr::collect() |>
    dplyr::mutate(w = c(3, 0, 1, 2))
  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = cohort)
  cohort <- cdm$test_table

  expect_no_error(
    result <- summariseResult(
      table = cohort,
      variables = variables,
      estimates = functions,
      weights = "w"
    )
  )

  expect_equal(
    dplyr::tibble() |> summariseResult(counts = FALSE),
    omopgenerics::emptySummarisedResult(),
    ignore_attr = TRUE
  )

  dropCreatedTables(cdm = cdm)
})

test_that("groups and strata", {
  cdm <- mockPatientProfiles(numberIndividuals = 1000, source = "local") |>
    copyCdm()

  result <- cdm$condition_occurrence |>
    addDemographics(
      indexDate = "condition_start_date",
      ageGroup = list(c(0, 30), c(31, 60))
    ) |>
    dplyr::collect() |>
    summariseResult(strata = list("sex"))

  expect_true(
    result |>
      dplyr::filter(
        group_name == "overall" & group_level == "overall" &
          strata_name == "overall" & strata_level == "overall" &
          variable_name == "number subjects"
      ) |>
      dplyr::pull("estimate_value") |>
      as.numeric() <= 1000
  )

  result <- cdm$condition_occurrence |>
    addDemographics(
      indexDate = "condition_start_date",
      ageGroup = list(c(0, 30), c(31, 60))
    ) |>
    dplyr::collect() |>
    summariseResult(strata = list(c("age_group", "sex")))

  expect_true(all(result |>
                    dplyr::select("strata_name") |>
                    dplyr::distinct() |>
                    dplyr::pull() %in%
                    c("overall", "age_group &&& sex")))
  expect_true(all(result |>
                    dplyr::select("strata_level") |>
                    dplyr::distinct() |>
                    dplyr::pull() %in%
                    c(
                      "overall", "0 to 30 &&& Female", "0 to 30 &&& Male",
                      "31 to 60 &&& Female", "31 to 60 &&& Male", "None &&& Female",
                      "None &&& Male"
                    )))

  result <- cdm$condition_occurrence |>
    addDemographics(
      indexDate = "condition_start_date",
      ageGroup = list(c(0, 30), c(31, 60))
    ) |>
    dplyr::collect() |>
    summariseResult(group = c("age_group", "sex"))
  expect_true(all(result |>
                    dplyr::select("group_name") |>
                    dplyr::distinct() |>
                    dplyr::pull() %in%
                    c("overall", "age_group &&& sex")))
  expect_true(all(result |>
                    dplyr::select("group_level") |>
                    dplyr::distinct() |>
                    dplyr::pull() %in%
                    c(
                      "overall", "0 to 30 &&& Female", "0 to 30 &&& Male",
                      "31 to 60 &&& Female", "31 to 60 &&& Male", "None &&& Female",
                      "None &&& Male"
                    )))

  expect_no_error(
    result <- cdm$condition_occurrence |>
      dplyr::collect() |>
      dplyr::mutate("sex" = "Missing") |>
      summariseResult(group = "sex")
  )

  expect_error(
    result <- cdm$condition_occurrence |>
      dplyr::collect() |>
      dplyr::mutate("sex" = "Missing") |>
      summariseResult(weights = "sex")
  )

  dropCreatedTables(cdm = cdm)
})

test_that("table in db or local", {
  cdm <- mockPatientProfiles(numberIndividuals = 1000, source = "local") |>
    copyCdm()

  # in db
  expect_no_error(cdm$condition_occurrence |>
                    addDemographics(
                      indexDate = "condition_start_date",
                      ageGroup = list(c(0, 30), c(31, 60))
                    ) |>
                    summariseResult(strata = "sex"))

  # already collected
  expect_warning(
    expect_no_error(
      cdm$condition_occurrence |>
        addDemographics(
          indexDate = "condition_start_date",
          ageGroup = list(c(0, 30), c(31, 60))
        ) |>
        dplyr::collect() |>
        dplyr::mutate("subject_id" = .data$person_id) |>
        summariseResult(strata = list("sex"))
    )
  )

  expect_no_error(
    x <- cdm$drug_exposure |>
      addSex() |>
      dplyr::collect() |>
      summariseResult(
        group = "sex", variables = character(), estimates = character()
      )
  )

  dropCreatedTables(cdm = cdm)
})

test_that("with and with overall groups and strata", {
  skip_on_cran()
  cdm <- mockPatientProfiles(numberIndividuals = 1000, source = "local") |>
    copyCdm()

  test_data <- cdm$condition_occurrence |>
    addDemographics(
      indexDate = "condition_start_date",
      ageGroup = list(c(0, 30), c(31, 60))
    ) |>
    dplyr::collect()

  expect_false(any(test_data |>
                     summariseResult(
                       strata = list("sex"),
                       includeOverallStrata = FALSE
                     ) |>
                     dplyr::pull("strata_name") %in%
                     c("overall")))
  expect_true(any(test_data |>
                    summariseResult(
                      strata = list("sex"),
                      includeOverallStrata = TRUE
                    ) |>
                    dplyr::pull("strata_name") %in%
                    c("overall")))

  expect_false(any(test_data |>
                     summariseResult(
                       group = list("sex"),
                       includeOverallGroup = FALSE
                     ) |>
                     dplyr::pull("group_name") %in%
                     c("overall")))
  expect_true(any(test_data |>
                    summariseResult(
                      group = list("sex"),
                      includeOverallGroup = TRUE
                    ) |>
                    dplyr::pull("group_name") %in%
                    c("overall")))

  dropCreatedTables(cdm = cdm)
})

test_that("obscure", {
  skip_on_cran()
  x <- dplyr::tibble(
    s = c("g1", "g1", "g2", "g1&&g2", "g2", "g1&&g2"),
    v1 = c(1, 2, 3, 4, 6, 3),
    v2 = c("a", "b", "a&&b", "b", "0", "0&&ab"),
    v3 = c(0, 1, 0, 1, 1, 0),
    v4 = as.Date(c(
      "2021-05-12", "2012-05-15", "2023-11-30", "2015-12-10", "2014-01-12",
      "1993-04-190"
    ))
  )

  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = x)
  x <- cdm$test_table

  # minCellCount = 1
  s <- summariseResult(x) |>
    suppress(minCellCount = 1)
  expect_true(nrow(s) == 34)
  expect_true(sum(s$estimate_value[!is.na(s$estimate_value)] == "<1") == 0)
  expect_true(sum(s$estimate_value == "-") == 0)

  # minCellCount = 2
  s <- summariseResult(x) |>
    suppress(minCellCount = 2)
  expect_true(nrow(s) == 34)
  expect_true(sum(s$estimate_value == "-") == 8)

  # minCellCount = 3
  s <- summariseResult(x) |>
    suppress(minCellCount = 3)
  expect_true(nrow(s) == 34)
  expect_true(sum(s$estimate_value == "-") == 16)

  # minCellCount = 4
  s <- summariseResult(x) |>
    suppress(minCellCount = 4)
  expect_true(nrow(s) == 34)
  expect_true(sum(s$estimate_value == "-") == 23)

  # minCellCount = 5
  s <- summariseResult(x) |>
    suppress(minCellCount = 5)
  expect_true(nrow(s) == 34)
  expect_true(sum(s$estimate_value == "-") == 23)

  # minCellCount = 6
  s <- summariseResult(x) |>
    suppress(minCellCount = 6)
  expect_true(nrow(s) == 34)
  expect_true(sum(s$estimate_value == "-") == 23)

  # minCellCount = 7
  s <- summariseResult(x) |>
    suppress(minCellCount = 7)
  expect_true(nrow(s) == 34)
  expect_true(sum(s$estimate_value == "-") == 34)

  dropCreatedTables(cdm = cdm)
})

test_that("test empty cohort", {
  skip_on_cran()
  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()

  expect_no_error(
    cdm$cohort1 |> dplyr::filter(cohort_definition_id == 0) |>
      summariseResult(
        group = list("cohort_name"),
        includeOverallGroup = FALSE,
        includeOverallStrata = TRUE
      )
  )

  expect_no_error(
    cdm$cohort1 |> dplyr::filter(cohort_definition_id == 0) |>
      summariseResult(
        group = list("cohort_name"),
        includeOverallGroup = TRUE,
        includeOverallStrata = TRUE
      )
  )

  expect_no_error(
    cdm$cohort1 |> dplyr::filter(cohort_definition_id == 0) |>
      summariseResult(
        group = list("cohort_name"),
        includeOverallGroup = FALSE,
        includeOverallStrata = FALSE
      )
  )

  expect_no_error(
    cdm$cohort1 |> dplyr::filter(cohort_definition_id == 0) |>
      summariseResult(
        group = list("cohort_name"),
        includeOverallGroup = TRUE,
        includeOverallStrata = FALSE
      )
  )

  dropCreatedTables(cdm = cdm)
})

test_that("test summary table naming", {
  skip_on_cran()
  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()

  dat <-
    cdm$cohort1 |>
    addDemographics() |>
    dplyr::mutate(
      age_age = age,
      age_age_age = age,
      age_age_age_age = age
    ) |>
    summariseResult()

  expect_true(all(
    c("age_age", "age", "age_age_age", "age_age_age_age") %in% dat$variable_name
  ))

  dropCreatedTables(cdm = cdm)
})

test_that("misisng counts", {
  skip_on_cran()
  cohort <- dplyr::tibble(
    cohort_definition_id = c(1, 1, 1, 2),
    subject_id = c(1, 1, 2, 3),
    age = c(NA, 40, NA, 7),
    sex = c("Male", "Male", "Female", "Male"),
    prior_history = c(365, 25, 14, 48),
    number_visits = c(NA, 1, 0, 0)
  )
  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = cohort)
  cohort <- cdm$test_table

  variables <- list(
    numeric = c("age", "number_visits", "prior_history"),
    categorical = c("sex")
  )
  functions <- list(
    numeric = c("median", "q25", "q75", "count_missing", "percentage_missing"),
    categorical = c("count", "percentage")
  )
  expect_no_error(
    result <- summariseResult(
      cohort,
      strata = list("sex"), variables = variables,
      estimates = functions
    )
  )
  expected <- dplyr::tribble(
    ~strata, ~variable_name, ~count, ~percentage,
    "overall", "age", "2", "50",
    "overall", "number_visits", "1", "25",
    "overall", "prior_history", "0", "0",
    "Male", "age", "1", as.character(100/3),
    "Male", "number_visits", "1", as.character(100/3),
    "Male", "prior_history", "0", "0",
    "Female", "age", "1", "100",
    "Female", "number_visits", "0", "0",
    "Female", "prior_history", "0", "0"
  )
  for (k in seq_len(nrow(expected))) {
    x <- result |>
      dplyr::filter(
        .data$strata_level == .env$expected$strata[k],
        .data$variable_name == .env$expected$variable_name[k]
      )
    xcount <- x$estimate_value[x$estimate_name == "count_missing"]
    xpercentage <- x$estimate_value[x$estimate_name == "percentage_missing"]
    expect_true(xcount == expected$count[k])
    expect_true(xpercentage == expected$percentage[k])
  }
  # female age is all na
  expect_true(
    result |>
      dplyr::filter(
        .data$variable_name == "age",
        .data$strata_level == "Female",
        is.na(.data$variable_level),
        !.data$estimate_name %in% c("count_missing", "percentage_missing")
      ) |>
      dplyr::pull("estimate_value") |>
      is.na() |>
      all()
  )

  dropCreatedTables(cdm = cdm)
})

test_that("data is ordered", {
  skip_on_cran()
  cohort <- dplyr::tibble(
    cohort_definition_id = c(1, 1, 1, 2),
    subject_id = c(1, 1, 2, 3),
    age = c(15, 40, 20, 7),
    sex = c("Male", "Male", "Female", "Male"),
    prior_history = c(365, 25, 14, 48),
    number_visits = c(5, 1, 0, 0)
  )

  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = cohort)
  testTable <- cdm$test_table

  variables <- list(
    numeric = c("age", "number_visits", "prior_history"),
    categorical = c("sex")
  )
  functions <- list(
    numeric = c("median", "q25", "q75"),
    categorical = c("count", "percentage", "median")
  )
  expect_no_error(
    result <- summariseResult(
      table = testTable, strata = list("sex"), variables = variables,
      estimates = functions
    )
  )
  # check first overall, second sex
  order <- unique(result$strata_level)
  expect_identical(order, c("overall", "Female", "Male"))
  # first numbers, age, sex, prior_history, number_visits
  variables <- unique(result$variable_name)
  expect_identical(variables, c(
    "number records", "number subjects", "age", "sex", "prior_history",
    "number_visits"
  ))
  # variable levels appear by order
  order <- unique(result$variable_level[result$variable_name == "sex"])
  order <- order[!is.na(order)]
  expect_identical(order, c("Female", "Male"))

  cohort <- dplyr::tibble(
    cohort_definition_id = c(1, 1, 1, 2),
    subject_id = c(1, 1, 2, 3),
    age = c(15, 40, 20, 7),
    sex = c("Male", "Male", "xFemale", "Male"),
    prior_history = c(365, 25, 14, 48),
    number_visits = c(5, 1, 0, 0)
  )

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = cohort)
  testTable <- cdm$test_table

  variables <- list(
    numeric = c("age", "number_visits", "prior_history"),
    categorical = c("sex")
  )
  functions <- list(
    numeric = c("median", "q25", "q75"),
    categorical = c("count", "percentage", "median")
  )
  expect_no_error(
    result <- summariseResult(
      table = testTable, strata = list("sex"), variables = variables,
      estimates = functions
    )
  )
  # check first overall, second sex
  order <- unique(result$strata_level)
  expect_identical(order, c("overall", "Male", "xFemale"))
  # first numbers, age, sex, prior_history, number_visits
  variables <- unique(result$variable_name)
  expect_identical(variables, c(
    "number records", "number subjects", "age", "sex", "prior_history",
    "number_visits"
  ))
  # variable levels appear by order
  order <- unique(result$variable_level[result$variable_name == "sex"])
  order <- order[!is.na(order)]
  expect_identical(order, c("Male", "xFemale"))

  dropCreatedTables(cdm = cdm)
})

test_that("NA when min, max and mean works", {
  skip_on_cran()
  # case estimatrs > variables
  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()

  x <- dplyr::tibble(group = c("N", "N", "V", "C", "C", "D"), var = c(NA, NA, NA, 1, 1, 1) |> as.integer())

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = x)
  x <- cdm$test_table

  expect_no_warning(
    res1 <- x |>
      summariseResult(
        group = "group",
        estimates = c("min", "max", "mean", "median", "percentage", "q25")
      )
  )
  expect_equal(res1$estimate_value, c(
    "2", "1", "2", "1", "100", "100", "100", "100", "1", "1", NA, NA, "1", "1",
    NA, NA, "1", "1", NA, NA, "1", "1", NA, NA, "100", "100", NA, NA, "1", "1",
    NA, NA
  ))

  x <- dplyr::tibble(
    group = c("N", "N", "V", "C", "C", "D"),
    var = c(NA, NA, NA, 1, 1, 1) |> as.integer(),
    w = c(0.25, 0, 0.25, 3, 0.5, 2)
  )

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = x)
  x <- cdm$test_table

  expect_no_warning(
    res1 <- x |>
      summariseResult(
        group = "group",
        estimates = c("min", "max", "mean", "median", "percentage", "q25"),
        weights = "w",
        counts = FALSE
      )
  )
  expect_equal(res1$estimate_value, c(
    '100', '100', '100', '100', '1', '1', NA, NA, '1', '1', NA, NA, '1', '1',
    NA, NA, '1', '1', NA, NA, '100', '100', NA, NA, '1', '1', NA, NA
  ))

  x <- dplyr::tibble(
    group = c("N", "N", "V", "C", "C", "D"),
    var1 = c(NA, NA, NA, 1, 1, 1) |> as.integer(),
    var2 = c(1, 1, 1, NA, NA, NA) |> as.integer()
  )

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = x)
  x <- cdm$test_table

  expect_no_warning(
    res2 <- x |>
      summariseResult(
        group = "group",
        estimates = c("min", "max", "mean", "median", "percentage", "q25"),
        counts = FALSE
      )
  )
  expect_equal(res2$estimate_value, c(
    "100", "100", "100", "100", "1", "1", NA, NA, "1", "1", NA, NA, "1", "1",
    NA, NA, "1", "1", NA, NA, "100", "100", NA, NA, "1", "1", NA, NA, NA, NA,
    "1", "1", NA, NA, "1", "1", NA, NA, "1", "1", NA, NA, "1", "1", NA, NA,
    "100", "100", NA, NA, "1", "1"
  ))

  x <- dplyr::tibble(
    group = c("N", "N", "V", "C", "C", "D"),
    var1 = c(NA, NA, NA, 1, 1, 1) |> as.integer(),
    var2 = c(1, 1, 1, NA, NA, NA) |> as.integer(),
    w = c(0.25, 0, 0.25, 3, 0.5, 2)
  )

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = x)
  x <- cdm$test_table

  expect_no_warning(
    res2 <- x |>
      summariseResult(
        group = "group",
        estimates = c("min", "mean", "percentage"),
        weights = "w",
        counts = FALSE
      )
  )
  expect_equal(res2$estimate_value, c(
    "100", "100", "100", "100", "1", "1", NA, NA, "1", "1", NA, NA, "100",
    "100", NA, NA, NA, NA, "1", "1", NA, NA, "1", "1", NA, NA, "100", "100"
  ))

  x <- dplyr::tibble(
    group = c("N", "N", "V", "C", "C", "D"),
    var1 = c(NA, NA, NA, 1, 1, 1) |> as.integer(),
    var2 = c(1, 1, 1, NA, NA, NA) |> as.integer(),
    var3 = c(NA, NA, NA, 1, 1, 1) |> as.integer()
  )

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = x)
  x <- cdm$test_table

  # case estimatrs <= variables
  expect_no_warning(
    res3 <- x |>
      summariseResult(
        group = "group",
        estimates = c("min", "max", "mean"),
        counts = FALSE
      )
  )
  expect_equal(res3$estimate_value, c(
    "1", "1", NA, NA, "1", "1", NA, NA, "1", "1", NA, NA, NA, NA, "1", "1", NA,
    NA, "1", "1", NA, NA, "1", "1", "1", "1", NA, NA, "1", "1", NA, NA, "1",
    "1", NA, NA
  ))

  x <- dplyr::tibble(
    group = c("N", "N", "V", "C", "C", "D"),
    var1 = c(NA, NA, NA, 1, 1, 1) |> as.integer(),
    var2 = c(1, 1, 1, NA, NA, NA) |> as.integer(),
    var3 = c(NA, NA, NA, 1, 1, 1) |> as.integer(),
    w = c(0.25, 0, 0.25, 3, 0.5, 2)
  )

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = x)
  x <- cdm$test_table

  expect_no_warning(
    res3 <- x |>
      summariseResult(
        group = "group",
        estimates = c("min", "max", "mean"),
        weights = "w",
        counts = FALSE
      )
  )
  expect_equal(res3$estimate_value, c(
    "1", "1", NA, NA, "1", "1", NA, NA, "1", "1", NA, NA, NA, NA, "1", "1", NA,
    NA, "1", "1", NA, NA, "1", "1", "1", "1", NA, NA, "1", "1", NA, NA, "1",
    "1", NA, NA
  ))

  # no group no strata
  expect_no_warning(
    res4 <- dplyr::tibble(var1 = c(NA, NA, NA) |> as.integer()) |>
      summariseResult(
        estimates = c("min", "max", "mean")
      )
  )
  expect_equal(res4$estimate_value, c("3", NA, NA, NA))

  dropCreatedTables(cdm = cdm)
})

test_that("density works correctly", {
  x <- dplyr::tibble(
    sex = c("M", "F", "F", "F", "F", "F"),
    group = c("g1", "g1", "g2", "g12", "g2", "g12"),
    age1 = c(NA, 23, 38, 45, NA, 39),
    age2 = c(20, 23, 38, 45, 67, 39),
    asthma = c(0L, 1L, 0L, 1L, 1L, 0L),
    birth = as.Date(c(
      "2021-05-12", "2012-05-15", "2023-11-30", "2015-12-10", "2014-01-12",
      "1993-04-190"
    ))
  )

  cdm <- mockPatientProfiles(source = "local") |>
    copyCdm()

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = x)
  x <- cdm$test_table

  est <- c("density", "mean", "count")
  var <- c("group", "age1", "age2", "asthma", "birth")
  expect_no_error(s <- summariseResult(x, estimates = est, variables = var))
  expect_no_error(s <- summariseResult(
    x, strata = list("sex"), estimates = est, variables = var))
  expect_false("density_x" %in% s$estimate_name[s$variable_name == "group"])
  expect_true("density_x" %in% s$estimate_name[s$variable_name == "age1"])
  expect_true("density_x" %in% s$estimate_name[s$variable_name == "age2"])
  expect_true("density_x" %in% s$estimate_name[s$variable_name == "asthma"])
  expect_true("density_x" %in% s$estimate_name[s$variable_name == "birth"])
  expect_identical(
    unique(s$estimate_type[s$estimate_name == "density_y"]), "numeric"
  )
  expect_identical(
    unique(s$estimate_type[s$estimate_name == "density_x" & s$variable_name == "age1"]),
    "numeric"
  )
  expect_identical(
    unique(s$estimate_type[s$estimate_name == "density_x" & s$variable_name == "age2"]),
    "numeric"
  )
  expect_identical(
    unique(s$estimate_type[s$estimate_name == "density_x" & s$variable_name == "asthma"]),
    "numeric"
  )
  expect_identical(
    unique(s$estimate_type[s$estimate_name == "density_x" & s$variable_name == "birth"]),
    "date"
  )
  sM <- s |>
    dplyr::filter(
      .data$strata_level == "M", startsWith(.data$variable_level, "density")
    )
  expect_identical(unique(sM$estimate_value[sM$estimate_name == "density_y"]), c("0", "1"))
  xx <- sM |>
    dplyr::group_by(.data$variable_level) |>
    dplyr::tally()
  expect_true(unique(xx$n) == 6L)
  expect_true(length(unique(xx$variable_level)) == 3L)
  xx <- s |>
    dplyr::filter(
      .data$strata_level == "F", startsWith(.data$variable_level, "density")
    ) |>
    dplyr::group_by(.data$variable_level) |>
    dplyr::tally()
  expect_true(unique(xx$n) == 8L)
  expect_true(length(unique(xx$variable_level)) == 512L)

  # only density
  expect_no_error(s <- summariseResult(x, estimates = "density", variables = "age1"))

  # weights work (!! stats dosen't apply them yet)
  x <- x |> dplyr::mutate(w = 1/6)
  expect_no_error(sw <- summariseResult(x, estimates = "density", variables = "age1", weights = "w"))
  expect_equal(
    s |> dplyr::filter(variable_name == "age1" & estimate_name == "density_y") |> dplyr::pull("estimate_value") |> as.numeric(),
    sw |> dplyr::filter(variable_name == "age1" & estimate_name == "density_y") |> dplyr::pull("estimate_value") |> as.numeric()
  )

  x <- x |>
    dplyr::collect() |>
    dplyr::mutate(w = c(0, 1, rep(0, 4)))
  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test_table", table = x)
  x <- cdm$test_table

  expect_no_error(sw <- summariseResult(x, estimates = "density", variables = "age1", weights = "w"))
  expect_false(
    all(s |> dplyr::filter(variable_name == "age1" & estimate_name == "density_y") |> dplyr::pull("estimate_value") |> as.numeric() ==
    sw |> dplyr::filter(variable_name == "age1" & estimate_name == "density_y") |> dplyr::pull("estimate_value") |> as.numeric())
  )

  # date sd is numeric
  expect_no_error(result <- summariseResult(
    table = x, variables = "birth", estimates = c("mean", "sd"), counts = FALSE
  ))
  expect_true(nrow(result) == 2)
  expect_identical(result$estimate_type, c("date", "numeric"))
  expect_identical(omopgenerics::tidy(result)$mean, as.Date("2013-06-26"))
  expect_identical(omopgenerics::tidy(result)$sd |> round(), 3954)

  dropCreatedTables(cdm = cdm)
})

test_that("new counts functions", {
  skip_on_cran()

  cdm <- mockPatientProfiles() |>
    copyCdm()

  x <- dplyr::tibble(
    group = c(rep("a", 5), rep("b", 3)),
    val1 = c(-5, 1.2, 0, 4.3, 2, -1, 1, -5.5),
    val2 = c(-5L, 1L, 0L, 4L, 2L, -1L, 1L, -5L),
    w = c(0.4, 2.5, 4.5, 1.1, 3.4, 1.4, 0.98, 0.45)
  )

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test", table = x)

  expect_no_error(result <- summariseResult(
    table = cdm$test,
    group = "group",
    variables = c("val1", "val2"),
    estimates = c(
      "count_0", "count_positive", "count_negative", "count_not_positive",
      "count_not_negative", "percentage_0", "percentage_positive",
      "percentage_negative", "percentage_not_positive",
      "percentage_not_negative"
    )
  ))

  res <- result |>
    dplyr::filter(.data$variable_name != "number records") |>
    omopgenerics::tidy()

  # same results for val1 and val2
  expect_identical(
    res |>
      dplyr::filter(.data$variable_name == "val1") |>
      dplyr::select(!"variable_name"),
    res |>
      dplyr::filter(.data$variable_name == "val2") |>
      dplyr::select(!"variable_name")
  )

  res <- res[res$variable_name == "val1",]

  # count 0
  expect_identical(res$count_0[1], sum(x$val1[x$group == "a"] == 0))
  expect_identical(res$count_0[2], sum(x$val1[x$group == "b"] == 0))

  # count positive
  expect_identical(res$count_positive[1], sum(x$val1[x$group == "a"] > 0))
  expect_identical(res$count_positive[2], sum(x$val1[x$group == "b"] > 0))

  # count negative
  expect_identical(res$count_negative[1], sum(x$val1[x$group == "a"] < 0))
  expect_identical(res$count_negative[2], sum(x$val1[x$group == "b"] < 0))

  # count not positive
  expect_identical(res$count_not_positive[1], sum(x$val1[x$group == "a"] <= 0))
  expect_identical(res$count_not_positive[2], sum(x$val1[x$group == "b"] <= 0))

  # count not negative
  expect_identical(res$count_not_negative[1], sum(x$val1[x$group == "a"] >= 0))
  expect_identical(res$count_not_negative[2], sum(x$val1[x$group == "b"] >= 0))

  na <- 100/sum(x$group == "a" & !is.na(x$val1))
  nb <- 100/sum(x$group == "b" & !is.na(x$val1))

  # percentage 0
  expect_equal(res$percentage_0[1], sum(x$val1[x$group == "a"] == 0) * na)
  expect_equal(res$percentage_0[2], sum(x$val1[x$group == "b"] == 0) * nb)

  # percentage positive
  expect_equal(res$percentage_positive[1], sum(x$val1[x$group == "a"] > 0) * na)
  expect_equal(res$percentage_positive[2], sum(x$val1[x$group == "b"] > 0) * nb)

  # percentage negative
  expect_equal(res$percentage_negative[1], sum(x$val1[x$group == "a"] < 0) * na)
  expect_equal(res$percentage_negative[2], sum(x$val1[x$group == "b"] < 0) * nb)

  # percentage not positive
  expect_equal(res$percentage_not_positive[1], sum(x$val1[x$group == "a"] <= 0) * na)
  expect_equal(res$percentage_not_positive[2], sum(x$val1[x$group == "b"] <= 0) * nb)

  # percentage not negative
  expect_equal(res$percentage_not_negative[1], sum(x$val1[x$group == "a"] >= 0) * na)
  expect_equal(res$percentage_not_negative[2], sum(x$val1[x$group == "b"] >= 0) * nb)

  expect_no_error(result <- summariseResult(
    table = cdm$test,
    group = "group",
    variables = c("val1", "val2"),
    weights = "w",
    estimates = c(
      "count_0", "count_positive", "count_negative", "count_not_positive",
      "count_not_negative", "percentage_0", "percentage_positive",
      "percentage_negative", "percentage_not_positive",
      "percentage_not_negative"
    )
  ))

  res <- result |>
    dplyr::filter(.data$variable_name != "number records") |>
    omopgenerics::tidy()

  # same results for val1 and val2
  expect_identical(
    res |>
      dplyr::filter(.data$variable_name == "val1") |>
      dplyr::select(!"variable_name"),
    res |>
      dplyr::filter(.data$variable_name == "val2") |>
      dplyr::select(!"variable_name")
  )

  res <- res[res$variable_name == "val1",]
  tol <- 0.01

  # count 0
  expect_equal(res$count_0[1], sum(x$w[x$group == "a" & x$val1 == 0]), tolerance = tol)
  expect_equal(res$count_0[2], sum(x$w[x$group == "b" & x$val1 == 0]), tolerance = tol)

  # count positive
  expect_equal(res$count_positive[1], sum(x$w[x$group == "a" & x$val1 > 0]), tolerance = tol)
  expect_equal(res$count_positive[2], sum(x$w[x$group == "b" & x$val1 > 0]), tolerance = tol)

  # count negative
  expect_equal(res$count_negative[1], sum(x$w[x$group == "a" & x$val1 < 0]), tolerance = tol)
  expect_equal(res$count_negative[2], sum(x$w[x$group == "b" & x$val1 < 0]), tolerance = tol)

  # count not positive
  expect_equal(res$count_not_positive[1], sum(x$w[x$group == "a" & x$val1 <= 0]), tolerance = tol)
  expect_equal(res$count_not_positive[2], sum(x$w[x$group == "b" & x$val1 <= 0]), tolerance = tol)

  # count not negative
  expect_equal(res$count_not_negative[1], sum(x$w[x$group == "a" & x$val1 >= 0]), tolerance = tol)
  expect_equal(res$count_not_negative[2], sum(x$w[x$group == "b" & x$val1 >= 0]), tolerance = tol)

  na <- 100/sum(x$w[x$group == "a" & !is.na(x$val1)])
  nb <- 100/sum(x$w[x$group == "b" & !is.na(x$val1)])

  # percentage 0
  expect_equal(res$percentage_0[1], sum(x$w[x$val1 == 0 & x$group == "a"]) * na, tolerance = tol)
  expect_equal(res$percentage_0[2], sum(x$w[x$val1 == 0 & x$group == "b"]) * nb, tolerance = tol)

  # percentage positive
  expect_equal(res$percentage_positive[1], sum(x$w[x$val1 > 0 & x$group == "a"]) * na, tolerance = tol)
  expect_equal(res$percentage_positive[2], sum(x$w[x$val1 > 0 & x$group == "b"]) * nb, tolerance = tol)

  # percentage negative
  expect_equal(res$percentage_negative[1], sum(x$w[x$val1 < 0 & x$group == "a"]) * na, tolerance = tol)
  expect_equal(res$percentage_negative[2], sum(x$w[x$val1 < 0 & x$group == "b"]) * nb, tolerance = tol)

  # percentage not positive
  expect_equal(res$percentage_not_positive[1], sum(x$w[x$val1 <= 0 & x$group == "a"]) * na, tolerance = tol)
  expect_equal(res$percentage_not_positive[2], sum(x$w[x$val1 <= 0 & x$group == "b"]) * nb, tolerance = tol)

  # percentage not negative
  expect_equal(res$percentage_not_negative[1], sum(x$w[x$val1 >= 0 & x$group == "a"]) * na, tolerance = tol)
  expect_equal(res$percentage_not_negative[2], sum(x$w[x$val1 >= 0 & x$group == "b"]) * nb, tolerance = tol)

  # no estimates
  expect_no_error(
    res <- summariseResult(
      table = cdm$test,
      variables = "group",
      estimates = "density",
      count = FALSE
    )
  )

  x <- dplyr::tibble(
    group = c(rep("a", 5), rep("b", 3)),
    person_id = c(1L, 1L, 2L, 2L, 3L, 2L, 1L, 1L),
    subject_id = c(1L, 2L, 2L, 2L, 2L, 2L, 4L, 4L),
    w = c(0.4, 2.5, 4.5, 1.1, 3.4, 1.4, 0.98, 0.45)
  )

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test", table = x)

  # count_subject count_person
  # no person_id or subject_id column
  expect_no_error(result1 <- summariseResult(
    table = cdm$test |>
      dplyr::select(!c("person_id", "subject_id")),
    variables = c("group"),
    estimates = c("count_person", "count_subject"),
    counts = FALSE
  ))
  expect_true(nrow(result1) == 0)
  expect_no_error(result1w <- summariseResult(
    table = cdm$test |>
      dplyr::select(!c("person_id", "subject_id")),
    variables = c("group"),
    estimates = c("count_person", "count_subject"),
    counts = FALSE,
    weights = "w"
  ))
  expect_equal(result1, result1w, ignore_attr = TRUE)

  # no person_id column
  expect_no_error(result2 <- summariseResult(
    table = cdm$test |>
      dplyr::select(!"person_id"),
    variables = c("group"),
    estimates = c("count_person", "count_subject"),
    counts = FALSE
  ))
  expect_true(nrow(result2) == 2)
  res <- omopgenerics::tidy(result2)
  expect_identical(res$count_subject, c(2L, 2L))
  expect_no_error(result2w <- summariseResult(
    table = cdm$test |>
      dplyr::select(!"person_id"),
    variables = c("group"),
    estimates = c("count_person", "count_subject"),
    counts = FALSE
  ))
  expect_equal(result2, result2w, ignore_attr = TRUE)

  # no subject_id column
  expect_no_error(result3 <- summariseResult(
    table = cdm$test |>
      dplyr::select(!"subject_id"),
    variables = c("group"),
    estimates = c("count_person", "count_subject"),
    counts = FALSE
  ))
  expect_true(nrow(result3) == 2)
  res <- omopgenerics::tidy(result3)
  expect_identical(res$count_person, c(3L, 2L))
  expect_no_error(result3w <- summariseResult(
    table = cdm$test |>
      dplyr::select(!"subject_id"),
    variables = c("group"),
    estimates = c("count_person", "count_subject"),
    counts = FALSE
  ))
  expect_equal(result3, result3w, ignore_attr = TRUE)

  # test binary variables and count
  cdm <- mockPatientProfiles() |>
    copyCdm()

  x <- dplyr::tibble(
    group = c(rep("a", 5), rep("b", 3)),
    val1 = c(0, 1, 0, 1, NA, NA, 1, 0),
    val2 = c(-5, 1, 0, 4, 2, -1, 1, -5),
    val3 = c(0L, 1L, 0, 1L, NA, NA, 1L, 0),
    val4 = c(-5L, 1L, 0L, 4L, 2L, -1L, 1L, -5L)
  )

  cdm <- omopgenerics::insertTable(cdm = cdm, name = "test", table = x)

  expect_no_error(res <- summariseResult(
    table = cdm$test,
    variables = c("val1", "val2", "val3", "val4"),
    estimates = c("count", "percentage", "mean"),
    counts = FALSE
  ))
  expect_identical(res$estimate_name[res$variable_name == "val1"], c("count", "percentage", "mean"))
  expect_identical(res$estimate_name[res$variable_name == "val2"], "mean")
  expect_identical(res$estimate_name[res$variable_name == "val3"], c("count", "percentage", "mean"))
  expect_identical(res$estimate_name[res$variable_name == "val4"], "mean")

  dropCreatedTables(cdm = cdm)
})

test_that("no cdm_table still works", {
  skip_if(dbToTest == "duckdb")

  con <- duckdb::dbConnect(drv = duckdb::duckdb())
  duckdb::dbWriteTable(conn = con, name = "cars", value = cars)
  cars_db <- dplyr::tbl(src = con, "cars")

  expect_no_warning(summariseResult(cars_db, variables = "speed"))

  duckdb::dbDisconnect(conn = con)
})
