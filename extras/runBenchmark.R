
referenceBranch <- "main"
n <- 50000
it <- 10

con <- duckdb::dbConnect(duckdb::duckdb(), CDMConnector::eunomiaDir())
cdmDuck <- CDMConnector::cdmFromCon(con = con, cdmSchema = "main", writeSchema = "main")

db <- DBI::dbConnect(RPostgres::Postgres(),
                     dbname = "cdm_gold_202407",
                     port = Sys.getenv("DB_PORT"),
                     host = Sys.getenv("DB_HOST"),
                     user = Sys.getenv("DB_USER"),
                     password = Sys.getenv("DB_PASSWORD"))
cdmPostgres <- CDMConnector::cdmFromCon(
  con = db, cdmSchema = "public_100k", writeSchema = "results", writePrefix = "mcs_bench_"
)

devtools::load_all()
comp_duck <- benchmarkPatientProfiles(cdm = cdmDuck, n = n, iterations = it)
#comp_postgres <- benchmarkPatientProfiles(cdm = cdmPostgres, n = n, iterations = it)
save(
  comp_duck,
  #comp_postgres,
  file = here::here("extras", "benchmark_comp.RData")
)

devtools::install_github(glue::glue("darwin-eu-dev/PatientProfiles@{referenceBranch}"))
ref_duck <- PatientProfiles::benchmarkPatientProfiles(cdm = cdmDuck, n = n, iterations = it)
ref_postgres <- PatientProfiles::benchmarkPatientProfiles(cdm = cdmPostgres, n = n, iterations = it)
save(ref_duck, ref_postgres, file = here::here("extras", "benchmark_ref.RData"))

compareBenchmarkPatientProfiles(
  ref_duck = ref_duck,
  comp_duck = comp_duck#,
  #ref_postgres = ref_postgres,
  #comp_postgres = comp_postgres
)

chnageBenchmark(ref_duck, comp_duck)
chnageBenchmark(ref_postgres, comp_postgres)

chnageBenchmark <- function(ref, comp) {
  ref <- omopgenerics::tidy(ref) |>
    dplyr::filter(.data$iteration != "overall") |>
    dplyr::group_by(.data$task) |>
    dplyr::summarise(
      overall = sum(.data$time_seconds),
      median = median(.data$time_seconds)
    ) |>
    tidyr::pivot_longer(c("overall", "median"), names_to = "estimate", values_to = "ref_time")
  comp <-  omopgenerics::tidy(comp) |>
    dplyr::filter(.data$iteration != "overall") |>
    dplyr::group_by(.data$task) |>
    dplyr::summarise(
      overall = sum(.data$time_seconds),
      median = median(.data$time_seconds)
    ) |>
    tidyr::pivot_longer(c("overall", "median"), names_to = "estimate", values_to = "comp_time")
  ref |>
    dplyr::inner_join(comp, by = c("task", "estimate")) |>
    dplyr::mutate(change = 100 * (.data$comp_time - .data$ref_time) / .data$ref_time) |>
    dplyr::select("task", "estimate", "change") |>
    tidyr::pivot_wider(values_from = "change", names_from = "estimate")
}
compareBenchmarkPatientProfiles <- function(...) {
  x <- purrr::compact(list(...)) |>
    purrr::map(\(x) {
      omopgenerics::tidy(x) |>
        dplyr::select("task", "iteration", "time_seconds") |>
        dplyr::filter(.data$iteration != "overall")
    }) |>
    dplyr::bind_rows(.id = "comparison") |>
    dplyr::mutate(
      group = dplyr::case_when(
        grepl("Demographics", .data$task) ~ "Demographics",
        grepl("one", .data$task) ~ "Intersect one window",
        .default = "Intersect three windows"
      ) |>
        factor(levels = c("Demographics", "Intersect one window", "Intersect three windows")),
      task = dplyr::case_when(
        grepl("Demographics", .data$task) ~ gsub("Demographics: ", "", .data$task),
        grepl("count", .data$task) ~ "count",
        grepl("flag", .data$task) ~ "flag",
        grepl("date", .data$task) ~ "date",
        grepl("days", .data$task) ~ "days",
        grepl("test_result", .data$task) ~ "extra_col"
      ) |>
        factor(levels = c(
          "age", "age_group", "sex", "prior_observation", "future_observation",
          "all", "count", "flag", "date", "days", "extra_col"
        ))
    )
  p1 <- x |>
    dplyr::filter(.data$group == "Demographics") |>
    ggplot2::ggplot(mapping = ggplot2::aes(x = .data$task, y = .data$time_seconds, fill = .data$comparison)) +
    ggplot2::geom_boxplot() +
    ggplot2::facet_grid(rows = ggplot2::vars(.data$group), scales = "free_y")
  p2 <- x |>
    dplyr::filter(.data$group != "Demographics") |>
    ggplot2::ggplot(mapping = ggplot2::aes(x = .data$task, y = .data$time_seconds, fill = .data$comparison)) +
    ggplot2::geom_boxplot() +
    ggplot2::facet_grid(rows = ggplot2::vars(.data$group), scales = "free_y")

  patchwork::wrap_plots(p1, p2, nrow = 2) +
    patchwork::plot_layout(heights = c(1/3, 2/3), guides = "collect", axis_titles = "collect")
}
