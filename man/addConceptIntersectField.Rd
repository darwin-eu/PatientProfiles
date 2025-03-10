% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/addConceptIntersect.R
\name{addConceptIntersectField}
\alias{addConceptIntersectField}
\title{It adds a custom column (field) from the intersection with a certain table
subsetted by concept id. In general it is used to add the first value of a
certain measurement.}
\usage{
addConceptIntersectField(
  x,
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
  name = NULL
)
}
\arguments{
\item{x}{Table with individuals in the cdm.}

\item{conceptSet}{Concept set list.}

\item{field}{Column in the standard omop table that you want to add.}

\item{indexDate}{Variable in x that contains the date to compute the
intersection.}

\item{censorDate}{Whether to censor overlap events at a date column of x}

\item{window}{Window to consider events in.}

\item{targetDate}{Event date to use for the intersection.}

\item{order}{'last' or 'first' to refer to which event consider if multiple
events are present in the same window.}

\item{inObservation}{If TRUE only records inside an observation period
will be considered.}

\item{allowDuplicates}{Whether to allow multiple records with same
conceptSet, person_id and targetDate. If switched to TRUE, it can have a
different and unpredictable behavior depending on the cdm_source.}

\item{nameStyle}{naming of the added column or columns, should include
required parameters.}

\item{name}{Name of the new table, if NULL a temporary table is returned.}
}
\value{
Table with the `field` value obtained from the intersection
}
\description{
It adds a custom column (field) from the intersection with a certain table
subsetted by concept id. In general it is used to add the first value of a
certain measurement.
}
\examples{
\donttest{
library(PatientProfiles)
cdm <- mockPatientProfiles()
concept <- dplyr::tibble(
  concept_id = c(1125315),
  domain_id = "Drug",
  vocabulary_id = NA_character_,
  concept_class_id = "Ingredient",
  standard_concept = "S",
  concept_code = NA_character_,
  valid_start_date = as.Date("1900-01-01"),
  valid_end_date = as.Date("2099-01-01"),
  invalid_reason = NA_character_
) |>
  dplyr::mutate(concept_name = paste0("concept: ", .data$concept_id))
cdm <- CDMConnector::insertTable(cdm, "concept", concept)

cdm$cohort1 |>
  addConceptIntersectField(
    conceptSet = list("acetaminophen" = 1125315),
    field = "drug_type_concept_id"
  )

mockDisconnect(cdm = cdm)
}

}
