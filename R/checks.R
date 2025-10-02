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

#' @noRd
checkVariableInX <- function(indexDate, x, nullOk = FALSE, name = "indexDate") {
  omopgenerics::assertCharacter(indexDate, length = 1, null = nullOk)
  if (!is.null(indexDate) && !(indexDate %in% colnames(x))) {
    cli::cli_abort(glue::glue("{name} ({indexDate}) should be a column in x"))
  }
  invisible(NULL)
}

#' @noRd
checkFilter <- function(filterVariable, filterId, idName, x) {
  if (is.null(filterVariable)) {
    filterId <- NULL
    idName <- NULL
    filterTbl <- NULL
  } else {
    checkVariableInX(filterVariable, x, FALSE, "filterVariable")
    omopgenerics::assertNumeric(filterId, na = FALSE)
    omopgenerics::assertNumeric(utils::head(x, 1) |>
                               dplyr::pull(dplyr::all_of(filterVariable)))
    if (is.null(idName)) {
      idName <- paste0("id", filterId)
    } else {
      omopgenerics::assertCharacter(idName,
                                    na = FALSE,
                                    length = length(filterId))
    }
    filterTbl <- dplyr::tibble(
      id = filterId,
      id_name = idName
    )
  }
  invisible(filterTbl)
}

#' @noRd
checkValue <- function(value, x, name) {
  omopgenerics::assertCharacter(value, na = FALSE)
  omopgenerics::assertTrue(all(value %in% c("flag", "count", "date", "days", colnames(x))))
  valueOptions <- c("flag", "count", "date", "days")
  valueOptions <- valueOptions[valueOptions %in% colnames(x)]
  if (length(valueOptions) > 0) {
    cli::cli_warn(paste0(
      "Variables: ",
      paste0(valueOptions, collapse = ", "),
      " are also present in ",
      name,
      ". But have their own functionality inside the package. If you want to
      obtain that column please rename and run again."
    ))
  }
  invisible(value[!(value %in% c("flag", "count", "date", "days"))])
}

#' @noRd
checkCohortNames <- function(x, targetCohortId, name) {
  if (!("cohort_table" %in% class(x))) {
    cli::cli_abort("cdm[[targetCohortTable]]) must be a 'cohort_table'.")
  }
  targetCohortId <- omopgenerics::validateCohortIdArgument(
    cohortId = {{targetCohortId}}, cohort = x
  )
  set <- omopgenerics::settings(x) |>
    dplyr::filter(.data$cohort_definition_id %in% .env$targetCohortId)
  parameters <- list(
    "filter_variable" = "cohort_definition_id",
    "filter_id" = set$cohort_definition_id,
    "id_name" = set$cohort_name
  )
  invisible(parameters)
}

#' @noRd
checkStrata <- function(list, table, type = "strata") {
  errorMessage <- paste0(type, " should be a list that point to columns in table")
  if (!is.list(list)) {
    cli::cli_abort(errorMessage)
  }
  if (length(list) > 0) {
    if (!is.character(unlist(list))) {
      cli::cli_abort(errorMessage)
    }
    if (!all(unlist(list) %in% colnames(table))) {
      notPresent <- list |>
        unlist() |>
        unique()
      notPresent <- notPresent[!notPresent %in% colnames(table)]
      cli::cli_abort(paste0(
        errorMessage,
        ". The following columns were not found in the data: ",
        paste0(notPresent, collapse = ", ")
      ))
    }
  }
  if (!is.null(names(list))) {
    cli::cli_inform(c("!" = "names of {type} will be ignored"))
  }
  names(list) <- NULL
  return(list)
}

#' @noRd
checkVariablesFunctions <- function(variables, estimates, table) {
  errorMessage <- "variables should be a unique named list that point to columns in table"
  omopgenerics::assertList(x = variables, class = "character")
  omopgenerics::assertList(x = estimates, class = "character")
  if (length(variables) != length(estimates)) {
    cli::cli_abort("Variables and estimates must have the same length")
  }
  if (!is.null(names(variables)) & !is.null(names(estimates))) {
    if (!identical(sort(names(variables)), sort(names(estimates)))) {
      cli::cli_abort("Names from variables and estimates must be the same")
    }
    variables <- variables[order(names(variables))]
    estimates <- estimates[order(names(estimates))]
  }

  if (length(variables) == 0) {
    return(dplyr::tibble(
      "variable_name" = character(),
      "estimate_name" = character(),
      "variable_type" = character(),
      "estimate_type" = character()
    ))
  }

  functions <- lapply(seq_along(variables), function(k) {
    tidyr::expand_grid(
      variable_name = variables[[k]],
      estimate_name = estimates[[k]]
    )
  }) |>
    dplyr::bind_rows() |>
    dplyr::inner_join(variableTypes(table), by = "variable_name") |>
    dplyr::inner_join(
      availableEstimates(fullQuantiles = TRUE) |>
        dplyr::select(-"estimate_description"),
      by = c("variable_type", "estimate_name")
    )

  # check binary
  binaryVars <- functions |>
    dplyr::filter(
      .data$variable_type %in% c("numeric", "integer") &
        .data$estimate_name %in% c("count", "percentage")
    ) |>
    dplyr::select("variable_name") |>
    dplyr::distinct() |>
    dplyr::pull()
  if (length(binaryVars) > 0) {
    notBinary <- character()
    for (binVar in binaryVars) {
      x <- table |>
        dplyr::select(dplyr::all_of(binVar)) |>
        dplyr::distinct() |>
        dplyr::pull()
      if (length(x) <= 3) {
        if (!all(as.numeric(x) %in% c(0, 1, NA))) {
          notBinary <- c(notBinary, binVar)
        }
      } else {
        notBinary <- c(notBinary, binVar)
      }
    }
    functions <- functions |>
      dplyr::filter(
        !.data$variable_name %in% .env$notBinary |
          !.data$estimate_name %in% c("count", "percentage")
      )
  }

  return(functions)
}

#' @noRd
checkCensorDate <- function(x, censorDate) {
  check <- x |>
    dplyr::select(dplyr::all_of(censorDate)) |>
    utils::head(1) |>
    dplyr::pull() |>
    inherits("Date")
  if (!check) {
    cli::cli_abort("{censorDate} is not a date variable")
  }
}

correctStrata <- function(strata, overall) {
  if (length(strata) == 0 | overall) {
    strata <- c(list(character()), strata)
  }
  strata <- unique(strata)
  return(strata)
}

assertNameStyle <- function(nameStyle,
                            values = list(),
                            call = parent.frame()) {
  # initial checks
  omopgenerics::assertCharacter(nameStyle, length = 1,
                                na = FALSE, minNumCharacter = 1, call = call)
  omopgenerics::assertList(values, named = TRUE)
  omopgenerics::assertClass(call, class = "environment")

  # check name style
  err <- character()
  for (k in seq_along(values)) {
    valk <- values[[k]]
    nm <- paste0("\\{", names(values)[k], "\\}")
    if (length(valk) > 1 & !grepl(pattern = nm, x = nameStyle)) {
      err <- c(err, paste0("{{", names(values)[k], "}}"))
    }
  }

  # error
  if (length(err) > 0) {
    names(err) <- rep("*", length(err))
    cli::cli_abort(
      message = c("The following elements are not present in nameStyle:", err),
      call = call
    )
  }

  return(invisible(nameStyle))
}

warnOverwriteColumns <- function(x, nameStyle, values = list()) {
  if (length(values) > 0) {
    nameStyle <- tidyr::expand_grid(!!!values) |>
      dplyr::mutate("tmp_12345" = glue::glue(.env$nameStyle)) |>
      dplyr::pull("tmp_12345") |>
      as.character() |>
      unique()
  }

  extraColumns <- colnames(x)[colnames(x) %in% nameStyle]
  if (length(extraColumns) > 0) {
    ms <- extraColumns
    names(ms) <- rep("*", length(ms))
    cli::cli_inform(message = c(
      "!" = "The following columns will be overwritten:", ms
    ))
    x <- x |> dplyr::select(!dplyr::all_of(extraColumns))
  }

  return(x)
}

# checks demographics
validateIndexDate <- function(indexDate, null, x, call) {
  if (null) {
    return(NULL)
  }
  omopgenerics::assertCharacter(indexDate, length = 1, call = call)
  if (!indexDate %in% colnames(x)) {
    cli::cli_abort("indexDate must be a column in x.", call = call)
  }
  xx <- x |>
    dplyr::select(dplyr::all_of(indexDate)) |>
    utils::head(1) |>
    dplyr::pull()
  if (!inherits(xx, "Date") && !inherits(xx, "POSIXt")) {
    cli::cli_abort("x[[{indexDate}]] is not a date column.", call = call)
  }
  return(indexDate)
}
validateColumn <- function(col, null = FALSE, call = parent.frame()) {
  if (null) {
    return(NULL)
  }

  nm <- paste0(substitute(col))

  err <- "{nm} must be a snake_case character string"
  if (!is.character(col)) cli::cli_abort(message = err, call = call)
  if (length(col) != 1) cli::cli_abort(message = err, call = call)
  if (is.na(col)) cli::cli_abort(message = err, call = call)

  scCol <- omopgenerics::toSnakeCase(col)

  if (scCol != col) {
    cli::cli_warn(
      c("!" = "{nm} has been modified to be snake_case, {col} -> {scCol}"),
      call = call
    )
  }

  return(scCol)
}
validateAgeMissingMonth <- function(ageMissingMonth, null, call) {
  if (null) {
    return(ageMissingMonth)
  }

  if (is.character(ageMissingMonth)) {
    ageMissingMonth <- as.numeric(ageMissingMonth)
  }
  omopgenerics::assertNumeric(ageMissingMonth, integerish = TRUE, min = 1, max = 12, call = call)
  ageMissingMonth <- as.integer(ageMissingMonth)

  return(ageMissingMonth)
}
validateAgeMissingDay <- function(ageMissingDay, null, call) {
  if (null) {
    return(ageMissingDay)
  }

  if (is.character(ageMissingDay)) {
    ageMissingDay <- as.numeric(ageMissingDay)
  }
  omopgenerics::assertNumeric(ageMissingDay, integerish = TRUE, min = 1, max = 12, call = call)
  ageMissingDay <- as.integer(ageMissingDay)

  return(ageMissingDay)
}
validateMissingValue <- function(x, null, call) {
  if (null) {
    return(NULL)
  }
  nm <- paste0(substitute(x))
  err <- "{nm} must be a character of length 1." |> rlang::set_names("!")
  if (!is.character(x)) cli::cli_abort(message = err, call = call)
  if (length(x) != 1) cli::cli_abort(message = err, call = call)
  return(x)
}
validateType <- function(x, null, call) {
  if (null) {
    return(NULL)
  }
  nm <- paste0(substitute(x))
  err <- "{nm} must be a choice between 'date' or 'days'." |>
    rlang::set_names("!")
  if (!is.character(x)) cli::cli_abort(message = err, call = call)
  if (length(x) != 1) cli::cli_abort(message = err, call = call)
  if (!x %in% c("date", "days")) cli::cli_abort(message = err, call = call)
  return(x)
}
validateName <- function(name, call = parent.frame()) {
  omopgenerics::assertCharacter(name, length = 1, null = TRUE, call = call)
}
