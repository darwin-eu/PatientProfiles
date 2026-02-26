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
#' @param x Table with individuals in the cdm.
#' @param indexDate Variable in x that contains the date to compute the
#' demographics characteristics.
#' @param age TRUE or FALSE. If TRUE, age will be calculated relative to
#' indexDate.
#' @param ageMissingMonth Month of the year assigned to individuals with missing
#' month of birth.
#' @param ageName Age variable name.
#' @param ageMissingDay day of the month assigned to individuals
#' with missing day of birth.
#' @param ageImposeMonth TRUE or FALSE. Whether the month of the date of birth
#' will be considered as missing for all the individuals.
#' @param ageImposeDay TRUE or FALSE. Whether the day of the date of birth
#' will be considered as missing for all the individuals.
#' @param ageUnit Unit for age it can either be 'years', 'months' or 'days'.
#' @param ageGroup if not NULL, a list of ageGroup vectors.
#' @param missingAgeGroupValue Value to include if missing age.
#' @param sex TRUE or FALSE. If TRUE, sex will be identified.
#' @param sexName Sex variable name.
#' @param missingSexValue Value to include if missing sex.
#' @param priorObservation TRUE or FALSE. If TRUE, days of between the start
#' of the current observation period and the indexDate will be calculated.
#' @param priorObservationName Prior observation variable name.
#' @param priorObservationType Whether to return a "date" or the number of
#' "days".
#' @param futureObservation TRUE or FALSE. If TRUE, days between the
#' indexDate and the end of the current observation period will be
#' calculated.
#' @param futureObservationName Future observation variable name.
#' @param futureObservationType Whether to return a "date" or the number of
#' "days".
#' @param dateOfBirth TRUE or FALSE, if true the date of birth will be return.
#' @param dateOfBirthName dateOfBirth column name.
#' @param name Name of the new table, if NULL a temporary table is returned.
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
                            name = NULL) {

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
      tmpName = tmpName
    ) |>
    computeTable(name = name)

  omopgenerics::dropSourceTable(cdm = cdm, name = tmpName)

  x
}

#' Compute the age of the individuals at a certain date
#'
#' @inheritParams addDemographics
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
                   name = NULL) {
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
      dateOfBirthName = NULL
    ) |>
    computeTable(name = name)

}

#' Compute the number of days till the end of the observation period at a
#' certain date
#'
#' @inheritParams addDemographics
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
                                 name = NULL) {

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
      tmpName = tmpName
    ) |>
    computeTable(name = name)

  omopgenerics::dropSourceTable(cdm = cdm, name = tmpName)

  x
}

#' Compute the number of days of prior observation in the current observation period
#' at a certain date
#'
#' @inheritParams addDemographics
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
                                name = NULL) {

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
      tmpName = tmpName
    ) |>
    computeTable(name = name)

  omopgenerics::dropSourceTable(cdm = cdm, name = tmpName)

  x
}

#' Indicate if a certain record is within the observation period
#'
#' @param x Table with individuals in the cdm.
#' @param indexDate Variable in x that contains the date to compute the
#' observation flag.
#' @param window window to consider events of.
#' @param completeInterval If the individuals are in observation for the full window.
#' @param nameStyle Name of the new columns to create, it must contain
#' "window_name" if multiple windows are provided.
#' @param name Name of the new table, if NULL a temporary table is returned.
#'
#' @return cohort table with the added numeric column assessing observation (1
#' in observation, 0 not in observation).
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
                             name = NULL) {
  name <- validateName(name)

  cdm <- omopgenerics::cdmReference(x)
  tmpName <- omopgenerics::uniqueTableName()

  x <- x |>
    .addInObservationQuery(
      indexDate = indexDate,
      window = window,
      completeInterval = completeInterval,
      nameStyle = nameStyle,
      tmpName = tmpName
    ) |>
    computeTable(name = name)

  omopgenerics::dropSourceTable(cdm = cdm, name = tmpName)

  x
}

#' Compute the sex of the individuals
#'
#' @inheritParams addDemographics
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
#' @inheritParams addDemographics
#' @param missingMonth Month of the year assigned to individuals with missing
#' month of birth.
#' @param missingDay day of the month assigned to individuals
#' with missing day of birth.
#' @param imposeMonth TRUE or FALSE. Whether the month of the date of birth
#' will be considered as missing for all the individuals.
#' @param imposeDay TRUE or FALSE. Whether the day of the date of birth
#' will be considered as missing for all the individuals.
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
