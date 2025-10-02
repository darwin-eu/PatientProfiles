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

#' Add cohort name for each cohort_definition_id
#'
#' @param cohort cohort to which add the cohort name
#'
#' @return cohort with an extra column with the cohort names
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#' cdm$cohort1 |>
#'   addCohortName()
#' }
#'
addCohortName <- function(cohort) {
  omopgenerics::assertClass(cohort, class = "cohort_table")

  if ("cohort_name" %in% colnames(cohort)) {
    cli::cli_inform(c("!" = "`cohort_name` will be overwrite"))
    cohort <- cohort |> dplyr::select(!"cohort_name")
  }
  cohort |>
    dplyr::left_join(
      attr(cohort, "cohort_set") |>
        dplyr::select("cohort_definition_id", "cohort_name"),
      by = "cohort_definition_id"
    )
}

#' Add concept name for each concept_id
#'
#' @param table cdm_table that contains column.
#' @param column Column to add the concept names from. If NULL any column that
#' its name ends with `concept_id` will be used.
#' @param nameStyle Name of the new column.
#'
#' @return table with an extra column with the concept names.
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#' library(omock)
#' library(dplyr, warn.conflicts = FALSE)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' cdm$drug_exposure |>
#'   addConceptName(column = "drug_concept_id", nameStyle = "drug_name") |>
#'   glimpse()
#'
#' cdm$drug_exposure |>
#'   addConceptName() |>
#'   glimpse()
#' }
#'
addConceptName <- function(table,
                           column = NULL,
                           nameStyle = "{column}_name") {
  # initial checks
  omopgenerics::assertClass(table, class = "cdm_table")
  if (is.null(column)) {
    column <- purrr::keep(colnames(table), \(col) endsWith(col, "concept_id"))
  }
  omopgenerics::assertCharacter(column)
  notPresent <- purrr::keep(column, \(col) !col %in% colnames(table))
  if (length(notPresent) > 0) {
    cli::cli_inform(c("!" = "{.var {notPresent}} ignored as not present in table."))
  }
  column <- purrr::keep(column, \(col) col %in% colnames(table))
  omopgenerics::validateNameStyle(nameStyle = nameStyle, column = column)
  cdm <- omopgenerics::cdmReference(table)

  # eliminate existent columns
  eliminate <- glue::glue(nameStyle) |>
    as.character() |>
    purrr::keep(\(col) col %in% colnames(table))
  if (length(eliminate) > 0) {
    cli::cli_inform(c("!" = "{.var {eliminate}} will be overwriten."))
    table <- table |>
      dplyr::select(!dplyr::all_of(eliminate))
  }

  # add concept names
  for (col in column) {
    cols <- c("concept_id", "concept_name") |>
      rlang::set_names(c(col, glue::glue(nameStyle, column = col)))
    table <- table |>
      dplyr::left_join(
        cdm$concept |>
          dplyr::select(dplyr::all_of(cols)),
        by = col
      )
  }

  table
}

#' Add cdm name
#'
#' @param table Table in the cdm
#' @param cdm A cdm reference object
#'
#' @return Table with an extra column with the cdm names
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
#'   addCdmName()
#' }
#'
addCdmName <- function(table, cdm = omopgenerics::cdmReference(table)) {
  name <- omopgenerics::cdmName(cdm)
  if ("cdm_name" %in% colnames(table)) {
    cli::cli_inform(c("!" = "`cdm_name` will be overwrite"))
  }
  table |> dplyr::mutate("cdm_name" = .env$name)
}

newTable <- function(name, call = parent.frame()) {
  omopgenerics::assertCharacter(name, length = 1, null = TRUE, na = TRUE, call = call)
  if (is.null(name) || is.na(name)) {
    x <- list(name = omopgenerics::uniqueTableName(), temporary = TRUE)
  } else {
    x <- list(name = name, temporary = FALSE)
  }
  return(x)
}
uniqueColumnName <- function(cols = character(), n = 1, nletters = 2) {
  x <- rep(list(letters), nletters) |>
    rlang::set_names(paste0("id_", seq_len(nletters)))
  tidyr::expand_grid(!!!x) |>
    tidyr::unite(col = "id", dplyr::starts_with("id_"), sep = "") |>
    dplyr::mutate("id" = paste0("id_", .data$id)) |>
    dplyr::filter(!.data$id %in% .env$cols) |>
    dplyr::sample_n(size = .env$n) |>
    dplyr::pull("id")
}
computeTable <- function(x, name) {
  if (is.null(name) || is.na(name)) {
    x <- x |>
      dplyr::compute(name = omopgenerics::uniqueTableName(), temporary = TRUE)
  } else {
    x <- x |>
      dplyr::compute(name = name, temporary = FALSE)
  }
  return(x)
}
