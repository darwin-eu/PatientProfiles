
# Argument descriptions used by more than one exported function:

#' Helper for consistent documentation of `x`.
#'
#' @param x A table containing individuals in a CDM reference.
#'
#' @name xDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `indexDate`.
#'
#' @param indexDate Name of a date column in `x`, or a single date to use for
#' all rows, used as the reference date.
#'
#' @name indexDateDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `name`.
#'
#' @param name Name of the new table. If `NULL`, a temporary table is returned.
#'
#' @name nameDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `window`.
#'
#' @param window Window or windows of time relative to `indexDate` to consider.
#'
#' @name windowDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `nameStyle`.
#'
#' @param nameStyle Naming pattern for the added column or columns. It should
#' include the required formatting variables. If more than one `tableName` is
#' provided, it must include `{table_name}`.
#'
#' @name nameStyleDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `censorDate`.
#'
#' @param censorDate Date or name of a date column in `x` on which to censor
#' follow-up. If `NULL`, no censoring is applied.
#'
#' @name censorDateDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `inObservation`.
#'
#' @param inObservation If `TRUE`, only records that occur during an observation
#' period are considered.
#'
#' @name inObservationDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `order`.
#'
#' @param order Which record to use when multiple records occur in a window:
#' `"first"` or `"last"`.
#'
#' @name orderDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `tableName`.
#'
#' @param tableName Names of one or more OMOP CDM tables to intersect with.
#'
#' @name tableNameDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `targetDate`.
#'
#' @param targetDate Name or names of date columns in the target tables to use
#' for the intersection.
#'
#' @name targetDateDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `targetStartDate`.
#'
#' @param targetStartDate Name or names of start-date columns in the target
#' tables to use for the intersection.
#'
#' @name targetStartDateDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `targetEndDate`.
#'
#' @param targetEndDate Name or names of end-date columns in the target tables
#' to use for the intersection. If `NULL`, the target is treated as a point
#' event.
#'
#' @name targetEndDateDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `conceptSet`.
#'
#' @param conceptSet A named list of concept sets.
#'
#' @name conceptSetDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `targetCohortTable`.
#'
#' @param targetCohortTable Name of the cohort table to intersect with.
#'
#' @name targetCohortTableDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `targetCohortId`.
#'
#' @param targetCohortId Cohort definition IDs to include from
#' `targetCohortTable`. If `NULL`, all cohorts are included.
#'
#' @name targetCohortIdDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `field`.
#'
#' @param field Name or names of columns in the target tables to add to `x`.
#'
#' @name fieldDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `type`.
#'
#' @param type Type of the created column(s). Counts, days, age, and observation
#' durations can be `"numeric"` or `"integer"`. Flag columns can also be
#' `"logical"`. Field columns can use `"auto"` to preserve the source type, or
#' can be converted to `"numeric"`, `"integer"`, `"logical"`, or `"character"`.
#'
#' @name typeDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `allowDuplicates`.
#'
#' @param allowDuplicates Whether to allow multiple records for the same person,
#' target, and date. If `TRUE`, multiple values are collapsed into a
#' semicolon-separated character value; otherwise, duplicates result in an
#' error.
#'
#' @name allowDuplicatesDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `age`.
#'
#' @param age If `TRUE`, age is calculated relative to `indexDate`.
#'
#' @name ageDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `ageName`.
#'
#' @param ageName Name of the age column to add.
#'
#' @name ageNameDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `ageMissingMonth`.
#'
#' @param ageMissingMonth Month of the year assigned when month of birth is
#' missing.
#'
#' @name ageMissingMonthDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `ageMissingDay`.
#'
#' @param ageMissingDay Day of the month assigned when day of birth is missing.
#'
#' @name ageMissingDayDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `ageImposeMonth`.
#'
#' @param ageImposeMonth If `TRUE`, month of birth is treated as missing for all
#' individuals.
#'
#' @name ageImposeMonthDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `ageImposeDay`.
#'
#' @param ageImposeDay If `TRUE`, day of birth is treated as missing for all
#' individuals.
#'
#' @name ageImposeDayDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `ageUnit`.
#'
#' @param ageUnit Unit in which to express age: `"years"`, `"months"`, or
#' `"days"`.
#'
#' @name ageUnitDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `ageGroup`.
#'
#' @param ageGroup If not `NULL`, a list of age-group vectors.
#'
#' @name ageGroupDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `missingAgeGroupValue`.
#'
#' @param missingAgeGroupValue Value to use when age is missing.
#'
#' @name missingAgeGroupValueDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `sex`.
#'
#' @param sex If `TRUE`, sex is identified.
#'
#' @name sexDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `sexName`.
#'
#' @param sexName Name of the sex column to add.
#'
#' @name sexNameDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `missingSexValue`.
#'
#' @param missingSexValue Value to use when sex is missing.
#'
#' @name missingSexValueDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `priorObservation`.
#'
#' @param priorObservation If `TRUE`, the time between the start of the current
#' observation period and `indexDate` is calculated.
#'
#' @name priorObservationDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `priorObservationName`.
#'
#' @param priorObservationName Name of the prior-observation column to add.
#'
#' @name priorObservationNameDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `priorObservationType`.
#'
#' @param priorObservationType Whether to return a `"date"` or a number of
#' `"days"`.
#'
#' @name priorObservationTypeDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `futureObservation`.
#'
#' @param futureObservation If `TRUE`, the time between `indexDate` and the end
#' of the current observation period is calculated.
#'
#' @name futureObservationDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `futureObservationName`.
#'
#' @param futureObservationName Name of the future-observation column to add.
#'
#' @name futureObservationNameDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `futureObservationType`.
#'
#' @param futureObservationType Whether to return a `"date"` or a number of
#' `"days"`.
#'
#' @name futureObservationTypeDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `dateOfBirth`.
#'
#' @param dateOfBirth If `TRUE`, date of birth is returned.
#'
#' @name dateOfBirthDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `dateOfBirthName`.
#'
#' @param dateOfBirthName Name of the date-of-birth column to add.
#'
#' @name dateOfBirthNameDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `birthday`.
#'
#' @param birthday Day of birth to add.
#'
#' @name birthdayDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `birthdayName`.
#'
#' @param birthdayName Name of the birthday column to add.
#'
#' @name birthdayNameDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `missingMonth`.
#'
#' @param missingMonth Month of the year assigned when month of birth is missing.
#'
#' @name missingMonthDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `missingDay`.
#'
#' @param missingDay Day of the month assigned when day of birth is missing.
#'
#' @name missingDayDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `imposeMonth`.
#'
#' @param imposeMonth If `TRUE`, month of birth is treated as missing for all
#' individuals.
#'
#' @name imposeMonthDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `imposeDay`.
#'
#' @param imposeDay If `TRUE`, day of birth is treated as missing for all
#' individuals.
#'
#' @name imposeDayDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `completeInterval`.
#'
#' @param completeInterval If `TRUE`, individuals must be observed for the full
#' requested interval.
#'
#' @name completeIntervalDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `nameObservationPeriodId`.
#'
#' @param nameObservationPeriodId Name of the observation-period ID column to
#' add.
#'
#' @name nameObservationPeriodIdDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `cohort`.
#'
#' @param cohort A `cohort_table` object.
#'
#' @name cohortDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `table`.
#'
#' @param table A table to process.
#'
#' @name tableDoc
#' @keywords internal
NULL

#' Helper for consistent documentation of `cdm`.
#'
#' @param cdm A `cdm_reference` object.
#'
#' @name cdmDoc
#' @keywords internal
NULL

documentationIntersect <- function(type, element) {
  start <- if (element == "death") {
    paste0(
      "The original table (`x`) with one added column per window indicating ",
      "whether the individual's death record intersects that window."
    )
  } else {
    paste0(
      "The original table (`x`) with one added column per intersection with ",
      "the desired ", element, " in a specific window. One column will be ",
      "created for each combination of window and ", element, "."
    )
  }

  end <- switch(
    type,
    count = paste0(
      "will be the number of intersections in the desired window, or NA if the ",
      "individual is not in observation at any time in the window."
    ),
    flag = paste0(
      "can either indicate presence (1 or TRUE), no intersection (0 or FALSE), ",
      "or NA if the individual is not in observation at any time of the window. ",
      "The representation depends on `type`."
    )
  )

  paste0(start, " The value of the column ", end)
}
#' Helper for consistent documentation of `multipleEvents`.
#'
#' @param multipleEvents How events occurring on the same date are handled. If
#' `NULL`, the first event in the original event order is returned. If `TRUE`,
#' all simultaneous event names are sorted alphabetically and joined with
#' `"; "`. A character vector gives priority to the specified event names; the
#' first matching name is returned, with unspecified names following in
#' alphabetical order. Boundary labels (`"censor"` and
#' `"end_of_observation"`) are never combined with event names.
#'
#' @name multipleEventsDoc
#' @keywords internal
NULL

#' Helper for event-specific documentation of `nameStyle`.
#'
#' @param nameStyle Naming pattern for the added columns. It must contain
#' `{value}` and can also contain `{window_name}`.
#'
#' @name nameStyleEventDoc
#' @keywords internal
NULL
