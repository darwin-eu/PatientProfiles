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

#' Categorize a numeric variable
#'
#' @param x Table with individuals in the cdm.
#' @param variable Target variable that we want to categorize.
#' @param categories List of lists of named categories with lower and upper
#' limit.
#' @param missingCategoryValue Value to assign to those individuals not in
#' any named category. If NULL or NA, missing values will not be changed.
#' @param overlap TRUE if the categories given overlap.
#' @param includeLowerBound Whether to include the lower bound in the group.
#' @param includeUpperBound Whether to include the upper bound in the group.
#' @param name Name of the new table, if NULL a temporary table is returned.
#'
#' @return The x table with the categorical variable added.
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(PatientProfiles)
#'
#' cdm <- mockPatientProfiles(source = "duckdb")
#'
#' result <- cdm$cohort1 |>
#'   addAge() |>
#'   addCategories(
#'     variable = "age",
#'     categories = list("age_group" = list(
#'       "0 to 39" = c(0, 39), "40 to 79" = c(40, 79), "80 to 150" = c(80, 150)
#'     ))
#'   )
#'
#' }
addCategories <- function(x,
                          variable,
                          categories,
                          missingCategoryValue = "None",
                          overlap = FALSE,
                          includeLowerBound = TRUE,
                          includeUpperBound = TRUE,
                          name = NULL) {
  comp <- newTable(name)
  omopgenerics::assertClass(x, class = "cdm_table")
  variable <- omopgenerics::validateColumn(variable, x = x, type = c("date", "numeric", "integer"))
  omopgenerics::assertList(categories, class = "list")
  omopgenerics::assertCharacter(missingCategoryValue, length = 1, na = TRUE)
  omopgenerics::assertLogical(includeLowerBound, length = 1)
  omopgenerics::assertLogical(includeUpperBound, length = 1)

  # check names
  if (length(unique(names(categories))) < length((names(categories)))) {
    "Categories have repeated names, please rename the groups." |>
      cli::cli_abort()
  }
  if (is.null(names(categories))) {
    names(categories) <- paste0("category_", seq_along(categories))
  }

  # validate new columns
  x <- omopgenerics::validateNewColumn(x, names(categories), validation = "error")

  # get signs
  le <- if (includeLowerBound) "<=" else "<"
  ue <- if (includeUpperBound) "<=" else "<"
  if (is.na(missingCategoryValue)) {
    miss <- 'NA_character_'
  } else {
    miss <- paste0('"', missingCategoryValue, '"')
  }

  # check if date
  date <- x |>
    utils::head(1) |>
    dplyr::pull(dplyr::all_of(variable)) |>
    dplyr::type_sum() |>
    assertClassification() == "date"
  if (date) {
    id <- omopgenerics::uniqueId(n = 2, exclude = colnames(x))
    x <- x |>
      dplyr::mutate(!!id[1] := !!as.Date("1970-01-01", format = "%Y-%m-%d")) |>
      dplyr::mutate(!!id[2] := clock::date_count_between(start = .data[[id[1]]], end = .data[[variable]], precision = "day")) |>
      dplyr::select(-dplyr::all_of(id[1]))
    variable <- id[2]
    categories <- categories |>
      purrr::map(\(x) purrr::map(x, as.numeric))
  }

  # check categories
  categoryTibble <- purrr::map(categories, \(category) {
    omopgenerics::assertList(category, class = "numeric")
    if (is.null(names(category))) {
      names(category) <- rep("", length(category))
    }
    category <- purrr::map(category, \(x) if (length(x) == 1) c(x, x) else x)
    if (any(lengths(category) != 2)) {
      "Please specify two values per category (lower bound and upper bound)" |>
        cli::cli_abort()
    }
    xf <- purrr::map_dbl(category, \(x) if (is.infinite(x[1])) NA else x[1])
    xs <- purrr::map_dbl(category, \(x) if (is.infinite(x[2])) NA else x[2])
    if (any(xf > xs & !is.na(xf) & !is.na(xs))) {
     cli::cli_abort("Lower bound must be smaller than upper bound")
    }
    res <- dplyr::tibble(
      lower_bound = .env$xf,
      upper_bound = .env$xs,
      category_label = names(category)
    ) |>
      dplyr::mutate(category_label = dplyr::if_else(
        .data$category_label == "",
        categoryName(.data$lower_bound, .data$upper_bound, date),
        .data$category_label
      ))
    ov <- detectOverlap(category, includeLowerBound & includeUpperBound)
    if (ov) {
      if (!overlap) {
        "There is overlap between categories, please use overlap = TRUE or provide non overlaping categories" |>
          cli::cli_abort()
      } else {
        res <- createNonOverlapingCategories(res)
      }
    }
    res |>
      dplyr::arrange(.data$lower_bound)
  })

  # create query
  q <- categoryTibble |>
    purrr::map_chr(\(x) {
      cond <- purrr::map_chr(seq_len(nrow(x)), \(k) {
        low <- x$lower_bound[k]
        up <- x$upper_bound[k]
        category <- x$category_label[k]
        condition(variable, low, up, le, ue) |>
          purrr::map_chr(\(x) paste0(x, ' ~ "', category, '"'))
      })
      cond <- c(
        cond,
        # handle NA's
        paste0('is.na(.data[["', variable, '"]]) ~ NA_character_'),
        # default
        paste0('.default = ', miss)
      )
      paste0("dplyr::case_when(", paste0(cond, collapse = ", "), ")")
    }) |>
    rlang::parse_exprs()

  x <- x |>
    dplyr::mutate(!!!q)

  if (date) {
    x <- x |>
      dplyr::select(!dplyr::all_of(variable))
  }

  x <- x |>
    dplyr::compute(name = comp$name, temporary = comp$temporary)

  return(x)
}
detectOverlap <- function(groups, bothIncluded) {
  tib <- purrr::map_df(groups, \(x) dplyr::tibble(min = x[1], max = x[2])) |>
    dplyr::mutate(next_min = dplyr::lead(.data$min, order_by = .data$min)) |>
    dplyr::filter(!is.na(.data$next_min))
  if (bothIncluded) {
    overlap <- any(tib$next_min <= tib$max)
  } else {
    overlap <- any(tib$next_min < tib$max)
  }
  return(overlap)
}
condition <- function(variable, low, up, le, ue) {
  if (is.na(low)) {
    if (is.na(up)) {
      x <- 'TRUE'
    } else {
      x <- '.data[["{variable}"]] {ue} {up}'
    }
  } else {
    if (is.na(up)) {
      x <- '{low} {le} .data[["{variable}"]]'
    } else {
      x <- '{low} {le} .data[["{variable}"]] & .data[["{variable}"]] {ue} {up}'
    }
  }
  glue::glue(x)
}
createNonOverlapingCategories <- function(res, both) {
  bounds <- sort(unique(c(res$upper_bound, res$lower_bound)))
  id <- seq_len(length(bounds) - 1)
  dplyr::tibble(
    lower_bound = bounds[id], upper_bound = bounds[id + 1]
  ) |>
    dplyr::cross_join(
      res |>
        dplyr::rename(
          group_lower_bound = "lower_bound", group_upper_bound = "upper_bound"
        )
    ) |>
    dplyr::filter(
      .data$group_lower_bound < .data$upper_bound &
        .data$lower_bound < .data$group_upper_bound
    ) |>
    dplyr::group_by(.data$lower_bound, .data$upper_bound) |>
    dplyr::summarise(
      category_label = paste0(.data$category_label, collapse = " and "),
      .groups = "drop"
    )
}
categoryName <- function(low, upp, date) {
  purrr::map2_chr(low, upp, \(l, u) {
    if (date) {
      u <- as.Date(u, origin = "1970-01-01")
      l <- as.Date(l, origin = "1970-01-01")
    }
    if (is.na(l)) {
      if (is.na(u)) {
        "any"
      } else {
        paste0(u, " or below")
      }
    } else {
      if (is.na(u)) {
        paste0(l, " or above")
      } else {
        paste0(l, " to ", u)
      }
    }
  })
}
