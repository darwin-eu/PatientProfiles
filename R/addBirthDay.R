#' Add the birth day of an individual to a table
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' The function accounts for leap years and corrects the invalid dates to the
#' next valid date.
#'
#' @inheritParams addDemographics
#' @param birthday Number of birth day.
#' @param birthdayName Birth day variable name.
#'
#' @return The table with a new column containing the birth day.
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#' library(dplyr)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort1 |>
#'   addBirthday() |>
#'   glimpse()
#'
#' cdm$cohort1 |>
#'   addBirthday(birthday = 5, birthdayName = "bithday_5th") |>
#'   glimpse()
#' }
#'
addBirthday <- function(x,
                        birthday = 0,
                        birthdayName = "birthday",
                        ageMissingMonth = 1L,
                        ageMissingDay = 1L,
                        ageImposeMonth = FALSE,
                        ageImposeDay = FALSE,
                        name = NULL) {
  name <- omopgenerics::validateNameArgument(name = name, null = TRUE)
  .addBirthdayQuery(
    x = x,
    birthdayName = birthdayName,
    birthday = birthday,
    ageMissingMonth = ageMissingMonth,
    ageMissingDay = ageMissingDay,
    ageImposeMonth = ageImposeMonth,
    ageImposeDay = ageImposeDay
  ) |>
    dplyr::compute(name = name)
}

#' Add the birth day of an individual to a table
#'
#' @description
#' `r lifecycle::badge("experimental")`
#' Same as `addBirthday()`, except query is not computed to a table.
#'
#' The function accounts for leap years and corrects the invalid dates to the
#' next valid date.
#'
#' @inheritParams addBirthday
#'
#' @return The table with a query that add the new column containing the birth
#' day.
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#' library(dplyr)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort1 |>
#'   addBirthdayQuery() |>
#'   glimpse()
#'
#' cdm$cohort1 |>
#'   addBirthdayQuery(birthday = 5) |>
#'   glimpse()
#' }
#'
addBirthdayQuery <- function(x,
                             birthdayName = "birthday",
                             birthday = 0,
                             ageMissingMonth = 1,
                             ageMissingDay = 1,
                             ageImposeMonth = FALSE,
                             ageImposeDay = FALSE) {
  .addBirthdayQuery(
    x = x,
    birthdayName = birthdayName,
    birthday = birthday,
    ageMissingMonth = ageMissingMonth,
    ageMissingDay = ageMissingDay,
    ageImposeMonth = ageImposeMonth,
    ageImposeDay = ageImposeDay
  )
}

.addBirthdayQuery <- function(x,
                              birthdayName,
                              birthday,
                              ageMissingMonth,
                              ageMissingDay,
                              ageImposeMonth,
                              ageImposeDay,
                              call = parent.frame()) {
  # initial checks
  x <- omopgenerics::validateCdmTable(table = x, call = call)
  id <- omopgenerics::getPersonIdentifier(x = x, call = call)
  x <- omopgenerics::validateNewColumn(table = x, column = birthdayName, call = call)
  omopgenerics::assertNumeric(birthday, integerish = TRUE, length = 1, call = call)
  ageMissingMonth <- validateAgeMissingMonth(ageMissingMonth, null = FALSE, call = call)
  ageMissingDay <- validateAgeMissingDay(ageMissingDay, null = FALSE, call = call)
  omopgenerics::assertLogical(ageImposeMonth, length = 1, call = call)
  omopgenerics::assertLogical(ageImposeDay, length = 1, call = call)

  cdm <- omopgenerics::cdmReference(table = x)

  # correct day
  if (ageImposeDay | !"day_of_birth" %in% colnames(cdm$person)) {
    qD <- "{ageMissingDay}L"
  } else {
    qD <- "dplyr::coalesce(as.integer(.data$day_of_birth), {ageMissingDay}L)"
  }

  # correct month
  if (ageImposeMonth | !"month_of_birth" %in% colnames(cdm$person)) {
    qM <- "{ageMissingMonth}L"
  } else {
    qM <- "dplyr::coalesce(as.integer(.data$month_of_birth), {ageMissingMonth}L)"
  }

  # add number of years
  qY <- paste0("as.integer(.data$year_of_birth + ", as.integer(birthday), "L)")

  # correct day of birth depending on leap year
  qLp <- "dplyr::case_when(
    .data$year_of_birth %% 4 == 0 & (.data$year_of_birth %% 100 != 0 | .data$year_of_birth %% 400 == 0) & .data$day_of_birth == 29L & .data$month_of_birth == 2L ~ 0L,
    .data$day_of_birth == 29L & .data$month_of_birth == 2L ~ 1L,
    .default = 0L
  )"

  # date of interest
  if (inherits(x, "tbl_duckdb_connection")) {
    qDt <- "dplyr::case_when(
      is.na(.data$year_of_birth) ~ as.Date(NA),
      .data$correct_leap_year == 0 ~ dbplyr::sql('make_date(year_of_birth, month_of_birth, day_of_birth)'),
      .data$correct_leap_year == 1 ~ dbplyr::sql('make_date(year_of_birth, 3, 1)')
    )"
  } else {
    qDt <- "dplyr::case_when(
      is.na(.data$year_of_birth) ~ as.Date(NA),
      .data$correct_leap_year == 0 ~ clock::date_build(year = .data$year_of_birth, month = .data$month_of_birth, day = .data$day_of_birth{ft}),
      .data$correct_leap_year == 1 ~ clock::date_build(year = .data$year_of_birth, month = 3L, day = 1L)
    )"
  }

  if (inherits(x, "data.frame")) {
    ft <- ", invalid = 'next'"
  } else {
    ft <- ""
  }

  q <- c(qD, qM, qY, qLp, qDt) |>
    purrr::map_chr(\(x) glue::glue(
      x,
      ageMissingDay = ageMissingDay,
      ageMissingMonth = ageMissingMonth,
      ft = ft
    )) |>
    rlang::set_names(c(
      "day_of_birth", "month_of_birth", "year_of_birth", "correct_leap_year",
      birthdayName
    )) |>
    rlang::parse_exprs()

  sel <- rlang::set_names(c("person_id", birthdayName), c(id, birthdayName))

  x |>
    dplyr::left_join(
      cdm$person |>
        dplyr::mutate(!!!q) |>
        dplyr::select(dplyr::all_of(sel)),
      by = id
    )
}
