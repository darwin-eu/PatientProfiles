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

#' Add the first or last cohort event and its relative days
#'
#' `addCohortEventDays()` finds the first or last event in each window.
#' When no event is observed before the applicable boundary, the event is
#' reported as `"end_of_observation"` if the observation period boundary is
#' reached or `"censor"` if the window boundary or `censorDate` is reached. The
#' days value represents that boundary.
#'
#' @inheritParams xDoc
#' @inheritParams targetCohortTableDoc
#' @inheritParams targetCohortIdDoc
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
#'   addCohortEventDays(targetCohortTable = "cohort2")
#' }
#'
addCohortEventDays <- function(x,
                               targetCohortTable,
                               targetCohortId = NULL,
                               indexDate = "cohort_start_date",
                               censorDate = NULL,
                               targetDate = "cohort_start_date",
                               order = "first",
                               window = c(0, Inf),
                               multipleEvents = NULL,
                               nameStyle = "{value}_{window_name}",
                               name = NULL,
                               type = "numeric") {
  .addCohortEvent(
    x = x,
    targetCohortTable = targetCohortTable,
    targetCohortId = {{ targetCohortId }},
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

#' Add the first or last cohort event and its date
#'
#' `addCohortEventDate()` finds the first or last event in each window.
#' When no event is observed before the applicable boundary, the event is
#' reported as `"end_of_observation"` if the observation period boundary is
#' reached or `"censor"` if the window boundary or `censorDate` is reached. The
#' date value represents that boundary.
#'
#' @inheritParams xDoc
#' @inheritParams targetCohortTableDoc
#' @inheritParams targetCohortIdDoc
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
#'   addCohortEventDate(targetCohortTable = "cohort2")
#' }
#'
addCohortEventDate <- function(x,
                               targetCohortTable,
                               targetCohortId = NULL,
                               indexDate = "cohort_start_date",
                               censorDate = NULL,
                               targetDate = "cohort_start_date",
                               order = "first",
                               window = c(0, Inf),
                               multipleEvents = NULL,
                               nameStyle = "{value}_{window_name}",
                               name = NULL) {
  .addCohortEvent(
    x = x,
    targetCohortTable = targetCohortTable,
    targetCohortId = {{ targetCohortId }},
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
.addCohortEvent <- function(x,
                            targetCohortTable,
                            targetCohortId,
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
  type <- validateColumnType(type, output)

  cdm <- omopgenerics::cdmReference(x)
  omopgenerics::assertCharacter(
    targetCohortTable,
    length = 1, na = FALSE, call = call
  )
  omopgenerics::validateCdmArgument(
    cdm = cdm, requiredTables = targetCohortTable, call = call
  )
  parameters <- checkCohortNames(
    cdm[[targetCohortTable]], {{ targetCohortId }}, targetCohortTable
  )

  .addEvent(
    x = x,
    tableName = targetCohortTable,
    filterVariable = parameters$filter_variable,
    filterId = parameters$filter_id,
    idName = parameters$id_name,
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
}
