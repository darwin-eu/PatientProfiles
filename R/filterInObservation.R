
#' Filter the rows of a `cdm_table` to the ones in observation that `indexDate`
#' is in observation.
#'
#' @param x A `cdm_table` object.
#' @param indexDate Name of a column of x that is a date.
#'
#' @return A `cdm_table` that is a subset of the original table.
#' @export
#'
#' @examples
#' \dontrun{
#' con <- duckdb::dbConnect(duckdb::duckdb(CDMConnector::eunomiaDir()))
#' cdm <- CDMConnector::cdmFromCon(
#'   con = con, cdmSchema = "main", writeSchema = "main"
#' )
#'
#' cdm$condition_occurrence |>
#'   filterInObservation(indexDate = "condition_start_date") |>
#'   dplyr::compute()
#' }
#'
filterInObservation <- function(x,
                                indexDate) {
  # initial check
  x <- omopgenerics::validateCdmTable(x)
  omopgenerics::validateColumn(indexDate, x = x, type = "date")
  cdm <- omopgenerics::cdmReference(x)

  id <- omopgenerics::getPersonIdentifier(x = x)
  cols <- omopgenerics::uniqueId(n = 2, exclude = colnames(x))

  sel <- c(
    "person_id", "observation_period_start_date", "observation_period_end_date"
  ) |>
    rlang::set_names(c(id, cols))

  x |>
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
}
