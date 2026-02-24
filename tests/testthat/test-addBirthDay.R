test_that("addBirthday functions", {
  skip_on_cran()
  cdm <- omock::mockCdmFromTables(tables = list(
    person = dplyr::tibble(
      person_id = 1:5L,
      year_of_birth = c(1990L, 1991L, 1992L, 1993L, 1994L),
      month_of_birth = c(1L, NA, 2L, 2L, 4L),
      day_of_birth = c(30L, 29L, 29L, NA, 1L),
      gender_concept_id = 0L
    ),
    cohort = dplyr::tibble(
      cohort_definition_id = 1L,
      subject_id = 1:5L,
      cohort_start_date = as.Date("2010-01-01"),
      cohort_end_date = cohort_start_date
    ),
    observation_period = dplyr::tibble(
      observation_period_id = 1:5L,
      person_id = 1:5L,
      observation_period_start_date = as.Date("2000-01-01"),
      observation_period_end_date = as.Date("2020-01-01")
    )
  )) |>
    copyCdm()

  expect_no_error(
    x <- cdm$cohort |>
      addBirthday() |>
      dplyr::collect() |>
      dplyr::arrange(.data$subject_id)
  )
  expect_identical(
    x$birthday,
    as.Date(c("1990-01-30", "1991-01-29", "1992-02-29", "1993-02-01", "1994-04-01"))
  )

  expect_no_error(
    x <- cdm$cohort |>
      addBirthday(birthday = 1) |>
      dplyr::collect() |>
      dplyr::arrange(.data$subject_id)
  )
  expect_identical(
    x$birthday,
    as.Date(c("1991-01-30", "1992-01-29", "1993-03-01", "1994-02-01", "1995-04-01"))
  )

  expect_no_error(
    x <- cdm$cohort |>
      addBirthday(birthday = 2) |>
      dplyr::collect() |>
      dplyr::arrange(.data$subject_id)
  )
  expect_identical(
    x$birthday,
    as.Date(c("1992-01-30", "1993-01-29", "1994-03-01", "1995-02-01", "1996-04-01"))
  )

  expect_no_error(
    x <- cdm$cohort |>
      addBirthday(birthday = 3) |>
      dplyr::collect() |>
      dplyr::arrange(.data$subject_id)
  )
  expect_identical(
    x$birthday,
    as.Date(c("1993-01-30", "1994-01-29", "1995-03-01", "1996-02-01", "1997-04-01"))
  )

  expect_no_error(
    x <- cdm$cohort |>
      addBirthday(birthday = 4) |>
      dplyr::collect() |>
      dplyr::arrange(.data$subject_id)
  )
  expect_identical(
    x$birthday,
    as.Date(c("1994-01-30", "1995-01-29", "1996-02-29", "1997-02-01", "1998-04-01"))
  )

  # missing dates
  expect_no_error(
    x <- cdm$cohort |>
      addBirthday(ageMissingMonth = 2, ageMissingDay = 29) |>
      dplyr::collect() |>
      dplyr::arrange(.data$subject_id)
  )
  expect_identical(
    x$birthday,
    as.Date(c("1990-01-30", "1991-03-01", "1992-02-29", "1993-03-01", "1994-04-01"))
  )
  expect_no_error(
    x <- cdm$cohort |>
      addBirthday(birthday = 1, ageMissingMonth = 2, ageMissingDay = 29) |>
      dplyr::collect() |>
      dplyr::arrange(.data$subject_id)
  )
  expect_identical(
    x$birthday,
    as.Date(c("1991-01-30", "1992-02-29", "1993-03-01", "1994-03-01", "1995-04-01"))
  )
  expect_no_error(
    x <- cdm$cohort |>
      addBirthday(birthday = -1, ageMissingMonth = 2, ageMissingDay = 29) |>
      dplyr::collect() |>
      dplyr::arrange(.data$subject_id)
  )
  expect_identical(
    x$birthday,
    as.Date(c("1989-01-30", "1990-03-01", "1991-03-01", "1992-02-29", "1993-04-01"))
  )

  # impose days
  expect_no_error(
    x <- cdm$cohort |>
      addBirthday(birthday = 2, ageMissingMonth = 2, ageMissingDay = 29, ageImposeMonth = TRUE, ageImposeDay = TRUE) |>
      dplyr::collect() |>
      dplyr::arrange(.data$subject_id)
  )
  expect_identical(
    x$birthday,
    as.Date(c("1992-02-29", "1993-03-01", "1994-03-01", "1995-03-01", "1996-02-29"))
  )

  # name
  expect_no_error(
    x <- cdm$cohort |>
      addBirthday(name = "new_table")
  )
  expect_true("new_table" %in% omopgenerics::listSourceTables(cdm = cdm))

  # query
  ls <- omopgenerics::listSourceTables(cdm = cdm)
  expect_no_error(
    xx <- cdm$cohort |>
      addBirthdayQuery()
  )
  expect_identical(ls, omopgenerics::listSourceTables(cdm = cdm))
  expect_identical(
    x |>
      dplyr::collect() |>
      dplyr::arrange(.data$subject_id),
    xx |>
      dplyr::collect() |>
      dplyr::arrange(.data$subject_id)
  )

  dropCreatedTables(cdm = cdm)
})
