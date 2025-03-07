test_that("test filterInObservation", {
  skip_if_not_installed("CDMConnector", "2.0.0")
  cdm <- omopgenerics::cdmFromTables(
    tables = list(
      person = dplyr::tibble(
        person_id = c(1L, 2L),
        gender_concept_id = 0L,
        year_of_birth = 1990L,
        month_of_birth = 1L,
        day_of_birth = 1L,
        birth_datetime = as.Date(NA),
        race_concept_id = 0L,
        ethnicity_concept_id = 0L,
        location_id = 0L,
        provider_id = 0L,
        care_site_id = 0L,
        person_source_value = "",
        gender_source_value = "",
        gender_source_concept_id = 0L,
        race_source_value = "",
        race_source_concept_id = 0L,
        ethnicity_source_value = "",
        ethnicity_source_concept_id = 0L
      ),
      observation_period = dplyr::tibble(
        observation_period_id = 1:3L,
        person_id = c(1L, 1L, 2L),
        observation_period_start_date = as.Date(c("2000-01-01", "2010-01-01", "2000-01-01")),
        observation_period_end_date = as.Date(c("2009-01-01", "2019-01-01", "2019-01-01")),
        period_type_concept_id = 0L
      ),
      drug_exposure = dplyr::tibble(
        drug_exposure_id = 1:6L,
        person_id = c(1L, 1L, 1L, 2L, 2L, 3L),
        drug_concept_id = 0L,
        drug_exposure_start_date = as.Date(c(
          "2004-01-01", "1950-01-01", "2009-02-01", "2004-01-01", "2020-01-01", "2000-01-01"
        )),
        drug_exposure_start_datetime = drug_exposure_start_date,
        drug_exposure_end_date = as.Date(c(
          "2004-02-01", "2005-01-01", "2010-01-01", "2004-01-01", "2020-01-01", "2000-01-01"
        )),
        drug_exposure_end_datetime = drug_exposure_end_date,
        varbatim_end_date = drug_exposure_end_date,
        drug_type_concept_id = 0L,
        stop_reason = "",
        refills = 0L,
        quntity = 0,
        days_supply = 0L,
        sig  = "",
        route_concept_id = 0L,
        lot_number = "",
        provider_id = 0L,
        visit_occurrence_id = 0L,
        visit_detail_id = 0L,
        drug_source_value = "",
        drug_source_concept_id = 0L,
        route_source_value = "",
        dose_unit_source_value = ""
      )
    ),
    cdmName = "test db",
    cdmVersion = "5.3"
  )
  src <- CDMConnector::dbSource(con = connection(), writeSchema = writeSchema())
  cdm <- omopgenerics::insertCdmTo(cdm = cdm, to = src)

  expect_no_error(
    xS <- cdm$drug_exposure |>
      filterInObservation(indexDate = "drug_exposure_start_date") |>
      dplyr::pull("drug_exposure_id") |>
      sort()
  )
  expect_identical(xS, c(1L, 4L))
  expect_no_error(
    xE <- cdm$drug_exposure |>
      filterInObservation(indexDate = "drug_exposure_end_date") |>
      dplyr::pull("drug_exposure_id") |>
      sort()
  )
  expect_identical(xE, c(1L, 2L, 3L, 4L))

  omopgenerics::cdmDisconnect(cdm)
})
