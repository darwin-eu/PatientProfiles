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

#' Summarise variables using a set of estimate functions. The output will be
#' a formatted summarised_result object.
#'
#' @param table Table with different records.
#' @param group List of groups to be considered.
#' @param includeOverallGroup TRUE or FALSE. If TRUE, results for an overall
#' group will be reported when a list of groups has been specified.
#' @param strata List of the stratifications within each group to be considered.
#' @param includeOverallStrata TRUE or FALSE. If TRUE, results for an overall
#' strata will be reported when a list of strata has been specified.
#' @param variables Variables to summarise, it can be a list to point to different
#' set of estimate names.
#' @param estimates Estimates to obtain, it can be a list to point to different
#' set of variables.
#' @param counts Whether to compute number of records and number of subjects.
#' @param weights Name of the column in the table that contains the weights to
#' be used when measuring the estimates.
#'
#' @return A summarised_result object with the summarised data of interest.
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#' library(dplyr)
#'
#' cdm <- mockPatientProfiles()
#' x <- cdm$cohort1 |>
#'   addDemographics() |>
#'   collect()
#' result <- summariseResult(x)
#' mockDisconnect(cdm = cdm)
#' }
#'
summariseResult <- function(table,
                            group = list(),
                            includeOverallGroup = FALSE,
                            strata = list(),
                            includeOverallStrata = TRUE,
                            variables = NULL,
                            estimates = c("min", "q25", "median", "q75", "max", "count", "percentage"),
                            counts = TRUE,
                            weights = NULL) {
  # initial checks
  checkTable(table)
  if (length(variables) == 0 & length(estimates) == 0 & counts == FALSE) {
    cli::cli_inform("No analyses were selected.")
    return(omopgenerics::emptySummarisedResult())
  }

  if (is.null(variables)) {
    variables <- colnames(table)
    variables <- variables[!grepl("_id", variables)]
    if (length(weights) > 0) {variables <- variables[variables != weights]}
  }

  if (inherits(table, "cdm_table")) {
    cdm_name <- omopgenerics::cdmName(omopgenerics::cdmReference(table))
  } else {
    cdm_name <- "unknown"
  }

  table <- table |>
    dplyr::ungroup()

  # create the summary for overall
  if (table |> utils::head(1) |> dplyr::tally() |> dplyr::pull() == 0) {
    if (counts) {
      result <- dplyr::tibble(
        "group_name" = "overall", "group_level" = "overall",
        "strata_name" = "overall", "strata_level" = "overall",
        "variable_name" = c("number_records", "number_subjects"),
        "variable_level" = NA_character_, "estimate_name" = "count",
        "estimate_type" = "integer", "estimate_value" = "0"
      )
    } else {
      result <- omopgenerics::emptySummarisedResult()
    }
  } else {
    if (!is.list(variables)) {
      variables <- list(variables)
    }
    if (!is.list(estimates)) {
      estimates <- list(estimates)
    }
    if (!is.list(group)) {
      group <- list(group)
    }
    if (!is.list(strata)) {
      strata <- list(strata)
    }
    checkStrata(group, table, type = "group")
    checkStrata(strata, table)
    functions <- checkVariablesFunctions(variables, estimates, table)

    if (!is.null(weights)) {
      omopgenerics::validateColumn(column = weights, x = table, type = "numeric")
      rlang::check_installed("Hmisc")
    }

    mes <- c("i" = "The following estimates will be computed:")
    variables <- functions$variable_name |> unique()
    for (vark in variables) {
      mes <- c(mes, "*" = paste0(
        vark, ": ", paste0(functions$estimate_name[functions$variable_name == vark], collapse = ", ")
      ))
    }
    cli::cli_inform(message = mes)

    # only required variables
    colOrder <- colnames(table)
    table <- table |>
      dplyr::select(dplyr::any_of(unique(c(
        unlist(strata), unlist(group), functions$variable_name, "person_id",
        "subject_id", weights
      ))))

    # collect if necessary
    if (length(weights) == 0) {
      if (identical(omopgenerics::sourceType(table), "sql server")) {
        estimatesCollect <- "q|median"
      } else {
        estimatesCollect <- "q"
      }
    } else {
      estimatesCollect <- "q|median|sd|mean"
    }
    collectFlag <- functions |>
      dplyr::filter(grepl(estimatesCollect, .data$estimate_name)) |>
      nrow() > 0
    if (collectFlag) {
      cli::cli_inform(c(
        "!" = "Table is collected to memory as not all requested estimates are
        supported on the database side"
      ))
      table <- table |> dplyr::collect()
    }

    # correct dates and logicals
    dates <- functions |>
      dplyr::filter(.data$variable_type %in% c("date", "logical")) |>
      dplyr::distinct(.data$variable_name) |>
      dplyr::pull()
    table <- table |>
      dplyr::mutate(dplyr::across(
        .cols = dplyr::all_of(dates),
        .fns = as.integer
      ))

    # correct strata and group
    group <- correctStrata(group, includeOverallGroup)
    strata <- correctStrata(strata, includeOverallStrata)

    cli::cli_alert("Start summary of data, at {Sys.time()}")
    nt <- length(group) * length(strata)
    k <- 0
    cli::cli_progress_bar(
      total = nt,
      format = "{cli::pb_bar}{k}/{nt} group-strata combinations @ {Sys.time()}"
    )

    personVariable <- NULL
    if (counts) {
      i <- "person_id" %in% colnames(table)
      j <- "subject_id" %in% colnames(table)
      if (i) {
        if (j) {
          cli::cli_warn(
            "person_id and subject_id present in table, `person_id` used as
            person identifier"
          )
        }
        personVariable <- "person_id"
      } else if (j) {
        personVariable <- "subject_id"
      }
    }

    resultk <- 1
    result <- list()
    for (groupk in group) {
      for (stratak in strata) {
        result[[resultk]] <- summariseInternal(
          table, groupk, stratak, functions, counts, personVariable, weights
        ) |>
          # order variables
          orderVariables(colOrder, unique(unlist(estimates)))
        resultk <- resultk + 1
        k <- k + 1
        cli::cli_progress_update()
      }
    }
    result <- result |> dplyr::bind_rows()
    cli::cli_inform(c("v" = "Summary finished, at {Sys.time()}"))
  }

  # TO REMOVE
  result$variable_name[result$variable_name == "number_subjects"] <- "number subjects"
  result$variable_name[result$variable_name == "number_records"] <- "number records"

  # format summarised_result
  result <- result |>
    dplyr::mutate(
      "result_id" = as.integer(1),
      "cdm_name" = .env$cdm_name,
      "additional_name" = "overall",
      "additional_level" = "overall"
    ) |>
    omopgenerics::newSummarisedResult(
      settings = dplyr::tibble(
        "result_id" = as.integer(1),
        "result_type" = "summarise_table",
        "package_name" = "PatientProfiles",
        "package_version" = as.character(utils::packageVersion("PatientProfiles")),
        "weights" = weights
      )
    )

  return(result)
}

summariseInternal <- function(table, groupk, stratak, functions, counts, personVariable, weights) {
  result <- list()

  # group by relevant variables
  strataGroupk <- unique(c(groupk, stratak))

  if (length(strataGroupk) == 0) {
    table <- table |>
      dplyr::mutate("strata_id" = 1L)
    strataGroup <- dplyr::tibble(
      "strata_id" = 1L,
      "group_name" = "overall",
      "group_level" = "overall",
      "strata_name" = "overall",
      "strata_level" = "overall"
    )
  } else {
    strataGroup <- table |>
      dplyr::select(dplyr::all_of(strataGroupk)) |>
      dplyr::distinct() |>
      dplyr::arrange(dplyr::across(dplyr::all_of(strataGroupk))) |>
      dplyr::mutate("strata_id" = dplyr::row_number()) |>
      dplyr::compute()
    table <- table |>
        dplyr::inner_join(strataGroup, by = strataGroupk)
    # format group strata
    strataGroup <- strataGroup |>
      dplyr::collect() |>
      omopgenerics::uniteGroup(
        cols = groupk, keep = TRUE, ignore = character()
      ) |>
      omopgenerics::uniteStrata(
        cols = stratak, keep = TRUE, ignore = character()
      ) |>
      dplyr::select(
        "strata_id", "group_name", "group_level", "strata_name", "strata_level"
      )
  }
  table <- table |>
    dplyr::select(dplyr::any_of(c(
      "strata_id", "person_id", "subject_id", unique(functions$variable_name), weights
    ))) |>
    dplyr::group_by(.data$strata_id)

  # count subjects and records
  if (counts) {
    result$counts <- countSubjects(table, personVariable, weights)
  }

  # summariseNumeric
  result$numeric <- summariseNumeric(table, functions, weights)

  # summariseBinary
  result$binary <- summariseBinary(table, functions, weights)

  # summariseCategories
  result$categories <- summariseCategories(table, functions, weights)

  # summariseMissings
  result$missings <- summariseMissings(table, functions, weights)

  result <- result |>
    dplyr::bind_rows() |>
    dplyr::inner_join(strataGroup, by = "strata_id") |>
    dplyr::select(-"strata_id") |>
    dplyr::arrange(.data$strata_level)

  return(result)
}

countSubjects <- function(x, personVariable, weights) {
  result <- list()
  #if (length(weights) == 0) {
    result$record <- x |>
      dplyr::summarise("estimate_value" = dplyr::n(), .groups = "drop") |>
      dplyr::collect() |>
      dplyr::mutate(
        "variable_name" = "number_records",
        "estimate_value" = sprintf("%.0f", as.numeric(.data$estimate_value))
      )
    if (!is.null(personVariable)) {
      result$subject <- x |>
        dplyr::summarise(
          "estimate_value" = dplyr::n_distinct(.data[[personVariable]]),
          .groups = "drop"
        ) |>
        dplyr::collect() |>
        dplyr::mutate(
          "variable_name" = "number_subjects",
          "estimate_value" = sprintf("%.0f", as.numeric(.data$estimate_value))
        )
    }
  # } else {
  #   result$record <- x |>
  #     dplyr::summarise(
  #       "estimate_value" = sum(.data[[weights]]),
  #       .groups = "drop"
  #     ) |>
  #     dplyr::collect() |>
  #     dplyr::mutate(
  #       "variable_name" = "number_records",
  #       "estimate_value" = sprintf("%.0f", as.numeric(.data$estimate_value))
  #     )
  #   if (!is.null(personVariable)) {
  #     result$subject <- x |>
  #       dplyr::group_by(.data[[personVariable]]) |>
  #       dplyr::summarise(
  #         estimate_value = max(.data[[weights]], na.rm = TRUE),
  #         .groups = "drop"
  #       ) |>
  #       dplyr::summarise(estimate_value = sum(.data$estimate_value)) |>
  #       dplyr::collect() |>
  #       dplyr::mutate(
  #         "variable_name" = "number_subjects",
  #         "estimate_value" = sprintf("%.0f", as.numeric(.data$estimate_value))
  #       )
  #   }
  # }
  result <- dplyr::bind_rows(result) |>
    dplyr::mutate(
      "estimate_type" = "integer",
      "estimate_name" = "count",
      "variable_level" = NA_character_
    )
  return(result)
}

summariseNumeric <- function(table, functions, weights) {
  functions <- functions |>
    dplyr::filter(
      .data$variable_type %in% c("date", "numeric", "integer") &
        !grepl("count|percentage", .data$estimate_name)
    )

  if (nrow(functions) == 0) {
    return(NULL)
  }

  if (length(weights) == 0) {
    estimatesFunctions <- estimatesFunc
  } else {
    estimatesFunctions <- estimatesFuncWeights
  }

  funs <- functions |>
    dplyr::filter(.data$estimate_name != "density")

  if (nrow(funs) > 0) {
    funs <- funs |>
      dplyr::mutate(fun = estimatesFunctions[.data$estimate_name]) |>
      dplyr::rowwise() |>
      dplyr::mutate(
        fun = gsub("\\(x", paste0("\\(.data[['", .data$variable_name, "']]"), .data$fun)
      ) |>
      dplyr::ungroup() |>
      dplyr::mutate(id = paste0("variable_", stringr::str_pad(dplyr::row_number(), 6, pad = "0")))
    numericSummary <- funs$fun |>
      rlang::parse_exprs() |>
      rlang::set_names(funs$id)
    res <- table |>
      dplyr::group_by(.data$strata_id) |>
      dplyr::summarise(!!!numericSummary, .groups = "drop") |>
      suppressWarnings() |>
      dplyr::collect() |>
      dplyr::mutate(dplyr::across(.cols = !"strata_id", .fns = as.numeric)) |>
      tidyr::pivot_longer(
        cols = !"strata_id", names_to = "id", values_to = "estimate_value"
      ) |>
      dplyr::inner_join(
        funs |>
          dplyr::select(c("id", "variable_name", "estimate_name", "estimate_type")),
        by = "id"
      ) |>
      dplyr::select(-"id") |>
      dplyr::mutate("variable_level" = NA_character_) |>
      correctTypes()
  } else {
    res <- NULL
  }

  functions <- functions |>
    dplyr::filter(.data$estimate_name == "density")

  if (nrow(functions) > 0) {
    res <- res |>
      dplyr::union_all(
        table |>
          dplyr::select(dplyr::all_of(c("strata_id", functions$variable_name, weights))) |>
          dplyr::collect() |>
          dplyr::group_by(.data$strata_id) |>
          dplyr::group_split() |>
          as.list() |>
          purrr::map_df(getDensityResult, weights) |>
          dplyr::inner_join(
            functions |>
              dplyr::select("variable_name", "estimate_type" = "variable_type") |>
              dplyr::mutate(estimate_type = dplyr::if_else(
                .data$estimate_type == "integer", "numeric", .data$estimate_type
              )),
            by = "variable_name"
          ) |>
          dplyr::mutate(estimate_type = dplyr::if_else(
            .data$estimate_name == "density_y", "numeric", .data$estimate_type
          )) |>
          correctTypes()
      )
  }

  return(res)
}

correctTypes <- function(x) {
  x |>
    dplyr::mutate(estimate_value = dplyr::case_when(
      # Inf and Nan generated due to missing values
      is.infinite(.data$estimate_value) | is.nan(.data$estimate_value) ~ NA_character_,
      # correct dates
      .data$estimate_type == "date" ~
        as.character(as.Date(round(.data$estimate_value), origin = "1970-01-01")),
      # round integers
      .data$estimate_type == "integer" ~
        as.character(round(.data$estimate_value)),
      # numeric to characters
      .data$estimate_type == "numeric" ~ as.character(.data$estimate_value)
    ))
}

getDensityResult <- function(x, weights) {
  w <- NULL
  if (length(weights) != 0) {
    w <- x |> dplyr::pull(.data[[weights]])
  }
  x |>
    dplyr::select(!dplyr::all_of(c("strata_id", weights))) |>
    as.list() |>
    purrr::map(densityResult, w) |>
    dplyr::bind_rows(.id = "variable_name") |>
    dplyr::mutate(strata_id = x$strata_id[1])
}
densityResult <- function(x, w) {
  nPoints <- 512
  nDigits <- ceiling(log(nPoints)/log(10))
  id <- !is.na(x)
  x <- as.numeric(x[id])
  if (length(x) == 0) {
    return(NULL)
  } else if (length(x) == 1) {
    den <- list(x = c(x - 1, x, x + 1), y = c(0, 1, 0)) # NEEDS DISCUSSION
  } else {
    # if-else to avoid warning when weights are NULL, but important to throw when non-null
    if (is.null(w)) {
      den <- stats::density(x, n = nPoints, na.rm = TRUE)
    } else {
      w <- as.numeric(w[id])
      den <- stats::density(x, n = nPoints, weights = w/sum(w), na.rm = TRUE)
    }

  }
  lev <- paste0("density_", stringr::str_pad(
    seq_along(den$x), width = nDigits, side = "left", pad = "0"))
  dplyr::tibble(
    variable_level = lev,
    estimate_name = "density_x",
    estimate_value = den$x
  ) |>
    dplyr::union_all(dplyr::tibble(
      variable_level = lev,
      estimate_name = "density_y",
      estimate_value = den$y
    )) |>
    dplyr::arrange(.data$variable_level, .data$estimate_name)
}

summariseBinary <- function(table, functions, weights) {
  binFuns <- functions |>
    dplyr::filter(
      .data$variable_type != "categorical" &
        .data$estimate_name %in% c("count", "percentage")
    )
  binNum <- binFuns |>
    dplyr::pull("variable_name") |>
    unique()
  if (length(weights) == 0) {
    weights <- omopgenerics::uniqueId(exclude = colnames(table))
    table <- table |>
      dplyr::mutate(!!weights := 1)
  }
  if (length(binNum) > 0) {
    num <- table |>
      dplyr::summarise(dplyr::across(
        .cols = dplyr::all_of(binNum),
        \(x) sum(x * !!dplyr::sym(weights), na.rm = TRUE),
        .names = "counts_{.col}"
      )) |>
      dplyr::collect() |>
      dplyr::mutate(dplyr::across(
        .cols = dplyr::all_of(paste0("counts_", binNum)),
        .fns = as.numeric
      ))
    binDen <- binFuns |>
      dplyr::filter(.data$estimate_name == "percentage") |>
      dplyr::pull("variable_name")
    res <- num |>
      tidyr::pivot_longer(
        cols = dplyr::all_of(paste0("counts_", binNum)),
        names_to = "variable_name",
        values_to = "estimate_value"
      ) |>
      dplyr::mutate(
        "variable_name" = substr(.data$variable_name, 8, nchar(.data$variable_name)),
        "estimate_name" = "count",
        "estimate_type" = "integer"
      )
    if (length(binDen) > 0) {
      den <- table |>
        dplyr::summarise(dplyr::across(
          .cols = dplyr::all_of(binDen),
          \(x) sum(as.integer(!is.na(x)) * !!dplyr::sym(weights), na.rm = TRUE),
          .names = "den_{.col}"
        )) |>
        dplyr::collect() |>
        dplyr::mutate(dplyr::across(
          .cols = dplyr::all_of(paste0("den_", binDen)),
          .fns = as.numeric
        ))
      percentages <- num |>
        tidyr::pivot_longer(
          cols = dplyr::all_of(paste0("counts_", binNum)),
          names_to = "variable_name",
          values_to = "numerator"
        ) |>
        dplyr::mutate(
          "variable_name" = substr(.data$variable_name, 8, nchar(.data$variable_name))
        ) |>
        dplyr::inner_join(
          den |>
            tidyr::pivot_longer(
              cols = dplyr::all_of(paste0("den_", binDen)),
              names_to = "variable_name",
              values_to = "denominator"
            ) |>
            dplyr::mutate(
              "variable_name" = substr(.data$variable_name, 5, nchar(.data$variable_name))
            ),
          by = c("strata_id", "variable_name")
        ) |>
        dplyr::mutate(
          "estimate_value" = 100 * .data$numerator / .data$denominator,
          "estimate_name" = "percentage",
          "estimate_type" = "percentage"
        ) |>
        dplyr::select(-c("numerator", "denominator"))
      res <- res |> dplyr::union_all(percentages)
    }

    res <- res |>
      dplyr::mutate(
        "estimate_value" = dplyr::if_else(
          is.infinite(.data$estimate_value) | is.nan(.data$estimate_value),
          NA_character_, as.character(.data$estimate_value)
        ),
        "variable_level" = NA_character_
      )
  } else {
    res <- NULL
  }

  return(res)
}

summariseCategories <- function(table, functions, weights) {
  catFuns <- functions |>
    dplyr::filter(.data$variable_type == "categorical")
  result <- list()
  catVars <- unique(catFuns$variable_name)
  if (length(weights) == 0) {
    weights <- omopgenerics::uniqueId(exclude = colnames(table))
    table <- table |>
      dplyr::mutate(!!weights := 1)
  }
  if (length(catVars) > 0) {
    den <- table |>
      dplyr::summarise("denominator" = sum(.data[[weights]], na.rm = TRUE), .groups = "drop") |>
      dplyr::collect()
    for (catVar in catVars) {
      est <- catFuns |>
        dplyr::filter(.data$variable_name == .env$catVar) |>
        dplyr::pull("estimate_name")
      result[[catVar]] <- table |>
        dplyr::group_by(.data$strata_id, .data[[catVar]]) |>
        dplyr::summarise("count" = sum(.data[[weights]], na.rm = TRUE), .groups = "drop") |>
        dplyr::collect() |>
        dplyr::inner_join(den, by = "strata_id") |>
        dplyr::mutate(
          "percentage" = as.character(100 * .data$count / .data$denominator),
          "count" = as.character(.data$count)
        ) |>
        dplyr::select(!"denominator") |>
        tidyr::pivot_longer(
          cols = c("count", "percentage"),
          names_to = "estimate_name",
          values_to = "estimate_value"
        ) |>
        dplyr::mutate(
          "variable_name" = .env$catVar,
          "estimate_type" = dplyr::if_else(
            .data$estimate_name == "count", "integer", "percentage"
          )
        ) |>
        dplyr::select(
          "strata_id", "variable_name",
          "variable_level" = dplyr::all_of(catVar), "estimate_name",
          "estimate_type", "estimate_value"
        ) |>
        dplyr::filter(.data$estimate_name %in% .env$est)
    }
  }
  return(dplyr::bind_rows(result))
}

summariseMissings <- function(table, functions, weights) {
  result <- list()
  if (length(weights) == 0) {
    weights <- omopgenerics::uniqueId(exclude = colnames(table))
    table <- table |>
      dplyr::mutate(!!weights := 1)
  }
  # counts
  mVars <- functions |>
    dplyr::filter(.data$estimate_name %in% c("count_missing", "percentage_missing")) |>
    dplyr::pull("variable_name") |>
    unique()
  if (length(mVars) > 0) {
    result <- table |>
      dplyr::summarise(
        dplyr::across(
          .cols = dplyr::all_of(mVars),
          ~ sum(as.integer(is.na(.x))*.data[[weights]], na.rm = TRUE),
          .names = "cm_{.col}"
        ),
        "den" = sum(.data[[weights]], na.rm = TRUE)
      ) |>
      dplyr::collect() |>
      dplyr::mutate(dplyr::across(
        .cols = dplyr::all_of(c("den", paste0("cm_", mVars))),
        .fns = as.numeric
      )) |>
      tidyr::pivot_longer(
        cols = dplyr::all_of(paste0("cm_", mVars)),
        names_to = "variable_name",
        values_to = "count_missing"
      ) |>
      dplyr::mutate("percentage_missing" = 100 * .data$count_missing / .data$den) |>
      dplyr::select(-"den") |>
      tidyr::pivot_longer(
        cols = c("count_missing", "percentage_missing"),
        names_to = "estimate_name",
        values_to = "estimate_value"
      ) |>
      dplyr::mutate(
        "variable_name" = substr(.data$variable_name, 4, nchar(.data$variable_name)),
        "variable_level" = NA_character_,
        "estimate_value" = dplyr::if_else(
          is.infinite(.data$estimate_value) | is.nan(.data$estimate_value),
          NA_character_, as.character(.data$estimate_value)
        )
      ) |>
      dplyr::inner_join(
        functions |>
          dplyr::filter(.data$estimate_name %in% c("count_missing", "percentage_missing")) |>
          dplyr::select("variable_name", "estimate_name", "estimate_type"),
        by = c("variable_name", "estimate_name")
      )
  } else {
    result <- NULL
  }
  return(result)
}

orderVariables <- function(res, cols, est) {
  if (length(est) == 0) {
    return(res)
  }
  orderVars <- dplyr::tibble("variable_name" = c(
    "number_records", "number_subjects", cols
  )) |>
    dplyr::mutate("id_variable" = dplyr::row_number())
  orderEst <- dplyr::tibble("estimate_name" = est) |>
    dplyr::mutate("id_estimate" = dplyr::row_number())
  res <- res |>
    dplyr::left_join(orderVars, by = c("variable_name")) |>
    dplyr::left_join(orderEst, by = c("estimate_name")) |>
    dplyr::arrange(.data$id_variable, .data$id_estimate, .data$variable_level) |>
    dplyr::select(-c("id_variable", "id_estimate"))
  return(res)
}
