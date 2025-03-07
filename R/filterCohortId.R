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

#' Filter a cohort according to cohort_definition_id column, the result is not
#' computed into a table. only a query is added. Used usually as internal
#' functions of other packages.
#'
#' @param cohort A `cohort_table` object.
#' @param cohortId A vector with cohort ids.
#'
#' @return A `cohort_table` object.
#'
#' @export
#'
filterCohortId <- function(cohort,
                           cohortId = NULL) {
  # initial checks
  cohortId <- omopgenerics::validateCohortIdArgument(
    cohortId = cohortId, cohort = cohort
  )

  populatedIds <- omopgenerics::cohortCount(cohort) |>
    dplyr::filter(.data$number_records > 0) |>
    dplyr::pull("cohort_definition_id")
  if (!all(populatedIds %in% cohortId)) {
    cohort <- cohort |>
      dplyr::filter(.data$cohort_definition_id %in% .env$cohortId)
  }

  return(cohort)
}
