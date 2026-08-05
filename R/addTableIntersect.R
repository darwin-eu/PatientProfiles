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

.addTableIntersect <- function(x,
                               tableName,
                               value,
                               indexDate,
                               censorDate,
                               window,
                               targetStartDate,
                               targetEndDate,
                               inObservation,
                               order,
                               allowDuplicates = FALSE,
                               nameStyle,
                               name,
                               type = "auto") {
  type <- validateColumnType(type, value)

  cdm <- omopgenerics::cdmReference(x)
  omopgenerics::assertCharacter(tableName)
  omopgenerics::validateCdmArgument(cdm = cdm, requiredTables = tableName)
  omopgenerics::assertCharacter(nameStyle, length = 1)

  if (length(tableName) > 1 &&
      !grepl("{table_name}", nameStyle, fixed = TRUE)) {
    cli::cli_abort(
      "If more than one `tableName` is provided, `nameStyle` must include `{{table_name}}`."
    )
  }

  recycleArgument <- function(argument, argumentName) {
    if (is.null(argument)) {
      return(rep(list(NULL), length(tableName)))
    }
    if (length(argument) == 1) {
      return(rep(as.list(argument), length(tableName)))
    }
    if (length(argument) != length(tableName)) {
      cli::cli_abort(
        "`{argumentName}` must have length 1 or the same length as `tableName`."
      )
    }
    as.list(argument)
  }

  value <- recycleArgument(value, "value")
  targetStartDate <- recycleArgument(targetStartDate, "targetStartDate")
  targetEndDate <- recycleArgument(targetEndDate, "targetEndDate")

  for (i in seq_along(tableName)) {
    x <- .addIntersect(
      x = x,
      tableName = tableName[[i]],
      filterVariable = NULL,
      filterId = NULL,
      idName = NULL,
      value = value[[i]],
      indexDate = indexDate,
      targetStartDate = targetStartDate[[i]],
      targetEndDate = targetEndDate[[i]],
      inObservation = inObservation,
      window = window,
      order = order,
      allowDuplicates = allowDuplicates,
      nameStyle = gsub("\\{table_name\\}", tableName[[i]], nameStyle),
      censorDate = censorDate,
      name = if (i == length(tableName)) name else NULL,
      type = type
    )
  }

  x
}

#' Compute a flag intersect with an omop table
#'
#' @inheritParams xDoc
#' @inheritParams tableNameDoc
#' @inheritParams indexDateDoc
#' @inheritParams censorDateDoc
#' @inheritParams windowDoc
#' @inheritParams targetStartDateDoc
#' @inheritParams targetEndDateDoc
#' @inheritParams inObservationDoc
#' @inheritParams nameStyleDoc
#' @inheritParams nameDoc
#' @inheritParams typeDoc
#'
#' @returns `r documentationIntersect("flag", "table")`
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
#'   addTableIntersectFlag(tableName = "visit_occurrence")
#'
#' }
#'
addTableIntersectFlag <- function(x,
                                  tableName,
                                  indexDate = "cohort_start_date",
                                  censorDate = NULL,
                                  window = list(c(0, Inf)),
                                  targetStartDate = startDateColumn(tableName),
                                  targetEndDate = endDateColumn(tableName),
                                  inObservation = TRUE,
                                  nameStyle = "{table_name}_{window_name}",
                                  name = NULL,
                                  type = "numeric") {
  omopgenerics::assertCharacter(tableName)
  if (missing(targetStartDate)) {
    targetStartDate <- vapply(tableName, startDateColumn, character(1))
  }
  if (missing(targetEndDate)) {
    targetEndDate <- vapply(tableName, endDateColumn, character(1))
  }

  .addTableIntersect(
    x = x, tableName = tableName, value = "flag", indexDate = indexDate,
    censorDate = censorDate, window = window,
    targetStartDate = targetStartDate, targetEndDate = targetEndDate,
    inObservation = inObservation, order = "first", nameStyle = nameStyle,
    name = name, type = type
  )
}

#' Compute number of intersect with an omop table.
#'
#' @inheritParams xDoc
#' @inheritParams tableNameDoc
#' @inheritParams indexDateDoc
#' @inheritParams censorDateDoc
#' @inheritParams windowDoc
#' @inheritParams targetStartDateDoc
#' @inheritParams targetEndDateDoc
#' @inheritParams inObservationDoc
#' @inheritParams nameStyleDoc
#' @inheritParams nameDoc
#' @inheritParams typeDoc
#'
#' @returns `r documentationIntersect("count", "table")`
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
#'   addTableIntersectCount(tableName = "visit_occurrence")
#'
#' }
#'
addTableIntersectCount <- function(x,
                                   tableName,
                                   indexDate = "cohort_start_date",
                                   censorDate = NULL,
                                   window = list(c(0, Inf)),
                                   targetStartDate = startDateColumn(tableName),
                                   targetEndDate = endDateColumn(tableName),
                                   inObservation = TRUE,
                                   nameStyle = "{table_name}_{window_name}",
                                   name = NULL,
                                   type = "numeric") {
  omopgenerics::assertCharacter(tableName)
  if (missing(targetStartDate)) {
    targetStartDate <- vapply(tableName, startDateColumn, character(1))
  }
  if (missing(targetEndDate)) {
    targetEndDate <- vapply(tableName, endDateColumn, character(1))
  }

  .addTableIntersect(
    x = x, tableName = tableName, value = "count", indexDate = indexDate,
    censorDate = censorDate, window = window,
    targetStartDate = targetStartDate, targetEndDate = targetEndDate,
    inObservation = inObservation, order = "first", nameStyle = nameStyle,
    name = name, type = type
  )
}

#' Compute date of intersect with an omop table.
#'
#' @inheritParams xDoc
#' @inheritParams tableNameDoc
#' @inheritParams indexDateDoc
#' @inheritParams censorDateDoc
#' @inheritParams windowDoc
#' @inheritParams targetDateDoc
#' @inheritParams inObservationDoc
#' @inheritParams orderDoc
#' @inheritParams nameStyleDoc
#' @inheritParams nameDoc
#'
#' @return table with added columns with intersect information.
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort1 |>
#'   addTableIntersectDate(tableName = "visit_occurrence")
#'
#' }
#'
addTableIntersectDate <- function(x,
                                  tableName,
                                  indexDate = "cohort_start_date",
                                  censorDate = NULL,
                                  window = list(c(0, Inf)),
                                  targetDate = startDateColumn(tableName),
                                  inObservation = TRUE,
                                  order = "first",
                                  nameStyle = "{table_name}_{window_name}",
                                  name = NULL) {
  omopgenerics::assertCharacter(tableName)
  if (missing(targetDate)) {
    targetDate <- vapply(tableName, startDateColumn, character(1))
  }

  if (missing(order) & rlang::is_interactive()) {
    messageOrder(order)
  }

  .addTableIntersect(
    x = x, tableName = tableName, value = "date", indexDate = indexDate,
    censorDate = censorDate, window = window,
    targetStartDate = targetDate, targetEndDate = NULL,
    inObservation = inObservation, order = order, nameStyle = nameStyle,
    name = name
  )
}

#' Compute time to intersect with an omop table.
#'
#' @inheritParams xDoc
#' @inheritParams tableNameDoc
#' @inheritParams indexDateDoc
#' @inheritParams censorDateDoc
#' @inheritParams windowDoc
#' @inheritParams targetDateDoc
#' @inheritParams inObservationDoc
#' @inheritParams orderDoc
#' @inheritParams nameStyleDoc
#' @inheritParams nameDoc
#' @inheritParams typeDoc
#'
#' @return table with added columns with intersect information.
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort1 |>
#'   addTableIntersectDays(tableName = "visit_occurrence")
#'
#' }
#'
addTableIntersectDays <- function(x,
                                  tableName,
                                  indexDate = "cohort_start_date",
                                  censorDate = NULL,
                                  window = list(c(0, Inf)),
                                  targetDate = startDateColumn(tableName),
                                  inObservation = TRUE,
                                  order = "first",
                                  nameStyle = "{table_name}_{window_name}",
                                  name = NULL,
                                  type = "numeric") {
  omopgenerics::assertCharacter(tableName)
  if (missing(targetDate)) {
    targetDate <- vapply(tableName, startDateColumn, character(1))
  }

  if (missing(order) & rlang::is_interactive()) {
    messageOrder(order)
  }

  .addTableIntersect(
    x = x, tableName = tableName, value = "days", indexDate = indexDate,
    censorDate = censorDate, window = window,
    targetStartDate = targetDate, targetEndDate = NULL,
    inObservation = inObservation, order = order, nameStyle = nameStyle,
    name = name, type = type
  )
}

#' Intersecting the cohort with columns of an OMOP table of user's choice.
#' It will add an extra column to the cohort, indicating the intersected
#' entries with the target columns in a window of the user's choice.
#'
#' @inheritParams xDoc
#' @inheritParams tableNameDoc
#' @inheritParams fieldDoc
#' @inheritParams indexDateDoc
#' @inheritParams censorDateDoc
#' @inheritParams windowDoc
#' @inheritParams targetDateDoc
#' @inheritParams inObservationDoc
#' @inheritParams orderDoc
#' @inheritParams allowDuplicatesDoc
#' @inheritParams nameStyleDoc
#' @inheritParams nameDoc
#' @inheritParams typeDoc
#'
#' @return table with added columns with intersect information.
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort1 |>
#'   addTableIntersectField(
#'     tableName = "visit_occurrence",
#'     field = "visit_concept_id",
#'     order = "last",
#'     window = c(-Inf, -1)
#'   )
#'
#' }
#'
addTableIntersectField <- function(x,
                                   tableName,
                                   field,
                                   indexDate = "cohort_start_date",
                                   censorDate = NULL,
                                   window = list(c(0, Inf)),
                                   targetDate = startDateColumn(tableName),
                                   inObservation = TRUE,
                                   order = "first",
                                   allowDuplicates = FALSE,
                                   nameStyle = "{table_name}_{field}_{window_name}",
                                   name = NULL,
                                   type = "auto") {
  omopgenerics::assertCharacter(tableName)
  if (missing(targetDate)) {
    targetDate <- vapply(tableName, startDateColumn, character(1))
  }
  nameStyle <- gsub("\\{field\\}", "\\{value\\}", nameStyle)

  if (missing(order) & rlang::is_interactive()) {
    messageOrder(order)
  }

  .addTableIntersect(
    x = x, tableName = tableName, value = field, indexDate = indexDate,
    censorDate = censorDate, window = window,
    targetStartDate = targetDate, targetEndDate = NULL,
    inObservation = inObservation, order = order,
    allowDuplicates = allowDuplicates, nameStyle = nameStyle, name = name,
    type = type
  )
}
