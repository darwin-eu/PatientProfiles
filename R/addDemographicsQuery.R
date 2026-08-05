# Copyright 2024 DARWIN EU (C)
#
# This file is part of PatientProfiles
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' Query to add demographic characteristics at a certain date
#'
#' @description
#' Same as `addDemographics()`, except query is not computed to a table.
#'
#' @inheritParams xDoc
#' @inheritParams indexDateDoc
#' @inheritParams ageDoc
#' @inheritParams ageNameDoc
#' @inheritParams ageMissingMonthDoc
#' @inheritParams ageMissingDayDoc
#' @inheritParams ageImposeMonthDoc
#' @inheritParams ageImposeDayDoc
#' @inheritParams ageUnitDoc
#' @inheritParams ageGroupDoc
#' @inheritParams missingAgeGroupValueDoc
#' @inheritParams sexDoc
#' @inheritParams sexNameDoc
#' @inheritParams missingSexValueDoc
#' @inheritParams priorObservationDoc
#' @inheritParams priorObservationNameDoc
#' @inheritParams priorObservationTypeDoc
#' @inheritParams futureObservationDoc
#' @inheritParams futureObservationNameDoc
#' @inheritParams futureObservationTypeDoc
#' @inheritParams dateOfBirthDoc
#' @inheritParams dateOfBirthNameDoc
#' @inheritParams typeDoc
#'
#' @return cohort table with the added demographic information columns.
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort1 |>
#'   addDemographicsQuery()
#'
#' }
#'
addDemographicsQuery <- function(x,
                                 indexDate = "cohort_start_date",
                                 age = TRUE,
                                 ageName = "age",
                                 ageMissingMonth = 1,
                                 ageMissingDay = 1,
                                 ageImposeMonth = FALSE,
                                 ageImposeDay = FALSE,
                                 ageUnit = "years",
                                 ageGroup = NULL,
                                 missingAgeGroupValue = "None",
                                 sex = TRUE,
                                 sexName = "sex",
                                 missingSexValue = "None",
                                 priorObservation = TRUE,
                                 priorObservationName = "prior_observation",
                                 priorObservationType = "days",
                                 futureObservation = TRUE,
                                 futureObservationName = "future_observation",
                                 futureObservationType = "days",
                                 dateOfBirth = FALSE,
                                 dateOfBirthName = "date_of_birth",
                                 type = "numeric") {
  x |>
    .addDemographicsQuery(
      indexDate = indexDate,
      age = age,
      ageGroup = ageGroup,
      ageMissingDay = ageMissingDay,
      ageMissingMonth = ageMissingMonth,
      ageImposeDay = ageImposeDay,
      ageImposeMonth = ageImposeMonth,
      ageUnit = ageUnit,
      sex = sex,
      sexName = sexName,
      missingSexValue = missingSexValue,
      priorObservation = priorObservation,
      futureObservation = futureObservation,
      ageName = ageName,
      priorObservationName = priorObservationName,
      futureObservationName = futureObservationName,
      missingAgeGroupValue = missingAgeGroupValue,
      priorObservationType = priorObservationType,
      futureObservationType = futureObservationType,
      dateOfBirth = dateOfBirth,
      dateOfBirthName = dateOfBirthName,
      type = type
    )
}

#' Query to add the age of the individuals at a certain date
#'
#' @description
#' Same as `addAge()`, except query is not computed to a table.
#'
#' @inheritParams xDoc
#' @inheritParams indexDateDoc
#' @inheritParams ageNameDoc
#' @inheritParams ageGroupDoc
#' @inheritParams ageMissingMonthDoc
#' @inheritParams ageMissingDayDoc
#' @inheritParams ageImposeMonthDoc
#' @inheritParams ageImposeDayDoc
#' @inheritParams ageUnitDoc
#' @inheritParams missingAgeGroupValueDoc
#' @inheritParams typeDoc
#'
#' @return tibble with the age column added.
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort1 |>
#'   addAgeQuery()
#'
#' }
addAgeQuery <- function(x,
                        indexDate = "cohort_start_date",
                        ageName = "age",
                        ageGroup = NULL,
                        ageMissingMonth = 1,
                        ageMissingDay = 1,
                        ageImposeMonth = FALSE,
                        ageImposeDay = FALSE,
                        ageUnit = "years",
                        missingAgeGroupValue = "None",
                        type = "numeric") {
  x |>
    .addDemographicsQuery(
      indexDate = indexDate,
      age = TRUE,
      ageName = ageName,
      ageGroup = ageGroup,
      ageMissingDay = ageMissingDay,
      ageMissingMonth = ageMissingMonth,
      ageImposeDay = ageImposeDay,
      ageImposeMonth = ageImposeMonth,
      ageUnit = ageUnit,
      missingAgeGroupValue = missingAgeGroupValue,
      sex = FALSE,
      priorObservation = FALSE,
      futureObservation = FALSE,
      sexName = NULL,
      priorObservationName = NULL,
      futureObservationName = NULL,
      missingSexValue = NULL,
      priorObservationType = NULL,
      futureObservationType = NULL,
      dateOfBirth = FALSE,
      dateOfBirthName = NULL,
      type = type
    )
}

#' Query to add the number of days till the end of the observation period at a
#' certain date
#'
#' @description
#' Same as `addFutureObservation()`, except query is not computed to a table.
#'
#' @inheritParams xDoc
#' @inheritParams indexDateDoc
#' @inheritParams futureObservationNameDoc
#' @inheritParams futureObservationTypeDoc
#' @inheritParams typeDoc
#'
#' @return cohort table with added column containing future observation of the
#' individuals.
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort1 |>
#'   addFutureObservationQuery()
#'
#' }
addFutureObservationQuery <- function(x,
                                      indexDate = "cohort_start_date",
                                      futureObservationName = "future_observation",
                                      futureObservationType = "days",
                                      type = "numeric") {
  x |>
    .addDemographicsQuery(
      indexDate = indexDate,
      age = FALSE,
      ageGroup = NULL,
      ageMissingDay = NULL,
      ageMissingMonth = NULL,
      ageImposeDay = FALSE,
      ageImposeMonth = FALSE,
      ageUnit = "years",
      sex = FALSE,
      priorObservation = FALSE,
      futureObservation = TRUE,
      futureObservationName = futureObservationName,
      futureObservationType = futureObservationType,
      ageName = NULL,
      sexName = NULL,
      priorObservationName = NULL,
      missingAgeGroupValue = NULL,
      missingSexValue = NULL,
      priorObservationType = NULL,
      dateOfBirth = FALSE,
      dateOfBirthName = NULL,
      type = type
    )
}

#' Query to add the number of days of prior observation in the current
#' observation period at a certain date
#'
#' @description
#' Same as `addPriorObservation()`, except query is not computed to a table.
#'
#' @inheritParams xDoc
#' @inheritParams indexDateDoc
#' @inheritParams priorObservationNameDoc
#' @inheritParams priorObservationTypeDoc
#' @inheritParams typeDoc
#'
#' @return cohort table with added column containing prior observation of the
#' individuals.
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort1 |>
#'   addPriorObservationQuery()
#'
#' }
addPriorObservationQuery <- function(x,
                                     indexDate = "cohort_start_date",
                                     priorObservationName = "prior_observation",
                                     priorObservationType = "days",
                                     type = "numeric") {
  x |>
    .addDemographicsQuery(
      indexDate = indexDate,
      age = FALSE,
      ageGroup = NULL,
      ageMissingDay = NULL,
      ageMissingMonth = NULL,
      ageImposeDay = FALSE,
      ageImposeMonth = FALSE,
      ageUnit = "years",
      sex = FALSE,
      priorObservation = TRUE,
      priorObservationName = priorObservationName,
      priorObservationType = priorObservationType,
      futureObservation = FALSE,
      ageName = NULL,
      sexName = NULL,
      futureObservationName = NULL,
      missingAgeGroupValue = NULL,
      missingSexValue = NULL,
      futureObservationType = NULL,
      dateOfBirth = FALSE,
      dateOfBirthName = NULL,
      type = type
    )
}

#' Query to add the sex of the individuals
#'
#' @description
#' Same as `addSex()`, except query is not computed to a table.
#'
#' @inheritParams xDoc
#' @inheritParams sexNameDoc
#' @inheritParams missingSexValueDoc
#'
#' @return table x with the added column with sex information.
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort1 |>
#'   addSexQuery()
#'
#' }
#'
addSexQuery <- function(x,
                        sexName = "sex",
                        missingSexValue = "None") {
  x |>
    .addDemographicsQuery(
      indexDate = NULL,
      age = FALSE,
      ageGroup = NULL,
      ageMissingDay = NULL,
      ageMissingMonth = NULL,
      ageImposeDay = FALSE,
      ageImposeMonth = FALSE,
      ageUnit = "years",
      sex = TRUE,
      sexName = sexName,
      missingSexValue = missingSexValue,
      priorObservation = FALSE,
      futureObservation = FALSE,
      ageName = NULL,
      priorObservationName = NULL,
      futureObservationName = NULL,
      missingAgeGroupValue = NULL,
      priorObservationType = NULL,
      futureObservationType = NULL,
      dateOfBirth = FALSE,
      dateOfBirthName = NULL
    )
}

#' Query to add a column with the individual birth date
#'
#' @description
#' Same as `addDateOfBirth()`, except query is not computed to a table.
#'
#' @inheritParams xDoc
#' @inheritParams dateOfBirthNameDoc
#' @inheritParams missingDayDoc
#' @inheritParams missingMonthDoc
#' @inheritParams imposeDayDoc
#' @inheritParams imposeMonthDoc
#'
#' @return The function returns the table x with an extra column that contains
#' the date of birth.
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort1 |>
#'   addDateOfBirthQuery()
#'
#' }
addDateOfBirthQuery <- function(x,
                                dateOfBirthName = "date_of_birth",
                                missingDay = 1,
                                missingMonth = 1,
                                imposeDay = FALSE,
                                imposeMonth = FALSE) {
  x |>
    .addDemographicsQuery(
      indexDate = NULL,
      age = FALSE,
      ageGroup = NULL,
      ageMissingDay = missingDay,
      ageMissingMonth = missingMonth,
      ageImposeDay = imposeDay,
      ageImposeMonth = imposeMonth,
      ageUnit = "years",
      sex = FALSE,
      sexName = NULL,
      missingSexValue = NULL,
      priorObservation = FALSE,
      futureObservation = FALSE,
      ageName = NULL,
      priorObservationName = NULL,
      futureObservationName = NULL,
      missingAgeGroupValue = NULL,
      priorObservationType = NULL,
      futureObservationType = NULL,
      dateOfBirth = TRUE,
      dateOfBirthName = dateOfBirthName
    )
}

.addDemographicsQuery <- function(x,
                                  indexDate,
                                  age,
                                  ageName,
                                  ageMissingMonth,
                                  ageMissingDay,
                                  ageImposeMonth,
                                  ageImposeDay,
                                  ageGroup,
                                  ageUnit,
                                  missingAgeGroupValue,
                                  sex,
                                  sexName,
                                  missingSexValue,
                                  priorObservation,
                                  priorObservationName,
                                  priorObservationType,
                                  futureObservation,
                                  futureObservationName,
                                  futureObservationType,
                                  dateOfBirth,
                                  dateOfBirthName,
                                  type = "numeric",
                                  tmpName = NULL,
                                  call = parent.frame()) {
  type <- validateColumnType(type, "observation", call)

  # initial checks
  x <- omopgenerics::validateCdmTable(table = x)
  originalColumns <- colnames(x)
  omopgenerics::assertLogical(age, length = 1, call = call)
  omopgenerics::assertLogical(sex, length = 1, call = call)
  omopgenerics::assertLogical(priorObservation, length = 1, call = call)
  omopgenerics::assertLogical(futureObservation, length = 1, call = call)
  omopgenerics::assertLogical(dateOfBirth, length = 1, call = call)
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup, call = call)
  notIndexDate <- !any(c(
    age, !is.null(ageGroup), priorObservation, futureObservation
  ))
  indexDateInput <- materialiseIndexDate(
    indexDate = indexDate, x = x, null = notIndexDate, call = call
  )
  x <- indexDateInput$x
  indexDate <- indexDateInput$indexDate
  ageName <- validateColumn(ageName, null = !age, call = call)
  sexName <- validateColumn(sexName, null = !sex, call = call)
  priorObservationName <- validateColumn(priorObservationName, null = !priorObservation, call = call)
  futureObservationName <- validateColumn(futureObservationName, null = !futureObservation, call = call)
  dateOfBirthName <- validateColumn(dateOfBirthName, null = !dateOfBirth, call = call)
  noAge <- !age & length(ageGroup) == 0 & !dateOfBirth
  ageMissingMonth <- validateAgeMissingMonth(ageMissingMonth, null = noAge, call = call)
  ageMissingDay <- validateAgeMissingDay(ageMissingDay, null = noAge, call = call)
  omopgenerics::assertLogical(ageImposeMonth, length = 1, call = call)
  omopgenerics::assertLogical(ageImposeDay, length = 1, call = call)
  missingAgeGroupValue <- validateMissingValue(missingAgeGroupValue, null = !age & length(ageGroup) == 0, call = call)
  missingSexValue <- validateMissingValue(missingSexValue, null = !sex, call = call)
  priorObservationType <- validateType(priorObservationType, null = !priorObservation, call = call)
  futureObservationType <- validateType(futureObservationType, null = !futureObservation, call = call)
  omopgenerics::assertChoice(ageUnit, c("days", "months", "years"), length = 1, call = call)

  # if no new columns return x
  if (!(age | sex | priorObservation | futureObservation | dateOfBirth | !is.null(ageGroup))) {
    return(x)
  }

  newColumns <- c(ageName, names(ageGroup), sexName, priorObservationName, futureObservationName, dateOfBirthName)
  toEliminate <- newColumns[newColumns %in% colnames(x)]
  if (length(toEliminate) > 0) {
    cli::cli_warn(c("!" = "The following columns will be overwritten: {toEliminate}"))
    x <- x |> dplyr::select(!dplyr::all_of(toEliminate))
  }

  if (!identical(unique(newColumns), newColumns)) {
    cli::cli_abort("Names of new columns must be unique: {newColumns}.", call = call)
  }

  cdm <- omopgenerics::cdmReference(x)

  personVariable <- omopgenerics::getPersonIdentifier(x)

  newCols <- omopgenerics::uniqueId(n = 2, exclude = c(colnames(x), newColumns))

  # OBSERVATION PERIOD JOIN
  if (priorObservation || futureObservation) {

    # prior observation
    if (priorObservation == TRUE) {
      if (priorObservationType == "days") {
        pHQ <- glue::glue(
          'as.integer(clock::date_count_between(start = .data$start_date, end = .data[["{indexDate}"]], precision = "day"))'
        )
      } else {
        pHQ <- ".data$start_date"
      }
      pHQ <- pHQ |>
        rlang::parse_exprs() |>
        rlang::set_names(glue::glue(priorObservationName))
    } else {
      pHQ <- NULL
    }

    # future observation
    if (futureObservation == TRUE) {
      if (futureObservationType == "days") {
        fOQ <- glue::glue(
          'as.integer(clock::date_count_between(start = .data[["{indexDate}"]], end = .data$end_date, precision = "day"))'
        )
      } else {
        fOQ <- ".data$end_date"
      }
      fOQ <- fOQ |>
        rlang::parse_exprs() |>
        rlang::set_names(futureObservationName)
    } else {
      fOQ <- NULL
    }

    distinctSubjects <- x |>
      dplyr::select(dplyr::all_of(c(personVariable, indexDate))) |>
      dplyr::distinct()

    if(!is.null(tmpName)){
      distinctSubjects <- distinctSubjects  |> dplyr::compute(name = tmpName,
                                                              temporary = FALSE,
                                                              logPrefix = "PatientProfiles.addDemographicsQuery_distinctSubjects")
    }

    observationPeriod <- distinctSubjects |>
      dplyr::inner_join(
        cdm[["observation_period"]] |>
          dplyr::select(
            !!personVariable := "person_id",
            "start_date" = "observation_period_start_date",
            "end_date" = "observation_period_end_date"
          ),
        by = personVariable
      ) |>
      dplyr::filter(
        .data$start_date <= .data[[indexDate]] &
          .data$end_date >= .data[[indexDate]]
      ) |>
      dplyr::mutate(!!!pHQ, !!!fOQ) |>
      dplyr::select(dplyr::all_of(c(
        personVariable, indexDate, priorObservationName, futureObservationName
      )))

    if(!is.null(tmpName)){
      observationPeriod <- observationPeriod  |> dplyr::compute(name = tmpName,
                                                                temporary = FALSE,
                                                                logPrefix = "PatientProfiles.addDemographicsQuery_observationPeriod")
    }

    xnew <- x |>
      dplyr::left_join(observationPeriod, by = c(personVariable, indexDate))
  } else {
    xnew <- x
  }

  # PERSON TABLE JOIN
  if (age | !is.null(ageGroup) | dateOfBirth | sex) {
    if (!age && is.null(ageGroup) && !dateOfBirth) indexDate <- NULL

    # AGE QUERYS
    if (age | !is.null(ageGroup) | dateOfBirth) {
      if (!"day_of_birth" %in% colnames(cdm$person) || isTRUE(ageImposeDay)) {
        dB <- ".env$ageMissingDay"
      } else {
        dB <- "dplyr::if_else(is.na(.data$day_of_birth), .env$ageMissingDay, .data$day_of_birth)"
      }
      if (!"month_of_birth" %in% colnames(cdm$person) || isTRUE(ageImposeMonth)) {
        mB <- ".env$ageMissingMonth"
      } else {
        mB <- "dplyr::if_else(is.na(.data$month_of_birth), .env$ageMissingMonth, .data$month_of_birth)"
      }
      dBQ <- dB |>
        rlang::parse_exprs() |>
        rlang::set_names("day_of_birth")
      mBQ <- mB |>
        rlang::parse_exprs() |>
        rlang::set_names("month_of_birth")
      if (!dateOfBirth) {
        dateOfBirthName <- newCols[1]
      }
      dateBuild <- .dateBuildQuery(
        x = x,
        year = "as.integer(.data$year_of_birth)",
        month = "as.integer(.data$month_of_birth)",
        day = "as.integer(.data$day_of_birth)"
      )
      dtBQ <- "dplyr::if_else(
        is.na(.data$year_of_birth),
        as.Date(NA),
        {dateBuild}
      )"
      dtBQ <- dtBQ |>
        glue::glue(dateBuild = dateBuild) |>
        rlang::parse_exprs() |>
        rlang::set_names(dateOfBirthName)
      if (age || length(ageGroup) > 0) {
        if (!age) {
          ageName <- newCols[2]
        }
        aQ <- getAgeQuery(ageUnit) |>
          glue::glue() |>
          rlang::parse_exprs() |>
          rlang::set_names(ageName)
        if (length(ageGroup) > 0) {
          agQ <- ageGroupQuery(ageName, ageGroup, missingAgeGroupValue)
        } else {
          agQ <- NULL
        }
      } else {
        aQ <- NULL
        agQ <- NULL
      }
    } else {
      dBQ <- NULL
      mBQ <- NULL
      dtBQ <- NULL
      aQ <- NULL
      agQ <- NULL
    }
    if (sex == TRUE) {
      sQ <- 'dplyr::case_when(.data$gender_concept_id == 8507 ~ "Male",
          .data$gender_concept_id == 8532 ~ "Female"'
      if (is.na(missingSexValue)) {
        sQ <- glue::glue("{sQ}, .default = NA_character_)")
      } else {
        sQ <- glue::glue('{sQ}, .default = "{missingSexValue}")')
      }
      sQ <- sQ |>
        rlang::parse_exprs() |>
        rlang::set_names(sexName)
    } else {
      sQ <- NULL
    }

    xnew <- xnew |>
      dplyr::left_join(
        cdm$person |>
          dplyr::mutate(!!!c(dBQ, mBQ, dtBQ, sQ)) |>
          dplyr::select(dplyr::all_of(c(
            rlang::set_names("person_id", personVariable),
            sexName, dateOfBirthName
          ))),
        by = personVariable
      ) |>
      dplyr::mutate(!!!c(aQ, agQ))
  }

  xnew <- removeMaterialisedIndexDate(xnew, indexDateInput)

  columnsToConvert <- c(
    if (age) ageName,
    if (priorObservation && priorObservationType == "days") {
      priorObservationName
    },
    if (futureObservation && futureObservationType == "days") {
      futureObservationName
    }
  )
  xnew <- .convertColumnType(
    x = xnew,
    columns = columnsToConvert,
    type = type
  ) |>
    dplyr::select(dplyr::all_of(c(originalColumns, newColumns)))

  return(xnew)
}

getAgeQuery <- function(ageUnit) {
  if (ageUnit == "years") {
    aQ <- "as.integer(floor(
        (
          (clock::get_year(.data[['{indexDate}']]) * 10000 + clock::get_month(.data[['{indexDate}']]) * 100 + clock::get_day(.data[['{indexDate}']])) -
          (clock::get_year(.data[['{dateOfBirthName}']]) * 10000 + clock::get_month(.data[['{dateOfBirthName}']]) * 100 + clock::get_day(.data[['{dateOfBirthName}']]))
        ) / 10000
        ))"
  } else if (ageUnit == "months") {
    aQ <- "as.integer(floor(
        (
          (clock::get_year(.data[['{indexDate}']]) * 1200 + clock::get_month(.data[['{indexDate}']]) * 100 + clock::get_day(.data[['{indexDate}']])) -
          (clock::get_year(.data[['{dateOfBirthName}']]) * 1200 + clock::get_month(.data[['{dateOfBirthName}']]) * 100 + clock::get_day(.data[['{dateOfBirthName}']]))
        ) / 100
        ))"
  } else if (ageUnit == "days") {
    aQ <- "as.integer(clock::date_count_between(
      start = .data[['{dateOfBirthName}']],
      end = .data[['{indexDate}']],
      precision = 'day'
    ))"
  }
  return(aQ)
}
ageGroupQuery <- function(ageName, ageGroup, missingAgeGroupValue) {
  ageName <- paste0(".data[['", ageName, "']]")
  purrr::map_chr(ageGroup, \(ag) {
    xx <- purrr::imap_chr(ag, \(x, nm) {
      if (is.infinite(x[2])) {
        paste0(ageName, " >= ", x[1], "L ~ '", nm, "'")
      } else {
        paste0(
          ageName, " >= ", x[1], "L & ", ageName, "<= ", x[2], "L ~ '", nm, "'"
        )
      }
    })
    if (is.na(missingAgeGroupValue)) {
      xx <- c(xx, ".default = NA_character_")
    } else {
      xx <- c(xx, paste0('.default = "', missingAgeGroupValue, '"'))
    }
    xx <- paste0(xx, collapse = ", ")
    paste0("dplyr::case_when(", xx, ")")
  }) |>
    rlang::parse_exprs()
}

#' Query to add a new column to indicate if a certain record is within the
#' observation period
#'
#' @description
#' Same as `addInObservation()`, except query is not computed to a table.
#'
#' @inheritParams xDoc
#' @inheritParams indexDateDoc
#' @inheritParams windowDoc
#' @inheritParams completeIntervalDoc
#' @inheritParams nameStyleDoc
#' @inheritParams typeDoc
#'
#' @return Cohort table with an added column assessing observation. Values are
#' 1/`TRUE` in observation and 0/`FALSE` otherwise, according to `type`.
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort1 |>
#'   addInObservationQuery()
#'
#' }
#'
addInObservationQuery <- function(x,
                                  indexDate = "cohort_start_date",
                                  window = c(0, 0),
                                  completeInterval = FALSE,
                                  nameStyle = "in_observation",
                                  type = "numeric") {

  x |>
    .addInObservationQuery(
      indexDate = indexDate,
      window = window,
      completeInterval = completeInterval,
      nameStyle = nameStyle,
      type = type
    )
}

.addInObservationQuery <- function(x,
                                   indexDate = "cohort_start_date",
                                   window = c(0, 0),
                                   completeInterval = FALSE,
                                   nameStyle = "in_observation",
                                   type = "numeric",
                                   tmpName = NULL,
                                   call = parent.frame()) {
  type <- validateColumnType(type, "flag", call)

  x <- omopgenerics::validateCdmTable(table = x)
  originalColumns <- colnames(x)
  indexDateInput <- materialiseIndexDate(
    indexDate = indexDate, x = x, call = call
  )
  x <- indexDateInput$x
  indexDate <- indexDateInput$indexDate
  if (!is.list(window)) window <- list(window)
  window <- omopgenerics::validateWindowArgument(window, call = call)
  assertNameStyle(nameStyle = nameStyle, values = list("window_name" = window), call = call)
  newColumns <- glue::glue(nameStyle, window_name = names(window))
  overwriteCols <- newColumns[newColumns %in% colnames(x)]
  if (length(overwriteCols) > 0) {
    cli::cli_warn(c("!" = "{overwriteCols} column{?s} will be overwritten"))
    x <- x |>
      dplyr::select(!dplyr::all_of(overwriteCols))
  }

  cdm <- omopgenerics::cdmReference(x)
  personVariable <- c("person_id", "subject_id")
  personVariable <- personVariable[personVariable %in% colnames(x)]

  id <- uniqueColumnName(cols = c(personVariable, indexDate, newColumns), n = 4)
  start <- id[1]
  end <- id[2]
  startDif <- id[3]
  endDif <- id[4]

  xnew <- x |>
    dplyr::select(dplyr::all_of(c(personVariable, indexDate))) |>
    dplyr::distinct() |>
    dplyr::inner_join(
      cdm$observation_period |>
        dplyr::select(
          !!personVariable := "person_id",
          !!start := "observation_period_start_date",
          !!end := "observation_period_end_date"
        ),
      by = personVariable
    ) |>
    dplyr::filter(
      .data[[indexDate]] <= .data[[end]] & .data[[indexDate]] >= .data[[start]]
    ) |>
    dplyr::mutate(
      !!startDif := clock::date_count_between(start = .data[[indexDate]], end = .data[[start]], precision = "day"),
      !!endDif := clock::date_count_between(start = .data[[indexDate]], end = .data[[end]], precision = "day")
    )
  if(!is.null(tmpName)){
    xnew <- xnew |> dplyr::compute(name = tmpName, temporary = FALSE)
  }

  qR <- NULL
  for (k in seq_along(window)) {
    win <- window[[k]]
    window_name <- names(window)[k]
    nam <- glue::glue(nameStyle) |> as.character()

    if (all(win == c(0, 0))) {
      nQ <- "1"
    } else {
      lower <- win[1]
      upper <- win[2]

      if (completeInterval == TRUE) {
        if (is.infinite(lower) | is.infinite(upper)) {
          nQ <- "0"
        } else {
          nQ <- "dplyr::if_else(
            .data[['{startDif}']] <= {lower} & .data[['{endDif}']] >= {upper}, 1L, 0L
          )"
        }
      } else {
        if (is.infinite(lower)) {
          if (is.infinite(upper)) {
            nQ <- "1"
          } else {
            nQ <- "dplyr::if_else(.data[['{startDif}']] <= {upper}, 1L, 0L)"
          }
        } else {
          if (is.infinite(upper)) {
            nQ <- "dplyr::if_else({lower} <= .data[['{endDif}']], 1L, 0L)"
          } else {
            nQ <- "dplyr::if_else(
            {lower} <= .data[['{endDif}']] & .data[['{startDif}']] <= {upper}, 1L, 0L
            )"
          }
        }
      }
    }
    nQ <- paste0(nQ) |>
      glue::glue() |>
      rlang::parse_exprs() |>
      rlang::set_names(nam)
    qR <- c(qR, nQ)
  }

  x <- x |>
    dplyr::left_join(
      xnew |> dplyr::mutate(!!!qR) |> dplyr::select(!dplyr::all_of(id)),
      by = c(personVariable, indexDate)
    ) |>
    dplyr::mutate(dplyr::across(
      dplyr::all_of(newColumns), ~ dplyr::coalesce(as.integer(.x), 0L)
    ))

  x <- removeMaterialisedIndexDate(x, indexDateInput)

  x <- .convertColumnType(
    x = x,
    columns = newColumns,
    type = type
  ) |>
    dplyr::select(dplyr::all_of(c(originalColumns, newColumns)))

  return(x)
}
