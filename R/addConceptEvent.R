# Copyright 2026 DARWIN EU (C)
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

#' Add the first or last concept event and its relative days
#'
#' `addConceptEventDays()` finds the first or last event from a set of
#' concepts in each window. When no event is observed before the applicable
#' boundary, the event is reported as `"end_of_observation"` if the observation
#' period boundary is reached or `"censor"` if the window boundary or
#' `censorDate` is reached. The days value represents that boundary.
#'
#' @inheritParams xDoc
#' @inheritParams conceptSetDoc
#' @inheritParams indexDateDoc
#' @inheritParams censorDateDoc
#' @inheritParams targetDateDoc
#' @inheritParams orderDoc
#' @inheritParams windowDoc
#' @inheritParams multipleEventsDoc
#' @inheritParams nameStyleEventDoc
#' @inheritParams nameDoc
#' @inheritParams typeDoc
#'
#' @return `x` with an event column and a days column of the requested `type`,
#' relative to `indexDate`, for every window.
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort1 |>
#'   addConceptEventDays(conceptSet = list(acetaminophen = 1125315L))
#' }
#'
addConceptEventDays <- function(x,
                                conceptSet,
                                indexDate = "cohort_start_date",
                                censorDate = NULL,
                                targetDate = "event_start_date",
                                order = "first",
                                window = list(c(0, Inf)),
                                multipleEvents = NULL,
                                nameStyle = "{value}_{window_name}",
                                name = NULL,
                                type = "numeric") {
  .addConceptEvent(
    x = x,
    conceptSet = conceptSet,
    indexDate = indexDate,
    censorDate = censorDate,
    targetDate = targetDate,
    order = order,
    window = window,
    multipleEvents = multipleEvents,
    output = "days",
    nameStyle = nameStyle,
    name = name,
    type = type,
    call = parent.frame()
  )
}

#' Add the first or last concept event and its date
#'
#' `addConceptEventDate()` finds the first or last event from a set of
#' concepts in each window. When no event is observed before the applicable
#' boundary, the event is reported as `"end_of_observation"` if the observation
#' period boundary is reached or `"censor"` if the window boundary or
#' `censorDate` is reached. The date value represents that boundary.
#'
#' @inheritParams xDoc
#' @inheritParams conceptSetDoc
#' @inheritParams indexDateDoc
#' @inheritParams censorDateDoc
#' @inheritParams targetDateDoc
#' @inheritParams orderDoc
#' @inheritParams windowDoc
#' @inheritParams multipleEventsDoc
#' @inheritParams nameStyleEventDoc
#' @inheritParams nameDoc
#'
#' @return `x` with an event column and a date column for every window.
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' cdm$cohort1 |>
#'   addConceptEventDate(conceptSet = list(acetaminophen = 1125315L))
#' }
#'
addConceptEventDate <- function(x,
                                conceptSet,
                                indexDate = "cohort_start_date",
                                censorDate = NULL,
                                targetDate = "event_start_date",
                                order = "first",
                                window = list(c(0, Inf)),
                                multipleEvents = NULL,
                                nameStyle = "{value}_{window_name}",
                                name = NULL) {
  .addConceptEvent(
    x = x,
    conceptSet = conceptSet,
    indexDate = indexDate,
    censorDate = censorDate,
    targetDate = targetDate,
    order = order,
    window = window,
    multipleEvents = multipleEvents,
    output = "date",
    nameStyle = nameStyle,
    name = name,
    call = parent.frame()
  )
}

#' @noRd
.addConceptEvent <- function(x,
                             conceptSet,
                             indexDate,
                             censorDate,
                             targetDate,
                             order,
                             window,
                             multipleEvents,
                             output,
                             nameStyle,
                             name,
                             type = "auto",
                             call = parent.frame()) {
  type <- validateColumnType(type, output, call)

  cdm <- omopgenerics::cdmReference(x)
  conceptSet <- omopgenerics::validateConceptSetArgument(
    conceptSet = conceptSet, cdm = cdm, call = call
  )
  omopgenerics::assertChoice(
    targetDate,
    choices = c("event_start_date", "event_end_date"),
    length = 1,
    call = call
  )
  originalNames <- names(conceptSet)
  conceptSet <- validateConceptNames(conceptSet)
  if (!is.null(multipleEvents) &&
    all(multipleEvents %in% originalNames)) {
    multipleEvents <- names(conceptSet)[match(multipleEvents, originalNames)]
  }

  tablePrefix <- omopgenerics::tmpPrefix()
  conceptsName <- omopgenerics::uniqueTableName(tablePrefix)
  cdm <- omopgenerics::insertTable(
    cdm = cdm,
    name = conceptsName,
    table = getConceptsTable(conceptSet),
    overwrite = TRUE
  )
  cdm[[conceptsName]] <- subsetTable(cdm[[conceptsName]], value = "days") |>
    dplyr::compute(name = conceptsName, temporary = FALSE)
  attr(x, "cdm_reference") <- cdm

  conceptSetId <- conceptSetId(conceptSet)
  x <- .addEvent(
    x = x,
    tableName = conceptsName,
    filterVariable = "concept_set_id",
    filterId = conceptSetId$concept_set_id,
    idName = conceptSetId$concept_set_name,
    indexDate = indexDate,
    censorDate = censorDate,
    targetDate = targetDate,
    order = order,
    window = window,
    multipleEvents = multipleEvents,
    output = output,
    nameStyle = nameStyle,
    name = name,
    type = type,
    call = call
  )

  omopgenerics::dropSourceTable(
    cdm = cdm, name = dplyr::starts_with(tablePrefix)
  )
  x
}
