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

.addEvent <- function(x,
                      tableName,
                      filterVariable,
                      filterId,
                      idName,
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

  comp <- newTable(name = name, call = call)
  prefix <- omopgenerics::tmpPrefix()
  if (!is.list(window)) {
    window <- list(window)
  }

  x <- omopgenerics::validateCdmTable(table = x, call = call)
  indexDateInput <- materialiseIndexDate(
    indexDate = indexDate, x = x, call = call
  )
  x <- indexDateInput$x
  indexDate <- indexDateInput$indexDate
  cdm <- omopgenerics::cdmReference(x)

  omopgenerics::assertCharacter(tableName, length = 1, na = FALSE, call = call)
  omopgenerics::validateCdmArgument(cdm = cdm, requiredTables = c(tableName, "observation_period"), call = call)
  checkVariableInX(indexDate, x, name = "indexDate", call = call)
  checkVariableInX(censorDate, x, nullOk = TRUE, name = "censorDate", call = call)
  checkVariableInX(targetDate, cdm[[tableName]], name = "targetDate", call = call)
  if (!is.null(censorDate)) {
    checkCensorDate(x = x, censorDate = censorDate, call = call)
  }
  omopgenerics::assertChoice(order, choices = c("first", "last"), length = 1, call = call)
  window <- omopgenerics::validateWindowArgument(window, call = call)

  filterTbl <- checkFilter(filterVariable, filterId, idName, cdm[[tableName]], call = call)

  # prepare event formatting
  eventNames <- filterTbl$id_name
  msg <- "`multipleEvents` must be `TRUE`, `NULL`, or a character vector indicating an order of events."
  if (!isTRUE(multipleEvents)) {
    combineEvents <- FALSE
    if (is.null(multipleEvents)) {
      eventOrder <- sort(eventNames)
    } else {
      omopgenerics::assertChoice(multipleEvents, choices = eventNames, call = call, unique = TRUE, msg = msg)
      eventOrder <- c(multipleEvents, sort(setdiff(eventNames, multipleEvents)))
    }
  } else {
    combineEvents <- TRUE
    eventOrder <- eventNames
  }

  values <- list(
    value = c("event", output),
    window_name = names(window)
  )
  assertNameStyle(nameStyle = nameStyle, values = values, call = call)
  newColumns <- tidyr::expand_grid(!!!values) |>
    dplyr::mutate(column = as.character(glue::glue(.env$nameStyle))) |>
    dplyr::mutate(column = omopgenerics::toSnakeCase(.data$column)) |>
    dplyr::pull("column")
  x <- warnOverwriteColumns(x = x, nameStyle = newColumns)

  personVariable <- omopgenerics::getPersonIdentifier(x = x, call = call)
  targetPersonVariable <- omopgenerics::getPersonIdentifier(x = cdm[[tableName]], call = call)

  resultKey <- c("person_id", "index_date")
  joinKey <- c(personVariable, indexDate)
  if (!is.null(censorDate)) {
    resultKey <- c(resultKey, "censor_date")
    joinKey <- c(joinKey, censorDate)
  }
  selectKey <- rlang::set_names(x = joinKey, nm = resultKey)

  nmi <- omopgenerics::uniqueTableName(prefix = prefix)
  xi <- x |>
    dplyr::select(dplyr::all_of(selectKey)) |>
    dplyr::distinct() |>
    dplyr::inner_join(
      cdm$observation_period |>
        dplyr::select(
          "person_id",
          "obs_start" = "observation_period_start_date",
          "obs_end" = "observation_period_end_date"
        ),
      by = "person_id"
    ) |>
    dplyr::filter(
      .data$obs_start <= .data$index_date &
        .data$index_date <= .data$obs_end
    )

  if (!is.null(censorDate)) {
    xi <- xi |>
      dplyr::mutate(
        days_to_start = as.numeric(clock::date_count_between(
          start = .data$index_date, end = .data$obs_start, precision = "day"
        )),
        days_to_end = as.numeric(clock::date_count_between(
          start = .data$index_date, end = .data$obs_end, precision = "day"
        )),
        days_to_censor = as.numeric(clock::date_count_between(
          start = .data$index_date, end = .data$censor_date, precision = "day"
        ))
      )
  } else {
    xi <- xi |>
      dplyr::mutate(
        days_to_start = as.numeric(clock::date_count_between(
          start = .data$index_date, end = .data$obs_start, precision = "day"
        )),
        days_to_end = as.numeric(clock::date_count_between(
          start = .data$index_date, end = .data$obs_end, precision = "day"
        ))
      )
  }

  xi <- xi |>
    dplyr::compute(name = nmi)

  targetSelect <- c(targetPersonVariable, filterVariable, targetDate) |>
    rlang::set_names(c("person_id", "event_id", "target_date"))
  targets <- cdm[[tableName]] |>
    dplyr::select(dplyr::all_of(targetSelect)) |>
    dplyr::filter(.data$event_id %in% .env$filterId)

  # find all results
  result <- xi |>
    dplyr::inner_join(targets, by = "person_id")

  # add target name
  nmt <- omopgenerics::uniqueTableName(prefix = prefix)
  filterTbl <- filterTbl |>
    dplyr::rename("event_id" = "id", "event_name" = "id_name")
  cdm <- omopgenerics::insertTable(cdm = cdm, name = nmt, table = filterTbl)
  result <- result |>
    dplyr::inner_join(cdm[[nmt]], by = "event_id")

  # censor
  if (!is.null(censorDate)) {
    result <- result |>
      dplyr::filter(
        .data$obs_start <= .data$target_date &
          .data$target_date <= .data$obs_end &
          (is.na(.data$censor_date) | .data$target_date <= .data$censor_date)
      )
  } else {
    result <- result |>
      dplyr::filter(
        .data$obs_start <= .data$target_date &
          .data$target_date <= .data$obs_end
      )
  }

  # calculate days
  result <- result |>
    dplyr::mutate(days = as.numeric(clock::date_count_between(
      start = .data$index_date, end = .data$target_date, precision = "day"
    ))) |>
    dplyr::select(dplyr::all_of(resultKey), "days", "event_name")

  # filter window
  overallWindow <- c(min(purrr::map_dbl(window, 1)), max(purrr::map_dbl(window, 2)))
  result <- result |>
    filterWindow(overallWindow) |>
    dplyr::compute(name = omopgenerics::uniqueTableName(prefix = prefix))

  # prepare solve events
  eventTies <- prepareSolveEvents(cdm, combineEvents, eventOrder, prefix)

  for (i in seq_along(window)) {

    win <- window[[i]]
    eventColumn <- nameStyle |>
      glue::glue(value = "event", window_name = names(window)[i]) |>
      as.character() |>
      omopgenerics::toSnakeCase()
    valueColumn <- nameStyle |>
      glue::glue(value = output, window_name = names(window)[i]) |>
      as.character() |>
      omopgenerics::toSnakeCase()

    events <- result |>
      filterWindow(win) |>
      dplyr::group_by(dplyr::across(dplyr::all_of(resultKey)))
    if (order == "first") {
      events <- events |>
        dplyr::filter(.data$days == min(.data$days, na.rm = TRUE))
    } else {
      events <- events |>
        dplyr::filter(.data$days == max(.data$days, na.rm = TRUE))
    }

    # get events
    events <- events |>
      pivotEvents(eventOrder) |>
      dplyr::compute(name = omopgenerics::uniqueTableName(prefix = prefix))

    # solve event ties
    events <- solveEvents(events, eventTies, eventColumn) |>
      dplyr::select(dplyr::all_of(c(
        resultKey, rlang::set_names("days", valueColumn), eventColumn
      ))) |>
      dplyr::compute(name = omopgenerics::uniqueTableName(prefix = prefix))

    # add it to xi
    xi <- xi |>
      dplyr::left_join(events, by = resultKey) |>
      dplyr::compute(name = nmi)

    # add censor and end of observation
    xi <- xi |>
      addCensorEvent(
        censorDate = censorDate,
        valueColumn = valueColumn,
        eventColumn = eventColumn,
        order = order,
        win = win
      ) |>
      # convert to date if needed
      prepareOutput(output, valueColumn) |>
      dplyr::compute(name = nmi)
  }

  # add values to original table
  selectKey <- rlang::set_names(x = resultKey, nm = joinKey)
  outputColumns <- purrr::map_chr(names(window), \(windowName) {
    nameStyle |>
      glue::glue(value = output, window_name = windowName) |>
      as.character() |>
      omopgenerics::toSnakeCase()
  })
  x <- x |>
    dplyr::inner_join(
      xi |>
        dplyr::select(dplyr::all_of(c(selectKey, newColumns))),
      by = joinKey
    ) |>
    removeMaterialisedIndexDate(indexDateInput = indexDateInput)

  x <- .convertColumnType(
    x = x,
    columns = outputColumns,
    type = type
  ) |>
    dplyr::compute(name = comp$name, temporary = comp$temporary)

  omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(prefix))

  return(x)
}
addCensorEvent <- function(x, censorDate, valueColumn, eventColumn, order, win) {
  if (!is.null(censorDate)) {
    x <- x |>
      dplyr::mutate(
        !!valueColumn := dplyr::case_when(
          !is.na(.data[[valueColumn]]) ~ .data[[valueColumn]],
          !!(order == "last") & .data$days_to_start >= !!win[1] ~ .data$days_to_start,
          !!(order == "last") ~ !!win[1],
          !is.na(.data$days_to_censor) &
            .data$days_to_censor <= .data$days_to_end &
            .data$days_to_censor <= !!win[2] ~ .data$days_to_censor,
          .data$days_to_end <= !!win[2] ~ .data$days_to_end,
          .default = !!win[2]
        ),
        !!eventColumn := dplyr::case_when(
          !is.na(.data[[eventColumn]]) ~ .data[[eventColumn]],
          !!(order == "last") & .data$days_to_start >= !!win[1] ~ "end_of_observation",
          !!(order == "last") ~ "censor",
          !is.na(.data$days_to_censor) &
            .data$days_to_censor <= .data$days_to_end &
            .data$days_to_censor <= !!win[2] ~ "censor",
          .data$days_to_end <= !!win[2] ~ "end_of_observation",
          .default = "censor"
        )
      )
  } else {
    x <- x |>
      dplyr::mutate(
        !!valueColumn := dplyr::case_when(
          !is.na(.data[[valueColumn]]) ~ .data[[valueColumn]],
          !!(order == "last") & .data$days_to_start >= !!win[1] ~ .data$days_to_start,
          !!(order == "last") ~ !!win[1],
          .data$days_to_end <= !!win[2] ~ .data$days_to_end,
          .default = !!win[2]
        ),
        !!eventColumn := dplyr::case_when(
          !is.na(.data[[eventColumn]]) ~ .data[[eventColumn]],
          !!(order == "last") & .data$days_to_start >= !!win[1] ~ "end_of_observation",
          !!(order == "last") ~ "censor",
          .data$days_to_end <= !!win[2] ~ "end_of_observation",
          .default = "censor"
        )
      )
  }
  return(x)
}
filterWindow <- function(x, win) {
  if (is.infinite(win[1])) {
    if (!is.infinite(win[2])) {
      x <- x |>
        dplyr::filter(.data$days <= !!win[2])
    }
  } else {
    if (is.infinite(win[2])) {
      x <- x |>
        dplyr::filter(!!win[1] <= .data$days)
    } else {
      x <- x |>
        dplyr::filter(!!win[1] <= .data$days & .data$days <= !!win[2])
    }
  }
  return(x)
}
prepareSolveEvents <- function(cdm, combineEvents, eventOrder, prefix) {
  x <- list()
  x$cdm <- cdm
  if (length(eventOrder) == 1) {
    x$mode <- "mutate"
    x$q <- paste0("'", eventOrder, "'")
  } else {
    if (combineEvents) {
      id <- omopgenerics::uniqueId(exclude = eventOrder)
      comb <- eventOrder |>
        rlang::set_names() |>
        purrr::map(\(x) c(0L, 1L)) |>
        expand.grid() |>
        dplyr::as_tibble() |>
        dplyr::filter(dplyr::if_any(dplyr::everything(), \(x) x == 1L)) |>
        dplyr::mutate(".n" = rowSums(dplyr::across(dplyr::everything()))) |>
        dplyr::arrange(-.data[[".n"]]) |>
        dplyr::select(!".n") |>
        dplyr::mutate(!!id := purrr::pmap_chr(
          dplyr::pick(dplyr::everything()),
          \(...) {
            row <- c(...)
            paste(names(row)[row == 1L], collapse = "; ")
          }
        ))
      if (length(eventOrder) > 5) {
        x$mode <- "join"
        nm <- omopgenerics::uniqueTableName(prefix = prefix)
        x$cdm <- omopgenerics::insertTable(cdm = cdm, name = nm, table = comb)
        x$nm <- nm
        x$id <- id
        x$join <- eventOrder
      } else {
        x$mode <- "mutate"
        q <- purrr::pmap_chr(comb[eventOrder], \(...) {
          row <- c(...)
          active <- names(row)[row == 1L]
          paste0(".data[['", active, "']] == 1", collapse = " & ")
        })
        q <- paste0(q, " ~ '", comb[[id]], "'", collapse = ", ")
        x$q <- paste0("dplyr::case_when(", q, ", .default = NA_character_)")
      }
    } else {
      x$mode <- "mutate"
      q <- eventOrder |>
        purrr::map_chr(\(x) {
          paste0(".data[['", x, "']] == 1L ~ '", x, "'")
        }) |>
        paste0(collapse = ", ")
      x$q <- paste0("dplyr::case_when(", q, ", .default = NA_character_)")
    }
  }
  return(x)
}
pivotEvents <- function(events, nms) {
  events <- events |>
    dplyr::mutate(value = 1L) |>
    tidyr::pivot_wider(names_from = "event_name", values_from = "value")
  for (nm in nms) {
    if (nm %in% colnames(events)) {
      events <- events |>
        dplyr::mutate(!!nm := dplyr::coalesce(.data[[nm]], 0L))
    } else {
      events <- events |>
        dplyr::mutate(!!nm := 0L)
    }
  }
  return(events)
}
solveEvents <- function(events, eventTies, eventColumn) {
  if (eventTies$mode == "join") {
    nm <- eventTies$nm
    cdm <- eventTies$cdm
    events <- events |>
      dplyr::inner_join(
        cdm[[nm]] |>
          dplyr::rename(!!eventColumn := dplyr::all_of(eventTies$id)),
        by = eventTies$join
      )
  } else if (eventTies$mode == "mutate") {
    q <- eventTies$q |>
      rlang::parse_exprs() |>
      rlang::set_names(eventColumn)
    events <- events |>
      dplyr::mutate(!!!q)
  }
  return(events)
}
prepareOutput <- function(x, output, col) {
  if (output == "date") {
    x <- x |>
      dplyr::mutate(!!col := as.Date(clock::add_days(
        .data$index_date, as.integer(.data[[col]])
      )))
  }
  return(x)
}
