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

.addConceptIntersect <- function(x,
                                 conceptSet,
                                 indexDate = "cohort_start_date",
                                 censorDate = NULL,
                                 window,
                                 targetStartDate = "event_start_date",
                                 targetEndDate = "event_end_date",
                                 inObservation = TRUE,
                                 order = "first",
                                 value,
                                 allowDuplicates = FALSE,
                                 nameStyle = "{value}_{concept_name}_{window_name}",
                                 name) {
  cdm <- omopgenerics::cdmReference(x)

  # initial checks
  conceptSet <- omopgenerics::validateConceptSetArgument(conceptSet = conceptSet, cdm = cdm)
  omopgenerics::assertChoice(targetStartDate, choices = c("event_start_date", "event_end_date"), length = 1)
  omopgenerics::assertChoice(targetEndDate, choices = c("event_start_date", "event_end_date"), length = 1, null = TRUE)
  omopgenerics::assertLogical(inObservation, length = 1)
  omopgenerics::assertCharacter(value)

  # validate names of concept set
  conceptSet <- validateConceptNames(conceptSet)

  tablePrefix <- omopgenerics::tmpPrefix()

  nameStyle <- nameStyle |>
    stringr::str_replace(
      pattern = "\\{concept_name\\}",
      replacement = "\\{id_name\\}"
    )

  # concepts table
  conceptsTable <- getConceptsTable(conceptSet)
  nm <- omopgenerics::uniqueTableName(tablePrefix)
  cdm <- omopgenerics::insertTable(cdm = cdm, name = nm, table = conceptsTable)

  # ids
  conceptSetId <- conceptSetId(conceptSet)

  # subset table
  cdm[[nm]] <- subsetTable(cdm[[nm]], value) |>
    dplyr::compute(name = nm, temporary = FALSE)
  attr(x, "cdm_reference") <- cdm
  x <- x |>
    .addIntersect(
      tableName = nm,
      value = value,
      filterVariable = "concept_set_id",
      filterId = conceptSetId$concept_set_id,
      idName = conceptSetId$concept_set_name,
      window = window,
      order = order,
      indexDate = indexDate,
      censorDate = censorDate,
      targetStartDate = targetStartDate,
      targetEndDate = targetEndDate,
      inObservation = inObservation,
      allowDuplicates = allowDuplicates,
      nameStyle = nameStyle,
      name = name
    )

  # drop intermediate tables
  omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(tablePrefix))

  return(x)
}
validateConceptNames <- function(cs) {
  orig <- names(cs)

  # to lower
  new <- tolower(orig)

  # replace
  new <- gsub(pattern = "[^A-Za-z0-9_]", replacement = "_", x = new)

  # replace multiple underscores
  new <- gsub(pattern = "_+", replacement = "_", x = new)

  # check if names changed
  idDiff <- new != orig
  diffNew <- new[idDiff]
  diffOrig <- orig[idDiff]
  if (length(diffOrig) > 0) {
    mes <- paste0("- '", diffOrig, "' -> '", diffNew, "'")
    c("The following conceptSet names have been modified:", mes) |>
      paste0(collapse = "\n") |>
      rlang::inform()
  }

  # error if uniqueness has been altered
  if (length(unique(new)) != length(new)) {
    cli::cli_abort(c(x = "Concept set names are not unique after formatting."))
  }

  names(cs) <- new

  return(cs)
}
getConceptsTable <- function(conceptSet) {
  purrr::map(conceptSet, dplyr::as_tibble) |>
    dplyr::bind_rows(.id = "concept_set_name") |>
    dplyr::inner_join(conceptSetId(conceptSet), by = "concept_set_name") |>
    dplyr::select("concept_id" = "value", "concept_set_id")
}
conceptSetId <- function(conceptSet) {
  dplyr::tibble(
    "concept_set_name" = names(conceptSet),
    "concept_set_id" = as.integer(seq_along(conceptSet))
  )
}
subsetTable <- function(x, value) {
  cdm <- omopgenerics::cdmReference(x)

  # domains
  x <- x |>
    dplyr::left_join(
      cdm[["concept"]] |>
        dplyr::select("concept_id", "domain_id") |>
        dplyr::mutate(domain_id = tolower(.data$domain_id)),
      by = "concept_id"
    ) |>
    dplyr::compute()

  # check domains
  supportedDomains <- list(
    "device" = "device_exposure",
    "specimen" = "specimen",
    "measurement" = "measurement",
    "drug" = "drug_exposure",
    "condition" = "condition_occurrence",
    "observation" = "observation",
    "procedure" = "procedure_occurrence",
    "episode" = "episode",
    "visit" = "visit_occurrence"
  )
  x <- checkDomainsAndTables(x, supportedDomains)

  domains <- x |>
    dplyr::distinct(.data$domain_id) |>
    dplyr::pull()
  if (length(domains) == 0) {
    res <- cdm[["concept"]] |>
      dplyr::select("concept_id") |>
      dplyr::mutate(
        "event_start_date" = as.Date("2000-01-01"),
        "event_end_date" = as.Date("2000-01-01"),
        "concept_set_id" = 0L,
        "person_id" = 0L
      ) |>
      utils::head(0)
    if (!value %in% c("flag", "count", "date", "days")) {
      res <- res |>
        dplyr::mutate(!!value := "")
    }
    return(res)
  }

  # extra column
  if (!value %in% c("flag", "count", "date", "days")) {
    type <- purrr::map(domains, \(x) {
      nm <- supportedDomains[[x]]
      if (!nm %in% names(cdm)) {
        type <- character()
      } else if (value %in% colnames(cdm[[nm]])) {
        type <- cdm[[nm]] |>
          dplyr::select(dplyr::all_of(value)) |>
          utils::head(1) |>
          dplyr::pull() |>
          dplyr::type_sum()
      } else {
        type <- character()
      }
      return(type)
    }) |>
      unlist() |>
      unique()
    if (length(type) == 1) {
      val <- switch(type,
                    "chr" = NA_character_,
                    "date" = as.Date(NA),
                    "dttm" = as.Date(NA),
                    "lgl" = NA,
                    "drtn" = NA_real_,
                    "dbl" = NA_real_,
                    "int" = NA_integer_,
                    "int64" = bit64::as.integer64(NA),
                    NA_character_)
      extraColumn <- TRUE
    } else if (length(type) == 0) {
      cli::cli_abort(c(x = "Column `{value}` not found in any of the tables."))
    } else {
      cli::cli_abort(c(x = "Different types found for column `{value}`."))
    }
  } else {
    extraColumn <- FALSE
  }

  purrr::map(domains, \(domain) {
    tableName <- supportedDomains[[domain]]
    sel <- c(
      "event_start_date" = startDateColumn(tableName),
      "event_end_date" = endDateColumn(tableName),
      "concept_id" = standardConceptIdColumn(tableName),
      "person_id"
    )
    if (extraColumn & value %in% colnames(cdm[[tableName]])) {
      sel <- c(sel, value)
    }
    res <- cdm[[tableName]] |>
      dplyr::select(dplyr::all_of(sel)) |>
      dplyr::inner_join(
        x |> dplyr::select("concept_id", "concept_set_id"),
        by = "concept_id"
      )
    if (extraColumn & !value %in% colnames(cdm[[tableName]])) {
      res <- dplyr::mutate(res, !!value := .env$val)
    }
    res
  }) |>
    purrr::reduce(dplyr::union_all)
}
checkDomainsAndTables <- function(x, supportedDomains) {
  # get cdm reference
  cdm <- omopgenerics::cdmReference(x)
  supDom <- names(supportedDomains)

  # get counts
  counts <- x |>
    dplyr::group_by(.data$domain_id) |>
    dplyr::tally() |>
    dplyr::collect()

  # domains
  cnd <- counts |>
    dplyr::filter(!.data$domain_id %in% .env$supDom)
  if (nrow(cnd) > 0) {
    mes <- paste0(cnd$n, " concept(s) from domain {.pkg ", cnd$domain_id, "} eliminated as it is not supported.")
    names(mes) <- rep("!", length(mes))
    mes <- c(mes, i = "Supported domains are: {.pkg {names(supportedDomains)}}.")
    cli::cli_inform(message = mes)
  }
  x <- x |>
    dplyr::filter(.data$domain_id %in% .env$supDom)

  # tables
  presentTables <- x |>
    dplyr::distinct(.data$domain_id) |>
    dplyr::pull() |>
    purrr::keep(\(dom) supportedDomains[[dom]] %in% names(cdm))
  cnt <- counts |>
    dplyr::filter(.data$domain_id %in% .env$supDom) |>
    dplyr::filter(!.data$domain_id %in% .env$presentTables)
  if (nrow(cnt) > 0) {
    mes <- paste0(cnt$n, " concept(s) from domain {.pkg ", cnt$domain_id, "} eliminated as table {.var ", supportedDomains[[cnt$domain_id]],"} is not present.")
    names(mes) <- rep("!", length(mes))
    cli::cli_inform(message = mes)
  }
  x <- x |>
    dplyr::filter(.data$domain_id %in% .env$presentTables)

  dplyr::compute(x)
}

#' It creates column to indicate the flag overlap information between a table
#' and a concept
#'
#' @param x Table with individuals in the cdm.
#' @param conceptSet Concept set list.
#' @param indexDate Variable in x that contains the date to compute the
#' intersection.
#' @param censorDate whether to censor overlap events at a date column of x
#' @param window window to consider events in.
#' @param targetStartDate Event start date to use for the intersection.
#' @param targetEndDate Event end date to use for the intersection.
#' @param inObservation If TRUE only records inside an observation period
#' will be considered.
#' @param nameStyle naming of the added column or columns, should include
#' required parameters.
#' @param name Name of the new table, if NULL a temporary table is returned.
#'
#' @return table with added columns with overlap information
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#' library(omopgenerics, warn.conflicts = TRUE)
#' library(dplyr, warn.conflicts = TRUE)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' concept <- tibble(
#'   concept_id = c(1125315),
#'   domain_id = "Drug",
#'   vocabulary_id = NA_character_,
#'   concept_class_id = "Ingredient",
#'   standard_concept = "S",
#'   concept_code = NA_character_,
#'   valid_start_date = as.Date("1900-01-01"),
#'   valid_end_date = as.Date("2099-01-01"),
#'   invalid_reason = NA_character_
#' ) |>
#'   mutate(concept_name = paste0("concept: ", .data$concept_id))
#' cdm <- insertTable(cdm, "concept", concept)
#'
#' cdm$cohort1 |>
#'   addConceptIntersectFlag(conceptSet = list("acetaminophen" = 1125315))
#'
#' }
#'
addConceptIntersectFlag <- function(x,
                                    conceptSet,
                                    indexDate = "cohort_start_date",
                                    censorDate = NULL,
                                    window = list(c(0, Inf)),
                                    targetStartDate = "event_start_date",
                                    targetEndDate = "event_end_date",
                                    inObservation = TRUE,
                                    nameStyle = "{concept_name}_{window_name}",
                                    name = NULL) {
  .addConceptIntersect(
    x = x,
    conceptSet = conceptSet,
    indexDate = indexDate,
    censorDate = censorDate,
    window = window,
    targetStartDate = targetStartDate,
    targetEndDate = targetEndDate,
    inObservation = inObservation,
    order = "first",
    value = "flag",
    nameStyle = nameStyle,
    name = name
  )
}

#' It creates column to indicate the count overlap information between a table
#' and a concept
#'
#' @param x Table with individuals in the cdm.
#' @param conceptSet Concept set list.
#' @param indexDate Variable in x that contains the date to compute the
#' intersection.
#' @param censorDate whether to censor overlap events at a date column of x
#' @param window window to consider events in.
#' @param targetStartDate Event start date to use for the intersection.
#' @param targetEndDate Event end date to use for the intersection.
#' @param inObservation If TRUE only records inside an observation period
#' will be considered.
#' @param nameStyle naming of the added column or columns, should include
#' required parameters.
#' @param name Name of the new table, if NULL a temporary table is returned.
#'
#' @return table with added columns with overlap information
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#' library(omopgenerics, warn.conflicts = TRUE)
#' library(dplyr, warn.conflicts = TRUE)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' concept <- tibble(
#'   concept_id = c(1125315),
#'   domain_id = "Drug",
#'   vocabulary_id = NA_character_,
#'   concept_class_id = "Ingredient",
#'   standard_concept = "S",
#'   concept_code = NA_character_,
#'   valid_start_date = as.Date("1900-01-01"),
#'   valid_end_date = as.Date("2099-01-01"),
#'   invalid_reason = NA_character_
#' ) |>
#'   mutate(concept_name = paste0("concept: ", .data$concept_id))
#' cdm <- insertTable(cdm, "concept", concept)
#'
#' cdm$cohort1 |>
#'   addConceptIntersectCount(conceptSet = list("acetaminophen" = 1125315))
#'
#' }
#'
addConceptIntersectCount <- function(x,
                                     conceptSet,
                                     indexDate = "cohort_start_date",
                                     censorDate = NULL,
                                     window = list(c(0, Inf)),
                                     targetStartDate = "event_start_date",
                                     targetEndDate = "event_end_date",
                                     inObservation = TRUE,
                                     nameStyle = "{concept_name}_{window_name}",
                                     name = NULL) {
  .addConceptIntersect(
    x = x,
    conceptSet = conceptSet,
    indexDate = indexDate,
    censorDate = censorDate,
    window = window,
    targetStartDate = targetStartDate,
    targetEndDate = targetEndDate,
    inObservation = inObservation,
    order = "first",
    value = "count",
    nameStyle = nameStyle,
    name = name
  )
}

#' It creates column to indicate the date overlap information between a table
#' and a concept
#'
#' @param x Table with individuals in the cdm.
#' @param conceptSet Concept set list.
#' @param indexDate Variable in x that contains the date to compute the
#' intersection.
#' @param censorDate whether to censor overlap events at a date column of x
#' @param window window to consider events in.
#' @param targetDate Event date to use for the intersection.
#' @param order last or first date to use for date/days calculations.
#' @param inObservation If TRUE only records inside an observation period
#' will be considered.
#' @param nameStyle naming of the added column or columns, should include
#' required parameters.
#' @param name Name of the new table, if NULL a temporary table is returned.
#'
#' @return table with added columns with overlap information
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#' library(omopgenerics, warn.conflicts = TRUE)
#' library(dplyr, warn.conflicts = TRUE)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' concept <- tibble(
#'   concept_id = c(1125315),
#'   domain_id = "Drug",
#'   vocabulary_id = NA_character_,
#'   concept_class_id = "Ingredient",
#'   standard_concept = "S",
#'   concept_code = NA_character_,
#'   valid_start_date = as.Date("1900-01-01"),
#'   valid_end_date = as.Date("2099-01-01"),
#'   invalid_reason = NA_character_
#' ) |>
#'   mutate(concept_name = paste0("concept: ", .data$concept_id))
#' cdm <- insertTable(cdm, "concept", concept)
#'
#' cdm$cohort1 |>
#'   addConceptIntersectDate(conceptSet = list("acetaminophen" = 1125315))
#'
#' }
#'
addConceptIntersectDate <- function(x,
                                    conceptSet,
                                    indexDate = "cohort_start_date",
                                    censorDate = NULL,
                                    window = list(c(0, Inf)),
                                    targetDate = "event_start_date",
                                    order = "first",
                                    inObservation = TRUE,
                                    nameStyle = "{concept_name}_{window_name}",
                                    name = NULL) {

  if (missing(order) & rlang::is_interactive()) {
    messageOrder(order)
  }

  .addConceptIntersect(
    x = x,
    conceptSet = conceptSet,
    indexDate = indexDate,
    censorDate = censorDate,
    window = window,
    targetStartDate = targetDate,
    targetEndDate = NULL,
    inObservation = inObservation,
    order = order,
    value = "date",
    nameStyle = nameStyle,
    name = name
  )
}

#' It creates column to indicate the days of difference from an index date to a
#' concept
#'
#' @param x Table with individuals in the cdm.
#' @param conceptSet Concept set list.
#' @param indexDate Variable in x that contains the date to compute the
#' intersection.
#' @param censorDate whether to censor overlap events at a date column of x
#' @param window window to consider events in.
#' @param targetDate Event date to use for the intersection.
#' @param order last or first date to use for date/days calculations.
#' @param inObservation If TRUE only records inside an observation period
#' will be considered.
#' @param nameStyle naming of the added column or columns, should include
#' required parameters.
#' @param name Name of the new table, if NULL a temporary table is returned.
#'
#' @return table with added columns with overlap information
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#' library(omopgenerics, warn.conflicts = TRUE)
#' library(dplyr, warn.conflicts = TRUE)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' concept <- tibble(
#'   concept_id = c(1125315),
#'   domain_id = "Drug",
#'   vocabulary_id = NA_character_,
#'   concept_class_id = "Ingredient",
#'   standard_concept = "S",
#'   concept_code = NA_character_,
#'   valid_start_date = as.Date("1900-01-01"),
#'   valid_end_date = as.Date("2099-01-01"),
#'   invalid_reason = NA_character_
#' ) |>
#'   mutate(concept_name = paste0("concept: ", .data$concept_id))
#' cdm <- insertTable(cdm, "concept", concept)
#'
#' cdm$cohort1 |>
#'   addConceptIntersectDays(conceptSet = list("acetaminophen" = 1125315))
#'
#' }
#'
addConceptIntersectDays <- function(x,
                                    conceptSet,
                                    indexDate = "cohort_start_date",
                                    censorDate = NULL,
                                    window = list(c(0, Inf)),
                                    targetDate = "event_start_date",
                                    order = "first",
                                    inObservation = TRUE,
                                    nameStyle = "{concept_name}_{window_name}",
                                    name = NULL) {

  if (missing(order) & rlang::is_interactive()) {
    messageOrder(order)
  }

  .addConceptIntersect(
    x = x,
    conceptSet = conceptSet,
    indexDate = indexDate,
    censorDate = censorDate,
    window = window,
    targetStartDate = targetDate,
    targetEndDate = NULL,
    inObservation = inObservation,
    order = order,
    value = "days",
    nameStyle = nameStyle,
    name = name
  )
}

#' It adds a custom column (field) from the intersection with a certain table
#' subsetted by concept id. In general it is used to add the first value of a
#' certain measurement.
#'
#' @param x Table with individuals in the cdm.
#' @param conceptSet Concept set list.
#' @param field Column in the standard omop table that you want to add.
#' @param indexDate Variable in x that contains the date to compute the
#' intersection.
#' @param censorDate Whether to censor overlap events at a date column of x
#' @param window Window to consider events in.
#' @param targetDate Event date to use for the intersection.
#' @param order 'last' or 'first' to refer to which event consider if multiple
#' events are present in the same window.
#' @param inObservation If TRUE only records inside an observation period
#' will be considered.
#' @param allowDuplicates Whether to allow multiple records with same
#' conceptSet, person_id and targetDate. If switched to TRUE, the created new
#' columns (field) will be collapsed to a character vector separated by `;` to
#' account for multiple values per person.
#' @param nameStyle naming of the added column or columns, should include
#' required parameters.
#' @param name Name of the new table, if NULL a temporary table is returned.
#'
#' @return Table with the `field` value obtained from the intersection
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#' library(omopgenerics, warn.conflicts = TRUE)
#' library(dplyr, warn.conflicts = TRUE)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' concept <- tibble(
#'   concept_id = c(1125315),
#'   domain_id = "Drug",
#'   vocabulary_id = NA_character_,
#'   concept_class_id = "Ingredient",
#'   standard_concept = "S",
#'   concept_code = NA_character_,
#'   valid_start_date = as.Date("1900-01-01"),
#'   valid_end_date = as.Date("2099-01-01"),
#'   invalid_reason = NA_character_
#' ) |>
#'   mutate(concept_name = paste0("concept: ", .data$concept_id))
#' cdm <- insertTable(cdm, "concept", concept)
#'
#' cdm$cohort1 |>
#'   addConceptIntersectField(
#'     conceptSet = list("acetaminophen" = 1125315),
#'     field = "drug_type_concept_id"
#'   )
#'
#' }
#'
addConceptIntersectField <- function(x,
                                     conceptSet,
                                     field,
                                     indexDate = "cohort_start_date",
                                     censorDate = NULL,
                                     window = list(c(0, Inf)),
                                     targetDate = "event_start_date",
                                     order = "first",
                                     inObservation = TRUE,
                                     allowDuplicates = FALSE,
                                     nameStyle = "{field}_{concept_name}_{window_name}",
                                     name = NULL) {
  omopgenerics::assertCharacter(nameStyle, length = 1)
  nameStyle <- stringr::str_replace(
    string = nameStyle, pattern = "\\{field\\}", replacement = "\\{value\\}"
  )

  if (missing(order) & rlang::is_interactive()) {
    messageOrder(order)
  }

  .addConceptIntersect(
    x = x,
    conceptSet = conceptSet,
    indexDate = indexDate,
    censorDate = censorDate,
    window = window,
    targetStartDate = targetDate,
    targetEndDate = NULL,
    inObservation = inObservation,
    order = order,
    value = field,
    allowDuplicates = allowDuplicates,
    nameStyle = nameStyle,
    name = name
  )
}
