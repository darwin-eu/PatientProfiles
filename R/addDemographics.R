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

#' Compute demographic characteristics at a certain date
#'
#' @inheritParams xDoc
#' @inheritParams indexDateDoc
#' @inheritParams ageDoc
#' @inheritParams ageMissingMonthDoc
#' @inheritParams ageNameDoc
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
#' @inheritParams nameDoc
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
#'   addDemographics()
#'
#' cdm$cohort1 |>
#'   addDemographics(indexDate = as.Date("2010-01-01"))
#'
#' }
#'
addDemographics <- function(x,
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
                            name = NULL,
                            type = "numeric") {

  name <- validateName(name)
  cdm <- omopgenerics::cdmReference(x)
  tmpName <- omopgenerics::uniqueTableName()

  x <- x |>
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
      type = type,
      tmpName = tmpName
    ) |>
    computeTable(name = name)

  omopgenerics::dropSourceTable(cdm = cdm, name = tmpName)

  x
}

#' Compute the age of the individuals at a certain date
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
#' @inheritParams nameDoc
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
#'   addAge()
#'
#' }
addAge <- function(x,
                   indexDate = "cohort_start_date",
                   ageName = "age",
                   ageGroup = NULL,
                   ageMissingMonth = 1,
                   ageMissingDay = 1,
                   ageImposeMonth = FALSE,
                   ageImposeDay = FALSE,
                   ageUnit = "years",
                   missingAgeGroupValue = "None",
                   name = NULL,
                   type = "numeric") {
  name <- validateName(name)
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
    ) |>
    computeTable(name = name)

}

#' Compute the number of days till the end of the observation period at a
#' certain date
#'
#' @inheritParams xDoc
#' @inheritParams indexDateDoc
#' @inheritParams futureObservationNameDoc
#' @inheritParams futureObservationTypeDoc
#' @inheritParams nameDoc
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
#'   addFutureObservation()
#'
#' }
addFutureObservation <- function(x,
                                 indexDate = "cohort_start_date",
                                 futureObservationName = "future_observation",
                                 futureObservationType = "days",
                                 name = NULL,
                                 type = "numeric") {

  name <- validateName(name)
  cdm <- omopgenerics::cdmReference(x)
  tmpName <- omopgenerics::uniqueTableName()

  x <- x |>
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
      type = type,
      tmpName = tmpName
    ) |>
    computeTable(name = name)

  omopgenerics::dropSourceTable(cdm = cdm, name = tmpName)

  x
}

#' Compute the number of days of prior observation in the current observation period
#' at a certain date
#'
#' @inheritParams xDoc
#' @inheritParams indexDateDoc
#' @inheritParams priorObservationNameDoc
#' @inheritParams priorObservationTypeDoc
#' @inheritParams nameDoc
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
#'   addPriorObservation()
#'
#' }
addPriorObservation <- function(x,
                                indexDate = "cohort_start_date",
                                priorObservationName = "prior_observation",
                                priorObservationType = "days",
                                name = NULL,
                                type = "numeric") {

  name <- validateName(name)
  cdm <- omopgenerics::cdmReference(x)
  tmpName <- omopgenerics::uniqueTableName()

  x <- x |>
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
      type = type,
      tmpName = tmpName
    ) |>
    computeTable(name = name)

  omopgenerics::dropSourceTable(cdm = cdm, name = tmpName)

  x
}

#' Indicate if a certain record is within the observation period
#'
#' @inheritParams xDoc
#' @inheritParams indexDateDoc
#' @inheritParams windowDoc
#' @inheritParams completeIntervalDoc
#' @inheritParams nameStyleDoc
#' @inheritParams nameDoc
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
#'   addInObservation()
#'
#' }
#'
addInObservation <- function(x,
                             indexDate = "cohort_start_date",
                             window = c(0, 0),
                             completeInterval = FALSE,
                             nameStyle = "in_observation",
                             name = NULL,
                             type = "numeric") {
  name <- validateName(name)

  cdm <- omopgenerics::cdmReference(x)
  tmpName <- omopgenerics::uniqueTableName()

  x <- x |>
    .addInObservationQuery(
      indexDate = indexDate,
      window = window,
      completeInterval = completeInterval,
      nameStyle = nameStyle,
      type = type,
      tmpName = tmpName
    ) |>
    computeTable(name = name)

  omopgenerics::dropSourceTable(cdm = cdm, name = tmpName)

  x
}

#' Compute the sex of the individuals
#'
#' @inheritParams xDoc
#' @inheritParams sexNameDoc
#' @inheritParams missingSexValueDoc
#' @inheritParams nameDoc
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
#'   addSex()
#'
#' }
#'
addSex <- function(x,
                   sexName = "sex",
                   missingSexValue = "None",
                   name = NULL) {
  name <- validateName(name)
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
    ) |>
    computeTable(name = name)
}

#' Add a column with the individual birth date
#'
#' @inheritParams xDoc
#' @inheritParams dateOfBirthNameDoc
#' @inheritParams nameDoc
#' @inheritParams missingMonthDoc
#' @inheritParams missingDayDoc
#' @inheritParams imposeMonthDoc
#' @inheritParams imposeDayDoc
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
#'   addDateOfBirth()
#'
#' }
addDateOfBirth <- function(x,
                           dateOfBirthName = "date_of_birth",
                           missingDay = 1,
                           missingMonth = 1,
                           imposeDay = FALSE,
                           imposeMonth = FALSE,
                           name = NULL) {
  name <- validateName(name)
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
    ) |>
    computeTable(name = name)
}
