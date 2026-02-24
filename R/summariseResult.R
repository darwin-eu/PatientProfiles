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
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' x <- cdm$cohort1 |>
#'   addDemographics()
#'
#' # summarise all variables with default estimates
#' result <- summariseResult(x)
#' result
#'
#' # get only counts of records and subjects
#' result <- summariseResult(x, variables = character())
#' result
#'
#' # specify variables and estimates
#' result <- summariseResult(
#'   table = x,
#'   variables = c("cohort_start_date", "age"),
#'   estimates = c("mean", "median", "density")
#' )
#' result
#'
#' # different estimates for each variable
#' result <- summariseResult(
#'   table = x,
#'   variables = list(c("age", "prior_observation"), "sex"),
#'   estimates = list(c("min", "max"), c("count", "percentage"))
#' )
#'
#' }
#'
summariseResult <- function(table,
                            group = list(),
                            includeOverallGroup = FALSE,
                            strata = list(),
                            includeOverallStrata = TRUE,
                            variables = NULL,
                            estimates = NULL,
                            counts = TRUE,
                            weights = NULL) {
  # initial checks
  omopgenerics::assertTable(x = table, class = "tbl")
  noVariables <- !is.null(variables) & length(variables) == 0
  noEstimates <- !is.null(estimates) & length(as.character(unlist(estimates))) == 0
  if ((noVariables | noEstimates) & counts == FALSE) {
    cli::cli_inform("No analyses were selected.")
    return(omopgenerics::emptySummarisedResult())
  }

  if (inherits(table, "cdm_table")) {
    cdm_name <- omopgenerics::cdmName(table)
  } else {
    cdm_name <- "unknown"
    table <- omopgenerics::newCdmTable(
      table = table,
      src = omopgenerics::newLocalSource(),
      name = "temp"
    )
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
    if (!is.list(group)) {
      group <- list(group)
    }
    if (!is.list(strata)) {
      strata <- list(strata)
    }
    checkStrata(group, table, type = "group")
    checkStrata(strata, table)
    functions <- checkVariablesFunctions(variables, estimates, table, weights)

    if (!"person_id" %in% colnames(table)) {
      functions <- functions |>
        dplyr::filter(!.data$estimate_name %in% c("count_person", "percentage_person"))
    }
    if (!"subject_id" %in% colnames(table)) {
      functions <- functions |>
        dplyr::filter(!.data$estimate_name %in% c("count_subject", "percentage_subject"))
    }

    if (!is.null(weights)) {
      omopgenerics::validateColumn(column = weights, x = table, type = "numeric")
      rlang::check_installed("Hmisc")
    }

    if (nrow(functions) == 0) {
      if (counts) {
        calculate <- TRUE
      } else {
        calculate <- FALSE
        cli::cli_inform(c("!" = "No estimates will be calculated, returning empty result."))
      }
    } else {
      mes <- c("i" = "The following estimates will be calculated:")
      variables <- functions$variable_name |> unique()
      for (vark in variables) {
        mes <- c(mes, "*" = paste0(
          vark, ": ", paste0(functions$estimate_name[functions$variable_name == vark], collapse = ", ")
        ))
      }
      calculate <- TRUE
      cli::cli_inform(message = mes)
    }

    # stop if no estimate needs to be calculated
    if (calculate) {
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
          estimatesCollect <- "q|median|density"
        } else {
          estimatesCollect <- "q|density"
        }
      } else {
        estimatesCollect <- "q|median|sd|mean|density"
      }
      collectFlag <- functions |>
        dplyr::filter(grepl(estimatesCollect, .data$estimate_name)) |>
        nrow() > 0
      # collect also if dates are present
      collectFlag <- collectFlag | any(functions$variable_type == "date")
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
        if ("person_id" %in% colnames(table)) {
          if ("subject_id" %in% colnames(table)) {
            cli::cli_warn(
              "person_id and subject_id present in table, `person_id` used as
            person identifier"
            )
          }
          personVariable <- "person_id"
        } else if ("subject_id" %in% colnames(table)) {
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
    } else {
      result <- omopgenerics::emptySummarisedResult()
    }
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
    result$counts_subjects <- countSubjects(table, personVariable, weights)
  }

  # summariseNumeric
  result$numeric <- summariseNumeric(table, functions, weights)

  # summariseCategories
  result$categories <- summariseCategories(table, functions, weights)

  # summariseCounts
  result$counts <- summariseCounts(table, functions, weights)

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
        !startsWith(.data$estimate_name, "count") &
        !startsWith(.data$estimate_name, "percentage")
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
    res <- dplyr::tibble(
      variable_level = character(),
      estimate_name = character(),
      estimate_value = numeric()
    )
    return(res)
  } else if (length(x) == 1) {
    den <- list(x = c(x - 1, x, x + 1), y = c(0, 1, 0)) # NEEDS DISCUSSION
  } else {
    # Limit the x values of the density estimation to the 0.005 to 0.995 percentiles of the distribution
    qs <- stats::quantile(x, c(0.005, 0.995), na.rm = TRUE)
    # if-else to avoid warning when weights are NULL, but important to throw when non-null
    if (is.null(w)) {
      den <- stats::density(x, n = nPoints, from = qs[1], to = qs[2], na.rm = TRUE)
    } else {
      w <- as.numeric(w[id])
      den <- stats::density(x, n = nPoints, from = qs[1], to = qs[2], weights = w/sum(w), na.rm = TRUE)
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

summariseCategories <- function(table, functions, weights) {
  catFuns <- functions |>
    dplyr::filter(.data$variable_type == "categorical")

  result <- list()

  # count_person, count_subject
  catSubj <- catFuns |>
    dplyr::filter(.data$estimate_name %in% c("count_subject", "count_person"))
  if (nrow(catSubj) > 0) {
    estimates <- c(
      "count_subject" = "as.numeric(dplyr::n_distinct(.data$subject_id))",
      "count_person" = "as.numeric(dplyr::n_distinct(.data$person_id))"
    )
    vars <- unique(catSubj$variable_name)
    for (var in vars) {
      est <- catSubj |>
        dplyr::filter(.data$variable_name == .env$var) |>
        dplyr::pull("estimate_name")
      q <- rlang::parse_exprs(estimates[est])
      result[[paste0(var, "_count")]] <- table |>
        dplyr::group_by(.data$strata_id, .data[[var]]) |>
        dplyr::summarise(!!!q, .groups = "drop") |>
        dplyr::collect() |>
        tidyr::pivot_longer(
          cols = dplyr::all_of(names(q)),
          names_to = "estimate_name",
          values_to = "estimate_value"
        ) |>
        dplyr::rename("variable_level" = dplyr::all_of(var)) |>
        dplyr::mutate(
          "estimate_value" = sprintf("%.0f", .data$estimate_value),
          "estimate_type" = "integer",
          "variable_name" = .env$var
        )
    }
  }

  # count and percentage
  catFuns <- catFuns |>
    dplyr::filter(.data$estimate_name %in% c("count", "percentage"))
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

        # TO BE REMOVED https://github.com/OHDSI/MeasurementDiagnostics/issues/136
        dplyr::filter(!is.na(.data[[catVar]])) |>

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

summariseCounts <- function(table, functions, weights) {
  # estimates
  estimates <- names(estimatesFunc) |>
    purrr::keep(\(x) startsWith(x = x, prefix = "count"))
  estimates <- c(estimates, gsub("^count", "percentage", estimates))

  # counts
  functs <- functions |>
    dplyr::filter(
      .data$variable_type %in% c("integer", "numeric", "date", "logical") &
        .data$estimate_name %in% .env$estimates
    ) |>
    dplyr::select("variable_name", "estimate_name", "estimate_type")

  # check if estimates need to be calculated
  if (nrow(functs) > 0) {

    # assign denominators
    functs <- functs |>
      dplyr::mutate(den = dplyr::case_when(
        grepl("count", .data$estimate_name) ~ NA_character_,
        length(.env$weights) == 0 & grepl("missing", .data$estimate_name) ~ "as.numeric(dplyr::n())",
        length(.env$weights) == 0 & !grepl("missing", .data$estimate_name) ~ paste0("as.numeric(sum(dplyr::if_else(is.na(.data[['", .data$variable_name,"']]), 0, 1), na.rm = TRUE))"),
        length(.env$weights) != 0 & grepl("missing", .data$estimate_name) ~ "as.numeric(sum(.data[[weights]], na.rm = TRUE))",
        length(.env$weights) != 0 & !grepl("missing", .data$estimate_name) ~ paste0("as.numeric(sum(dplyr::if_else(is.na(.data[['", .data$variable_name,"']]), 0, .data[[weights]]), na.rm = TRUE))")
      ))

    # assign denominator name
    dens <- functs |>
      dplyr::distinct(.data$den) |>
      dplyr::filter(!is.na(.data$den)) |>
      dplyr::mutate(den_name = paste0("den_", dplyr::row_number()))
    functs <- functs |>
      dplyr::left_join(dens, by = "den")

    # assign numerator
    functs <- functs |>
      dplyr::mutate(num = dplyr::case_when(
        length(.env$weights) == 0 ~ estimatesFunc[gsub("percentage", "count", .data$estimate_name)],
        length(.env$weights) != 0 ~ estimatesFuncWeights[gsub("percentage", "count", .data$estimate_name)]
      )) |>
      dplyr::rowwise() |>
      dplyr::mutate(num = gsub(
        "\\(x", paste0("\\(.data[['", .data$variable_name, "']]"), .data$num
      )) |>
      dplyr::ungroup() |>
      dplyr::mutate(num = paste0("as.numeric(", .data$num, ")"))

    # assign numerator name
    nums <- functs |>
      dplyr::distinct(.data$num) |>
      dplyr::mutate(num_name = paste0("num_", dplyr::row_number()))
    functs <- functs |>
      dplyr::left_join(nums, by = "num")

    # make calculations
    estimates <- functs |>
      dplyr::select("value" = "num", "name" = "num_name") |>
      dplyr::union_all(
        functs |>
          dplyr::select("value" = "den", "name" = "den_name")
      ) |>
      dplyr::distinct() |>
      dplyr::filter(!is.na(.data$value))
    q <- estimates$value |>
      rlang::parse_exprs() |>
      rlang::set_names(nm = estimates$name)
    est <- table |>
      dplyr::summarise(!!!q) |>
      dplyr::collect() |>
      tidyr::pivot_longer(cols = dplyr::all_of(names(q)))

    # add numerators and denominator back to functs
    functs <- functs |>
      dplyr::select(!c("den", "num")) |>
      dplyr::left_join(
        est |>
          dplyr::select("num" = "value", "num_name" = "name", "strata_id"),
        by = "num_name"
      ) |>
      dplyr::left_join(
        est |>
          dplyr::select("den" = "value", "den_name" = "name", "strata_id"),
        by = c("den_name", "strata_id")
      )

    # format results
    result <- functs |>
      dplyr::mutate(
        variable_level = NA_character_,
        estimate_value = dplyr::case_when(
          grepl("count", .data$estimate_name) & is.null(weights) ~ sprintf("%.0f", .data$num),
          grepl("count", .data$estimate_name) & !is.null(weights) ~ sprintf("%.3f", .data$num),
          is.na(.data$den) | .data$den == 0 ~ NA_character_,
          .default = as.character(100 * .data$num / .data$den)
        )
      ) |>
      dplyr::select(!c("num", "num_name", "den", "den_name"))
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
