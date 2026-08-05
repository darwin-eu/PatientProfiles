#' Add the birth day of an individual to a table
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' The function accounts for leap years and corrects the invalid dates to the
#' next valid date.
#'
#' @inheritParams xDoc
#' @inheritParams birthdayDoc
#' @inheritParams birthdayNameDoc
#' @inheritParams ageMissingMonthDoc
#' @inheritParams ageMissingDayDoc
#' @inheritParams ageImposeMonthDoc
#' @inheritParams ageImposeDayDoc
#' @inheritParams ageUnitDoc
#' @inheritParams nameDoc
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
                        ageUnit = "years",
                        name = NULL) {
  name <- omopgenerics::validateNameArgument(name = name, null = TRUE)
  .addBirthdayQuery(
    x = x,
    birthdayName = birthdayName,
    birthday = birthday,
    ageMissingMonth = ageMissingMonth,
    ageMissingDay = ageMissingDay,
    ageImposeMonth = ageImposeMonth,
    ageImposeDay = ageImposeDay,
    ageUnit = ageUnit
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
#' @inheritParams xDoc
#' @inheritParams birthdayDoc
#' @inheritParams birthdayNameDoc
#' @inheritParams ageMissingMonthDoc
#' @inheritParams ageMissingDayDoc
#' @inheritParams ageImposeMonthDoc
#' @inheritParams ageImposeDayDoc
#' @inheritParams ageUnitDoc
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
                             ageImposeDay = FALSE,
                             ageUnit = "years") {
  .addBirthdayQuery(
    x = x,
    birthdayName = birthdayName,
    birthday = birthday,
    ageMissingMonth = ageMissingMonth,
    ageMissingDay = ageMissingDay,
    ageImposeMonth = ageImposeMonth,
    ageImposeDay = ageImposeDay,
    ageUnit = ageUnit
  )
}

.addBirthdayQuery <- function(x,
                              birthdayName,
                              birthday,
                              ageMissingMonth,
                              ageMissingDay,
                              ageImposeMonth,
                              ageImposeDay,
                              ageUnit,
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
  omopgenerics::assertChoice(ageUnit, c("days", "months", "years"), length = 1, call = call)

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

  # add number of units
  if (ageUnit == "years") {
    qY <- paste0("as.integer(.data$year_of_birth + ", as.integer(birthday), "L)")
    qMonth <- NULL
  } else if (ageUnit == "months") {
    monthIndex <- glue::glue(
      "(.data$month_of_birth - 1L + {as.integer(birthday)}L)"
    )
    qY <- glue::glue(
      "as.integer(.data$year_of_birth + floor({monthIndex} / 12.0))"
    )
    qMonth <- glue::glue(
      "as.integer({monthIndex} - floor({monthIndex} / 12.0) * 12L + 1L)"
    )
  } else {
    qY <- "as.integer(.data$year_of_birth)"
    qMonth <- NULL
  }

  # correct invalid dates
  qLp <- "dplyr::case_when(
    .data$month_of_birth == 2L & .data$day_of_birth > dplyr::if_else(
      .data$year_of_birth %% 4L == 0L & (.data$year_of_birth %% 100L != 0L | .data$year_of_birth %% 400L == 0L),
      29L,
      28L
    ) ~ 1L,
    .data$month_of_birth %in% c(4L, 6L, 9L, 11L) & .data$day_of_birth > 30L ~ 1L,
    .default = 0L
  )"

  # date of interest
  dateBuild <- .dateBuildQuery(
    x = x,
    year = ".data$year_of_birth",
    month = ".data$month_of_birth",
    day = ".data$day_of_birth"
  )
  leapDateBuild <- .dateBuildQuery(
    x = x,
    year = ".data$year_of_birth",
    month = "dplyr::if_else(.data$month_of_birth == 12L, 12L, .data$month_of_birth + 1L)",
    day = "1L"
  )
  qDt <- glue::glue("dplyr::case_when(
    is.na(.data$year_of_birth) ~ as.Date(NA),
    .data$correct_leap_year == 0 ~ {dateBuild},
    .data$correct_leap_year == 1 ~ {leapDateBuild}
  )")

  if (ageUnit == "days") {
    qDt <- glue::glue(
      "as.Date(clock::add_days(x = ({qDt}), n = {as.integer(birthday)}L))"
    )
  }

  q <- c(qD, qM, qY) |>
    purrr::map_chr(\(x) glue::glue(
      x,
      ageMissingDay = ageMissingDay,
      ageMissingMonth = ageMissingMonth
    )) |>
    rlang::set_names(c("day_of_birth", "month_of_birth", "year_of_birth")) |>
    rlang::parse_exprs()

  if (!is.null(qMonth)) {
    qMonth <- qMonth |>
      rlang::parse_exprs() |>
      rlang::set_names("month_of_birth")
  }

  qBirthday <- c(qLp, qDt) |>
    purrr::map_chr(\(x) glue::glue(x)) |>
    rlang::set_names(c("correct_leap_year", birthdayName)) |>
    rlang::parse_exprs()

  sel <- rlang::set_names(c("person_id", birthdayName), c(id, birthdayName))

  x |>
    dplyr::left_join(
      cdm$person |>
        dplyr::mutate(!!!q) |>
        dplyr::mutate(!!!qMonth) |>
        dplyr::mutate(!!!qBirthday) |>
        dplyr::select(dplyr::all_of(sel)),
      by = id
    )
}
