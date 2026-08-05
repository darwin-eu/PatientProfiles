# Adding first or last events

## Introduction

The event functions identify which event occurs first or last within a
time window. They can search either a cohort table or a concept set:

| Event source | Return the date | Return days relative to the index date |
|:---|:---|:---|
| Cohort table | [`addCohortEventDate()`](https://darwin-eu.github.io/PatientProfiles/reference/addCohortEventDate.md) | [`addCohortEventDays()`](https://darwin-eu.github.io/PatientProfiles/reference/addCohortEventDays.md) |
| Concept set | [`addConceptEventDate()`](https://darwin-eu.github.io/PatientProfiles/reference/addConceptEventDate.md) | [`addConceptEventDays()`](https://darwin-eu.github.io/PatientProfiles/reference/addConceptEventDays.md) |

Each function adds two columns for every window:

- an `event` column containing the name of the selected event; and
- a `date` or `days` column containing when that event occurred.

Unlike the intersection functions, the event functions also return the
applicable boundary when no target event occurs in the requested window.
This makes it possible to distinguish an observed event, an explicit
censoring boundary, and the end of observation.

We will use the *GiBleed* dataset to illustrate this functionality:

``` r

library(PatientProfiles)
library(dplyr)
library(omock)
library(CohortConstructor)
library(CodelistGenerator)

cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
```

Let’s create some simple cohorts:

``` r

codelist <- getDrugIngredientCodes(
  cdm = cdm,
  name = "acetaminophen",
  nameStyle = "{concept_name}"
)
cdm$my_cohort <- conceptCohort(
  cdm = cdm,
  conceptSet = codelist,
  name = "my_cohort"
) |>
  requireIsFirstEntry()
codelist <- list(osteoarthritis = 80180L, diverticular_disease = 4266809L)
cdm$conditions <- conceptCohort(
  cdm = cdm,
  conceptSet = codelist,
  name = "conditions"
)
```

## Finding a cohort event

[`addCohortEventDays()`](https://darwin-eu.github.io/PatientProfiles/reference/addCohortEventDays.md)
searches the cohorts in `targetCohortTable`. In this example we find the
first event on or after each record’s cohort start date and up to 365
days later.

``` r

cohort_event_days <- cdm$my_cohort |>
  addCohortEventDays(
    targetCohortTable = "conditions",
    indexDate = "cohort_start_date",
    order = "first",
    window = list(next_year = c(0, 365))
  )

cohort_event_days |>
  glimpse()
#> Rows: ??
#> Columns: 6
#> $ cohort_definition_id <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ subject_id           <int> 6, 16, 42, 18, 35, 40, 53, 9, 2, 49, 11, 61, 32, …
#> $ cohort_start_date    <date> 1969-12-20, 1974-06-11, 1937-09-07, 1970-09-22, …
#> $ cohort_end_date      <date> 1970-01-03, 1974-06-25, 1937-09-14, 1970-10-06, …
#> $ event_next_year      <chr> "censor", "censor", "censor", "censor", "censor",…
#> $ days_next_year       <dbl> 365, 365, 365, 365, 365, 365, 365, 365, 365, 365,…
```

The `days_next_year` value is relative to `cohort_start_date`: positive
values are after the index date, zero is the index date, and negative
values are before it.

We can obtain a quick summary of the result:

``` r

cohort_event_days |>
  group_by(event_next_year) |>
  summarise(
    n = n(),
    median_days = median(days_next_year)
  ) |>
  collect()
#> # A tibble: 4 × 3
#>   event_next_year          n median_days
#>   <chr>                <dbl>       <dbl>
#> 1 end_of_observation       1         321
#> 2 diverticular_disease     1         221
#> 3 censor                2676         365
#> 4 osteoarthritis           1         199
```

- **censor** means that no event was found before the window or
  censoring boundary;
- **end_of_observation** means that no event was found before the
  relevant observation period boundary; and
- any other value is the name of the event that was found.

To find the nearest previous event, use a window ending on the index
date and `order = "last"`. Here, `"last"` selects the latest event in
the window. Because the complete window is in the past, this is the
event nearest the index date.

``` r

cohort_event_date <- cdm$my_cohort |>
  addCohortEventDate(
    targetCohortTable = "conditions",
    indexDate = "cohort_start_date",
    order = "last",
    window = list(previous_year = c(-365, 0))
  )

cohort_event_date |>
  glimpse()
#> Rows: ??
#> Columns: 6
#> $ cohort_definition_id <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ subject_id           <int> 6, 16, 42, 18, 35, 40, 53, 9, 2, 49, 11, 61, 32, …
#> $ cohort_start_date    <date> 1969-12-20, 1974-06-11, 1937-09-07, 1970-09-22, …
#> $ cohort_end_date      <date> 1970-01-03, 1974-06-25, 1937-09-14, 1970-10-06, …
#> $ event_previous_year  <chr> "censor", "censor", "censor", "censor", "end_of_o…
#> $ date_previous_year   <date> 1968-12-20, 1973-06-11, 1936-09-07, 1969-09-22, …
```

Use `targetCohortId` to restrict the search to particular cohorts.
`targetDate` determines which date in the target cohort table represents
the event and defaults to `cohort_start_date`.

## Finding a concept event

The concept event functions search records associated with one or more
concept sets across the OMOP clinical tables. The names of the concept
sets become the event names.

``` r

concept_event_days <- cdm$my_cohort |>
  addConceptEventDays(
    conceptSet = codelist,
    order = "first",
    window = list(next_event = c(0, Inf))
  )

concept_event_days |>
  glimpse()
#> Rows: ??
#> Columns: 6
#> $ cohort_definition_id <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ subject_id           <int> 2, 49, 11, 61, 41, 19, 3, 36, 1, 38, 65, 72, 116,…
#> $ cohort_start_date    <date> 1931-09-03, 1978-03-10, 1966-10-25, 1969-12-23, …
#> $ cohort_end_date      <date> 1931-09-17, 1978-03-24, 1966-11-08, 1970-01-06, …
#> $ event_next_event     <chr> "osteoarthritis", "osteoarthritis", "osteoarthrit…
#> $ days_next_event      <dbl> 9224, 11418, 7538, 13033, 12339, 2814, 3464, 1154…
```

For concept events, `targetDate` can be either `event_start_date`, the
default, or `event_end_date`. The concept set is validated against the
vocabulary in the CDM before the clinical records are searched.

## First, last, and censoring

The `window` defines the period to search, while `order` determines
which event within that period is returned:

- `order = "first"` selects the earliest event in the window;
- `order = "last"` selects the latest event in the window;
- a window such as `c(-365, 0)` searches before `indexDate`, while
  `c(0, 365)` searches after it; and
- both window endpoints are included.

The search is always restricted to the observation period containing the
index date. For a forward search, a column supplied through `censorDate`
can shorten the available follow-up. If no event occurs before the
applicable boundary, the event column contains:

- `"end_of_observation"` when the observation period boundary is
  reached; or
- `"censor"` when `censorDate` or the requested window boundary is
  reached.

The accompanying date or days value is the applicable boundary.

For a forward search, the boundary is the earliest of the upper window
boundary, `censorDate`, and the observation period end. For a backward
search, the boundary is the latest of the lower window boundary and the
observation period start.

An event on the boundary is returned as the event itself. It is not
combined with `"censor"` or `"end_of_observation"`. If the index date is
outside observation, both added values are missing.

## Events occurring on the same date

Several cohorts or concept sets can occur on the selected date. The
`multipleEvents` argument controls how these ties are represented:

- `NULL`, the default, returns the first matching event in the original
  order;
- `TRUE` returns all matching event names in alphabetical order,
  separated by `"; "`; and
- a character vector defines a priority order and returns the first
  matching name. Event names omitted from the vector follow in
  alphabetical order.

Use `NULL` to follow the original order of the concept set:

``` r

cdm$my_cohort |>
  addConceptEventDays(
    conceptSet = codelist,
    order = "first",
    window = list("next" = c(0, Inf)),
    multipleEvents = NULL
  ) |>
  group_by(event_next) |>
  summarise(n = n()) |>
  collect()
#> # A tibble: 3 × 2
#>   event_next               n
#>   <chr>                <dbl>
#> 1 diverticular_disease   390
#> 2 end_of_observation     115
#> 3 osteoarthritis        2174
```

Use `TRUE` to combine all events that occur on the selected date:

``` r

cdm$my_cohort |>
  addConceptEventDays(
    conceptSet = codelist,
    order = "first",
    window = list("next" = c(0, Inf)),
    multipleEvents = TRUE
  ) |>
  group_by(event_next) |>
  summarise(n = n()) |>
  collect()
#> # A tibble: 3 × 2
#>   event_next                               n
#>   <chr>                                <dbl>
#> 1 diverticular_disease; osteoarthritis   390
#> 2 osteoarthritis                        2174
#> 3 end_of_observation                     115
```

Alternatively, provide an explicit priority order. Here,
`osteoarthritis` is selected before `diverticular_disease` when they
occur on the same date:

``` r

cdm$my_cohort |>
  addConceptEventDays(
    conceptSet = codelist,
    order = "first",
    window = list("next" = c(0, Inf)),
    multipleEvents = c("osteoarthritis", "diverticular_disease")
  ) |>
  group_by(event_next) |>
  summarise(n = n()) |>
  collect()
#> # A tibble: 2 × 2
#>   event_next             n
#>   <chr>              <dbl>
#> 1 osteoarthritis      2564
#> 2 end_of_observation   115
```

In this example, 390 cohort records have both *osteoarthritis* and
*diverticular disease* on the selected date. The three calls above show
how `multipleEvents` can resolve these ties using the original order, a
combined label, or an explicit priority.

## Multiple windows and column names

More than one window can be supplied in a named list. The default
`nameStyle = "{value}_{window_name}"` uses `{value}` for `event`,
`date`, or `days`, and `{window_name}` for the name of the window.

``` r

events_in_two_directions <- cdm$my_cohort |>
  addCohortEventDays(
    targetCohortTable = "conditions",
    order = "first",
    window = list(
      before = c(-365, 0),
      after = c(0, 365)
    )
  )

events_in_two_directions |>
  glimpse()
#> Rows: ??
#> Columns: 8
#> $ cohort_definition_id <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ subject_id           <int> 6, 16, 42, 18, 35, 40, 53, 9, 2, 49, 11, 61, 32, …
#> $ cohort_start_date    <date> 1969-12-20, 1974-06-11, 1937-09-07, 1970-09-22, …
#> $ cohort_end_date      <date> 1970-01-03, 1974-06-25, 1937-09-14, 1970-10-06, …
#> $ event_before         <chr> "censor", "censor", "censor", "censor", "censor",…
#> $ event_after          <chr> "censor", "censor", "censor", "censor", "censor",…
#> $ days_before          <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
#> $ days_after           <dbl> 365, 365, 365, 365, 365, 365, 365, 365, 365, 365,…
```

The same value of `order` applies to every supplied window. If different
windows require different values of `order`, use separate calls.

`nameStyle` must contain `{value}` so that the event and its date or
days have different names. It must also produce a unique name for every
output column.
