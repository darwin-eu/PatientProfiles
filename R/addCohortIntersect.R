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

#' It creates columns to indicate the presence of cohorts
#'
#' @inheritParams xDoc
#' @inheritParams targetCohortTableDoc
#' @inheritParams targetCohortIdDoc
#' @inheritParams indexDateDoc
#' @inheritParams censorDateDoc
#' @inheritParams targetStartDateDoc
#' @inheritParams targetEndDateDoc
#' @inheritParams windowDoc
#' @inheritParams nameStyleDoc
#' @inheritParams nameDoc
#' @inheritParams typeDoc
#'
#' @returns `r documentationIntersect("flag", "cohort")`
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
#'   addCohortIntersectFlag(
#'     targetCohortTable = "cohort2"
#'   )
#'
#' }
#'
addCohortIntersectFlag <- function(x,
                                   targetCohortTable,
                                   targetCohortId = NULL,
                                   indexDate = "cohort_start_date",
                                   censorDate = NULL,
                                   targetStartDate = "cohort_start_date",
                                   targetEndDate = "cohort_end_date",
                                   window = list(c(0, Inf)),
                                   nameStyle = "{cohort_name}_{window_name}",
                                   name = NULL,
                                   type = "numeric") {
  cdm <- omopgenerics::cdmReference(x)
  omopgenerics::assertCharacter(targetCohortTable)
  omopgenerics::validateCdmArgument(cdm = cdm, requiredTables = targetCohortTable)
  parameters <- checkCohortNames(cdm[[targetCohortTable]], {{targetCohortId}}, targetCohortTable)
  nameStyle <- gsub("\\{cohort_name\\}", "\\{id_name\\}", nameStyle)

  x <- x |>
    .addIntersect(
      tableName = targetCohortTable,
      filterVariable = parameters$filter_variable,
      filterId = parameters$filter_id,
      idName = parameters$id_name,
      value = "flag",
      indexDate = indexDate,
      targetStartDate = targetStartDate,
      targetEndDate = targetEndDate,
      window = window,
      nameStyle = nameStyle,
      censorDate = censorDate,
      name = name,
      type = type
    )

  return(x)
}

#' It creates columns to indicate number of occurrences of intersection with a
#' cohort
#'
#' @inheritParams xDoc
#' @inheritParams targetCohortTableDoc
#' @inheritParams targetCohortIdDoc
#' @inheritParams indexDateDoc
#' @inheritParams censorDateDoc
#' @inheritParams targetStartDateDoc
#' @inheritParams targetEndDateDoc
#' @inheritParams windowDoc
#' @inheritParams nameStyleDoc
#' @inheritParams nameDoc
#' @inheritParams typeDoc
#'
#' @returns `r documentationIntersect("count", "cohort")`
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
#'   addCohortIntersectCount(
#'     targetCohortTable = "cohort2"
#'   )
#'
#' }
#'
addCohortIntersectCount <- function(x,
                                    targetCohortTable,
                                    targetCohortId = NULL,
                                    indexDate = "cohort_start_date",
                                    censorDate = NULL,
                                    targetStartDate = "cohort_start_date",
                                    targetEndDate = "cohort_end_date",
                                    window = list(c(0, Inf)),
                                    nameStyle = "{cohort_name}_{window_name}",
                                    name = NULL,
                                    type = "numeric") {
  cdm <- omopgenerics::cdmReference(x)
  omopgenerics::assertCharacter(targetCohortTable)
  omopgenerics::validateCdmArgument(cdm = cdm, requiredTables = targetCohortTable)
  parameters <- checkCohortNames(cdm[[targetCohortTable]], {{targetCohortId}}, targetCohortTable)
  nameStyle <- gsub("\\{cohort_name\\}", "\\{id_name\\}", nameStyle)

  x <- x |>
    .addIntersect(
      tableName = targetCohortTable,
      filterVariable = parameters$filter_variable,
      filterId = parameters$filter_id,
      idName = parameters$id_name,
      value = "count",
      indexDate = indexDate,
      targetStartDate = targetStartDate,
      targetEndDate = targetEndDate,
      window = window,
      nameStyle = nameStyle,
      censorDate = censorDate,
      name = name,
      type = type
    )

  return(x)
}

#' It creates columns to indicate the number of days between the current table
#' and a target cohort
#'
#' @inheritParams xDoc
#' @inheritParams targetCohortTableDoc
#' @inheritParams targetCohortIdDoc
#' @inheritParams indexDateDoc
#' @inheritParams censorDateDoc
#' @inheritParams targetDateDoc
#' @inheritParams orderDoc
#' @inheritParams windowDoc
#' @inheritParams nameStyleDoc
#' @inheritParams nameDoc
#' @inheritParams typeDoc
#'
#' @return x along with additional columns for each cohort of interest.
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort1 |>
#'   addCohortIntersectDays(targetCohortTable = "cohort2")
#'
#' }
#'
addCohortIntersectDays <- function(x,
                                   targetCohortTable,
                                   targetCohortId = NULL,
                                   indexDate = "cohort_start_date",
                                   censorDate = NULL,
                                   targetDate = "cohort_start_date",
                                   order = "first",
                                   window = c(0, Inf),
                                   nameStyle = "{cohort_name}_{window_name}",
                                   name = NULL,
                                   type = "numeric") {
  cdm <- omopgenerics::cdmReference(x)
  omopgenerics::assertCharacter(targetCohortTable)
  omopgenerics::validateCdmArgument(cdm = cdm, requiredTables = targetCohortTable)
  parameters <- checkCohortNames(cdm[[targetCohortTable]], {{targetCohortId}}, targetCohortTable)
  nameStyle <- gsub("\\{cohort_name\\}", "\\{id_name\\}", nameStyle)

  if (missing(order) & rlang::is_interactive()) {
    messageOrder(order)
  }

  x <- x |>
    .addIntersect(
      tableName = targetCohortTable,
      indexDate = indexDate,
      value = "days",
      filterVariable = parameters$filter_variable,
      filterId = parameters$filter_id,
      idName = parameters$id_name,
      window = window,
      targetStartDate = targetDate,
      targetEndDate = NULL,
      order = order,
      nameStyle = nameStyle,
      censorDate = censorDate,
      name = name,
      type = type
    )

  return(x)
}


#' Date of cohorts that are present in a certain window
#'
#' @inheritParams xDoc
#' @inheritParams targetCohortTableDoc
#' @inheritParams targetCohortIdDoc
#' @inheritParams indexDateDoc
#' @inheritParams censorDateDoc
#' @inheritParams targetDateDoc
#' @inheritParams orderDoc
#' @inheritParams windowDoc
#' @inheritParams nameStyleDoc
#' @inheritParams nameDoc
#'
#' @return x along with additional columns for each cohort of interest.
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort1 |>
#'   addCohortIntersectDate(targetCohortTable = "cohort2")
#'
#' }
#'
addCohortIntersectDate <- function(x,
                                   targetCohortTable,
                                   targetCohortId = NULL,
                                   indexDate = "cohort_start_date",
                                   censorDate = NULL,
                                   targetDate = "cohort_start_date",
                                   order = "first",
                                   window = c(0, Inf),
                                   nameStyle = "{cohort_name}_{window_name}",
                                   name = NULL) {
  cdm <- omopgenerics::cdmReference(x)
  omopgenerics::assertCharacter(targetCohortTable)
  omopgenerics::validateCdmArgument(cdm = cdm, requiredTables = targetCohortTable)
  parameters <- checkCohortNames(cdm[[targetCohortTable]], {{targetCohortId}}, targetCohortTable)
  nameStyle <- gsub("\\{cohort_name\\}", "\\{id_name\\}", nameStyle)

  if (missing(order) & rlang::is_interactive()) {
    messageOrder(order)
  }

  x <- x |>
    .addIntersect(
      tableName = targetCohortTable,
      indexDate = indexDate,
      value = "date",
      filterVariable = parameters$filter_variable,
      filterId = parameters$filter_id,
      idName = parameters$id_name,
      window = window,
      targetStartDate = targetDate,
      targetEndDate = NULL,
      order = order,
      nameStyle = nameStyle,
      censorDate = censorDate,
      name = name
    )

  return(x)
}

#' It creates a column with the field of a desired intersection
#'
#' @inheritParams xDoc
#' @inheritParams targetCohortTableDoc
#' @inheritParams fieldDoc
#' @inheritParams targetCohortIdDoc
#' @inheritParams indexDateDoc
#' @inheritParams censorDateDoc
#' @inheritParams targetDateDoc
#' @inheritParams orderDoc
#' @inheritParams windowDoc
#' @inheritParams nameStyleDoc
#' @inheritParams nameDoc
#' @inheritParams typeDoc
#'
#' @return table with added columns with overlap information.
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#' library(dplyr)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort2 <- cdm$cohort2 |>
#'   mutate(even = if_else(subject_id %% 2, "yes", "no")) |>
#'   compute(name = "cohort2")
#'
#' cdm$cohort1 |>
#'   addCohortIntersectFlag(
#'     targetCohortTable = "cohort2"
#'   )
#'
#' }
#'
addCohortIntersectField <- function(x,
                                    targetCohortTable,
                                    field,
                                    targetCohortId = NULL,
                                    indexDate = "cohort_start_date",
                                    censorDate = NULL,
                                    targetDate = "cohort_start_date",
                                    order = "first",
                                    window = list(c(0, Inf)),
                                    nameStyle = "{cohort_name}_{field}_{window_name}",
                                    name = NULL,
                                    type = "auto") {
  cdm <- omopgenerics::cdmReference(x)
  omopgenerics::assertCharacter(targetCohortTable)
  omopgenerics::validateCdmArgument(cdm = cdm, requiredTables = targetCohortTable)
  parameters <- checkCohortNames(cdm[[targetCohortTable]], {{targetCohortId}}, targetCohortTable)
  nameStyle <- gsub("\\{cohort_name\\}", "\\{id_name\\}", nameStyle)
  nameStyle <- gsub("\\{field\\}", "\\{value\\}", nameStyle)

  if (missing(order) & rlang::is_interactive()) {
    messageOrder(order)
  }

  x <- x |>
    .addIntersect(
      tableName = targetCohortTable,
      filterVariable = parameters$filter_variable,
      filterId = parameters$filter_id,
      idName = parameters$id_name,
      value = field,
      indexDate = indexDate,
      targetStartDate = targetDate,
      targetEndDate = NULL,
      window = window,
      order = order,
      nameStyle = nameStyle,
      censorDate = censorDate,
      name = name,
      type = type
    )

  return(x)
}
