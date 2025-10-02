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

.addIntersect <- function(x,
                          tableName,
                          value,
                          filterVariable = NULL,
                          filterId = NULL,
                          idName = NULL,
                          window = list(c(0, Inf)),
                          indexDate = "cohort_start_date",
                          censorDate = NULL,
                          targetStartDate = startDateColumn(tableName),
                          targetEndDate = endDateColumn(tableName),
                          inObservation = TRUE,
                          order = "first",
                          allowDuplicates = FALSE,
                          nameStyle = "{value}_{id_name}_{window_name}",
                          name = NULL) {
  comp <- newTable(name)
  if (!is.list(window)) {
    window <- list(window)
  }

  targetStartDate <- eval(targetStartDate)
  targetEndDate <- eval(targetEndDate)

  # initial checks
  omopgenerics::validateCdmTable(table = x)
  personVariable <- omopgenerics::getPersonIdentifier(x = x)
  cdm <- omopgenerics::cdmReference(x)
  omopgenerics::assertCharacter(tableName, length = 1, na = FALSE)
  omopgenerics::assertCharacter(tableName)
  omopgenerics::validateCdmArgument(cdm = cdm, requiredTables = tableName)
  personVariableTable <- omopgenerics::getPersonIdentifier(x = cdm[[tableName]])
  extraValue <- checkValue(value, cdm[[tableName]], tableName)
  filterTbl <- checkFilter(filterVariable, filterId, idName, cdm[[tableName]])
  window <- omopgenerics::validateWindowArgument(window)
  checkVariableInX(indexDate, x)
  checkVariableInX(targetStartDate, cdm[[tableName]], FALSE, "targetStartDate")
  checkVariableInX(targetEndDate, cdm[[tableName]], TRUE, "targetEndDate")
  omopgenerics::assertChoice(order, choices = c("first", "last"))
  checkVariableInX(censorDate, x, TRUE, "censorDate")
  omopgenerics::assertLogical(allowDuplicates, length = 1)

  if (!is.null(censorDate)) {
    checkCensorDate(x, censorDate)
  }
  if (!is.null(idName)) {
    idName <- omopgenerics::toSnakeCase(idName)
  }

  tablePrefix <- omopgenerics::tmpPrefix()

  # define overlapTable that contains the events of interest
  overlapTable <- cdm[[tableName]]
  if (!is.null(filterTbl)) {
    filterTbl <- filterTbl |>
      dplyr::rename(!!filterVariable := "id")
    filterTblName <- omopgenerics::uniqueTableName(tablePrefix)
    cdm <- omopgenerics::insertTable(
      cdm = cdm, name = filterTblName, table = filterTbl, overwrite = TRUE
    )
    overlapTable <- overlapTable |>
      dplyr::inner_join(cdm[[filterTblName]], by = filterVariable)
  } else {
    filterTbl <- dplyr::tibble(id_name = "all")
    overlapTable <- dplyr::mutate(overlapTable, "id_name" = "all")
  }

  values <- list(
    "id_name" = filterTbl$id_name,
    "window_name" = names(window),
    "value" = value
  )
  assertNameStyle(nameStyle, values)
  x <- warnOverwriteColumns(x = x, nameStyle = nameStyle, values = values)

  # columns that will be added
  newCols <- expand.grid(
    value = value,
    id_name = filterTbl$id_name,
    window_name = names(window)
  ) |>
    dplyr::as_tibble() |>
    dplyr::mutate(colnam = as.character(glue::glue(
      nameStyle,
      value = .data$value,
      id_name = .data$id_name,
      window_name = .data$window_name
    ))) |>
    dplyr::mutate(colnam = omopgenerics::toSnakeCase(.data$colnam)) |>
    dplyr::inner_join(
      dplyr::tibble(
        window_name = names(window),
        w1 = purrr::flatten_dbl(purrr::map(window, \(x) x[1])),
        w2 = purrr::flatten_dbl(purrr::map(window, \(x) x[2]))
      ),
      by = "window_name"
    )

  nameStyle <- stringr::str_replace(nameStyle, "\\{value\\}", "\\{.value\\}")

  overlapTable <- overlapTable |>
    dplyr::select(
      !!personVariable := dplyr::all_of(personVariableTable),
      "start_date" = dplyr::all_of(targetStartDate),
      "end_date" = dplyr::all_of(targetEndDate %||% targetStartDate),
      dplyr::all_of(extraValue),
      "id_name"
    ) |>
    dplyr::mutate(end_date = dplyr::coalesce(.data$end_date, .data$start_date))

  result <- x |>
    dplyr::select(
      dplyr::all_of(personVariable),
      "index_date" = dplyr::all_of(indexDate),
      "censor_date" = dplyr::any_of(censorDate)
    ) |>
    dplyr::distinct()

  if (any(value %in% c("count", "flag"))) {
    idsObs <- omopgenerics::uniqueId(n = 2, exclude = colnames(x))
    qInObservation <- newCols$colnam |>
      rlang::set_names() |>
      purrr::map(\(col) {
        w1 <- newCols$w1[newCols$colnam == col]
        w2 <- newCols$w2[newCols$colnam == col]
        if (is.infinite(w1)) {
          if (is.infinite(w2)) {
            res <- NULL
          } else {
            res <- 'dplyr::if_else(.data${idsObs[1]} <= {sprintf("%.0f", w2)}, .data[["{col}"]], NA)'
          }
        } else if (is.infinite(w2)) {
          res <- 'dplyr::if_else(.data${idsObs[2]} >= {sprintf("%.0f", w1)}, .data[["{col}"]], NA)'
        } else {
          res <- 'dplyr::if_else(.data${idsObs[1]} <= {sprintf("%.0f", w2)} & .data${idsObs[2]} >= {sprintf("%.0f", w1)}, .data[["{col}"]], NA)'
        }
        glue::glue(res)
      }) |>
      unlist() |>
      rlang::parse_exprs()
    if (length(qInObservation) > 0) {
      renamePersonId <- rlang::set_names("person_id", personVariable)
      renameDates <- rlang::set_names(
        c("observation_period_start_date", "observation_period_end_date"), idsObs
      )
      individualsInObservation <- x |>
        dplyr::select(dplyr::all_of(c(personVariable, indexDate))) |>
        dplyr::distinct() |>
        dplyr::inner_join(
          cdm$observation_period |>
            dplyr::select(dplyr::all_of(c(renamePersonId, renameDates))),
          by = personVariable
        ) |>
        dplyr::filter(
          .data[[indexDate]] >= .data[[idsObs[1]]] &
            .data[[indexDate]] <= .data[[idsObs[2]]]
        ) |>
        dplyr::mutate(
          !!idsObs[1] := as.integer(clock::date_count_between(start = .data[[indexDate]], end = .data[[idsObs[1]]], precision = "day")),
          !!idsObs[2] := as.integer(clock::date_count_between(start = .data[[indexDate]], end = .data[[idsObs[2]]], precision = "day"))
        ) |>
        dplyr::compute(name = omopgenerics::uniqueTableName(prefix = tablePrefix))
    }
  }

  if (isTRUE(inObservation)) {
    sel <- c("person_id", "observation_period_start_date", "observation_period_end_date") |>
      rlang::set_names(c(personVariable, "start_obs", "end_obs"))
    result <- result |>
      dplyr::inner_join(
        cdm$observation_period |>
          dplyr::select(dplyr::all_of(sel)),
        by = personVariable
      ) |>
      dplyr::filter(
        .data$start_obs <= .data$index_date & .data$index_date <= .data$end_obs
      )
  }

  result <- result |>
    dplyr::inner_join(overlapTable, by = personVariable)

  if (!is.null(censorDate)) {
    result <- result |>
      dplyr::filter(.data$start_date <= .data$censor_date)
  }

  if (isTRUE(inObservation)) {
    result <- result |>
      dplyr::filter(
        .data$start_obs <= .data$end_date & .data$start_date <= .data$end_obs
      )
  }

  result <- result |>
    dplyr::mutate(
      "start" = clock::date_count_between(start = .data$index_date, end = .data$start_date, precision = "day"),
      "end" = clock::date_count_between(start = .data$index_date, end = .data$end_date, precision = "day")
    ) |>
    dplyr::select(!dplyr::any_of(c(
      "censor_date", "start_date", "end_date", "start_obs", "end_obs"
    ))) |>
    dplyr::compute(name = omopgenerics::uniqueTableName(tablePrefix))

  resultCountFlag <- NULL
  resultDateTimeOther <- NULL
  # Start loop for different windows

  for (i in seq_along(window)) {
    win <- window[[i]]
    if (is.infinite(win[1])) {
      if (is.infinite(win[2])) {
        resultW <- result
      } else {
        resultW <- result |> dplyr::filter(.data$start <= !!win[2])
      }
    } else {
      if (is.infinite(win[2])) {
        resultW <- result |> dplyr::filter(.data$end >= !!win[1])
      } else {
        resultW <- result |>
          dplyr::filter(.data$end >= !!win[1] & .data$start <= !!win[2])
      }
    }

    resultW <- resultW |>
      dplyr::select(-"end") |>
      dplyr::compute(name = omopgenerics::uniqueTableName(tablePrefix))

    # add count or flag
    if ("count" %in% value | "flag" %in% value) {
      if (identical("flag", value)) {
        resultCF <- resultW |>
          dplyr::distinct(.data[[personVariable]], .data$index_date, .data$id_name) |>
          dplyr::mutate(flag = 1)
      } else {
        resultCF <- resultW |>
          dplyr::group_by(.data[[personVariable]], .data$index_date, .data$id_name) |>
          dplyr::summarise(count = as.numeric(dplyr::n()), .groups = "drop")
        if ("flag" %in% value) {
          resultCF <- resultCF |> dplyr::mutate(flag = 1)
        }
        if (!("count" %in% value)) {
          resultCF <- resultCF |> dplyr::select(-"count")
        }
      }
      resultCF <- resultCF |>
        dplyr::mutate("window_name" = !!tolower(names(window)[i]))

      if (i == 1) {
        resultCountFlag <- resultCF |>
          dplyr::compute(name = omopgenerics::uniqueTableName(tablePrefix))
      } else {
        resultCountFlag <- resultCountFlag |>
          dplyr::union_all(resultCF) |>
          dplyr::compute(name = omopgenerics::uniqueTableName(tablePrefix))
      }
    }
    # add date, time or other
    if (length(value[!(value %in% c("count", "flag"))]) > 0) {
      if (length(extraValue) > 0) {
        resultDTO <- resultW |>
          dplyr::select(dplyr::all_of(c(personVariable, "index_date", "id_name", extraValue, "days" = "start"))) |>
          dplyr::group_by(.data[[personVariable]], .data$index_date, .data$id_name)
        if (order == "first") {
          resultDTO <- resultDTO |>
            dplyr::filter(.data$days == min(.data$days, na.rm = TRUE))
        } else {
          resultDTO <- resultDTO |>
            dplyr::filter(.data$days == max(.data$days, na.rm = TRUE))
        }
        if (allowDuplicates) {
          qs <- extraValue |>
            rlang::set_names() |>
            purrr::map_chr(\(x) paste0('stringr::str_flatten(.data[["', x, '"]], collapse = "; ")')) |>
            rlang::parse_exprs()
          resultDTO <- resultDTO |>
            dplyr::group_by(.data[[personVariable]], .data$index_date, .data$id_name, .data$days) |>
            dplyr::summarise(!!!qs, .groups = "drop")
        }
        if ("date" %in% value) {
          resultDTO <- resultDTO |>
            dplyr::mutate(date = as.Date(clock::add_days(x = .data$index_date, n = .data$days)))
        }
      } else {
        resultDTO <- resultW |>
          dplyr::group_by(.data[[personVariable]], .data$index_date, .data$id_name)
        if (order == "first") {
          resultDTO <- resultDTO |>
            dplyr::summarise(
              days = min(.data$start, na.rm = TRUE), .groups = "drop"
            )
        } else {
          resultDTO <- resultDTO |>
            dplyr::summarise(
              days = max(.data$start, na.rm = TRUE), .groups = "drop"
            )
        }
        if ("date" %in% value) {
          resultDTO <- resultDTO |>
            dplyr::mutate(date = as.Date(clock::add_days(x = .data$index_date, n = .data$days)))
        }
      }

      resultDTO <- resultDTO |>
        dplyr::mutate("window_name" = !!tolower(names(window)[i]))
      if (!("days" %in% value)) {
        resultDTO <- dplyr::select(resultDTO, -"days")
      }
      if (i == 1) {
        resultDateTimeOther <- resultDTO |>
          dplyr::compute(name = omopgenerics::uniqueTableName(tablePrefix))
      } else {
        resultDateTimeOther <- resultDateTimeOther |>
          dplyr::union_all(resultDTO) |>
          dplyr::compute(name = omopgenerics::uniqueTableName(tablePrefix))
      }
    }
  }

  if (any(c("flag", "count") %in% value)) {
    values <- value[value %in% c("count", "flag")]
    resultCountFlagPivot <- resultCountFlag |>
      tidyr::pivot_wider(
        names_from = c("id_name", "window_name"),
        values_from = dplyr::any_of(values),
        names_glue = nameStyle,
        values_fill = 0
      ) |>
      dplyr::rename(!!indexDate := "index_date") |>
      dplyr::rename_all(tolower) |>
      dplyr::compute(name = omopgenerics::uniqueTableName(tablePrefix))

    newColCountFlag <- colnames(resultCountFlagPivot)
    newColCountFlag <- newColCountFlag[newColCountFlag %in% newCols$colnam]

    x <- x |>
      dplyr::left_join(
        resultCountFlagPivot,
        by = c(personVariable, indexDate)
      ) |>
      dplyr::compute(name = omopgenerics::uniqueTableName(tablePrefix))

    x <- x |>
      dplyr::mutate(dplyr::across(
        dplyr::all_of(newColCountFlag), ~ dplyr::if_else(is.na(.x), 0, .x)
      )) |>
      dplyr::compute(name = omopgenerics::uniqueTableName(tablePrefix))
  }

  if (length(value[!(value %in% c("count", "flag"))]) > 0) {
    values <- value[!(value %in% c("count", "flag"))]

    if (length(extraValue) > 0 & !allowDuplicates) {
      duplicates <- resultDateTimeOther |>
        dplyr::select(
          dplyr::all_of(personVariable), "index_date",
          dplyr::all_of(extraValue), "id_name", "window_name"
        ) |>
        dplyr::group_by(dplyr::across(dplyr::all_of(c(
          personVariable, "index_date", "id_name", "window_name"
        )))) |>
        dplyr::filter(dplyr::n() > 1) |>
        dplyr::ungroup() |>
        dplyr::tally() |>
        dplyr::pull()
      if (duplicates > 0) {
        cli::cli_abort(c(
          x = "There are {duplicates} row{?s} in {.strong {tableName}} with same
          {.var {c(personVariable, filterVariable, targetStartDate)}}, solve
          duplications or swicth {.pkg allowDuplicates} to TRUE.",
          i = "NOTE that `allowDuplicates = TRUE` can have different and
          unpredictable behavior depending on the cdm_source."
        ))
      }
    }

    resultDateTimeOther <- resultDateTimeOther |>
      dplyr::select(
        dplyr::all_of(personVariable), "index_date", dplyr::all_of(values),
        "id_name", "window_name"
      ) |>
      tidyr::pivot_wider(
        names_from = c("id_name", "window_name"),
        values_from = dplyr::all_of(values),
        names_glue = nameStyle
      ) |>
      dplyr::rename(!!indexDate := "index_date") |>
      dplyr::rename_all(tolower)

    x <- x |>
      dplyr::left_join(
        resultDateTimeOther, by = c(personVariable, indexDate)
      ) |>
      dplyr::compute(name = omopgenerics::uniqueTableName(tablePrefix))
  }

  # missing columns
  createMissingCols <- newCols |>
    dplyr::filter(!.data$colnam %in% colnames(x)) |>
    dplyr::pull("colnam") |>
    rlang::set_names() |>
    purrr::map_chr(\(x) {
      val <- as.character(newCols$value[newCols$colnam == x])
      switch(val,
             flag = "0",
             count = "0",
             days = "as.numeric(NA)",
             date = "as.Date(NA)",
             "as.character(NA)")
    }) |>
    rlang::parse_exprs()
  if (length(createMissingCols) > 0) {
    x <- x |>
      dplyr::mutate(!!!createMissingCols) |>
      dplyr::compute(name = omopgenerics::uniqueTableName(tablePrefix))
  }

  if (any(value %in% c("count", "flag"))) {
    if (length(qInObservation) > 0) {
      x <- x |>
        dplyr::left_join(individualsInObservation, by = c(personVariable, indexDate)) |>
        dplyr::mutate(!!!qInObservation) |>
        dplyr::select(!dplyr::all_of(idsObs))
    }
  }

  x <- x |>
    dplyr::compute(name = comp$name, temporary = comp$temporary)

  omopgenerics::dropSourceTable(
    cdm = cdm, name = dplyr::starts_with(tablePrefix)
  )

  return(x)
}

#' Get the name of the start date column for a certain table in the cdm
#'
#' @param tableName Name of the table.
#'
#' @return Name of the start date column in that table.
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' startDateColumn("condition_occurrence")
#' }
#'
startDateColumn <- function(tableName) {
  if (tableName %in% omopgenerics::omopTables()) {
    col <- omopgenerics::omopColumns(table = tableName, field = "start_date")
  } else {
    col <- "cohort_start_date"
  }
  return(col)
}

#' Get the name of the end date column for a certain table in the cdm
#'
#' @param tableName Name of the table.
#'
#' @return Name of the end date column in that table.
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' endDateColumn("condition_occurrence")
#' }
#'
endDateColumn <- function(tableName) {
  if (tableName %in% omopgenerics::omopTables()) {
    col <- omopgenerics::omopColumns(table = tableName, field = "end_date")
  } else {
    col <- "cohort_end_date"
  }
  return(col)
}

#' Get the name of the standard concept_id column for a certain table in the cdm
#'
#' @param tableName Name of the table.
#'
#' @return Name of the concept_id column in that table.
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' standardConceptIdColumn("condition_occurrence")
#' }
#'
standardConceptIdColumn <- function(tableName) {
  if (tableName %in% omopgenerics::omopTables()) {
    col <- omopgenerics::omopColumns(table = tableName, field = "standard_concept")
  } else {
    col <- "cohort_definition_id"
  }
  return(col)
}

#' Get the name of the source concept_id column for a certain table in the cdm
#'
#' @param tableName Name of the table.
#'
#' @return Name of the source_concept_id column in that table.
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' sourceConceptIdColumn("condition_occurrence")
#' }
#'
sourceConceptIdColumn <- function(tableName) {
  if (tableName %in% omopgenerics::omopTables()) {
    col <- omopgenerics::omopColumns(table = tableName, field = "source_concept")
  } else {
    col <- NA_character_
  }
  return(col)
}

messageOrder <- function(order) {
  cli::cli_inform(c("i" = "`order` argument is populated by default to
                    {.pkg {order}}, which means {order} ever record in the
                    window will be considered. Populate the argument explicitly
                    to silence this message."))
}
