
#' Filter the rows of a `cdm_table` to the ones in observation that `indexDate`
#' is in observation.
#'
#' @inheritParams xDoc
#' @inheritParams indexDateDoc
#'
#' @return A `cdm_table` that is a subset of the original table.
#' @export
#'
#' @examples
#' \dontrun{
#' library(PatientProfiles)
#' library(omock)
#'
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
#'
#' cdm$condition_occurrence |>
#'   filterInObservation(indexDate = "condition_start_date")
#'
#' }
#'
filterInObservation <- function(x,
                                indexDate) {
  # initial check
  x <- omopgenerics::validateCdmTable(x)
  originalColumns <- colnames(x)
  indexDateInput <- materialiseIndexDate(indexDate = indexDate, x = x)
  x <- indexDateInput$x
  indexDate <- indexDateInput$indexDate
  cdm <- omopgenerics::cdmReference(x)

  id <- omopgenerics::getPersonIdentifier(x = x)
  cols <- omopgenerics::uniqueId(n = 2, exclude = colnames(x))

  sel <- c(
    "person_id", "observation_period_start_date", "observation_period_end_date"
  ) |>
    rlang::set_names(c(id, cols))

  x <- x |>
    dplyr::inner_join(
      cdm$observation_period |>
        dplyr::select(dplyr::all_of(sel)),
      by = id
    ) |>
    dplyr::filter(
      .data[[cols[1]]] <= .data[[indexDate]] &
        .data[[indexDate]] <= .data[[cols[2]]]
    ) |>
    dplyr::select(!dplyr::all_of(cols))

  removeMaterialisedIndexDate(x, indexDateInput) |>
    dplyr::select(dplyr::all_of(originalColumns))
}
