# Helper for consistent documentation of `multipleEvents`.

Helper for consistent documentation of `multipleEvents`.

## Arguments

- multipleEvents:

  How events occurring on the same date are handled. If `NULL`, the
  first event in the original event order is returned. If `TRUE`, all
  simultaneous event names are sorted alphabetically and joined with
  `"; "`. A character vector gives priority to the specified event
  names; the first matching name is returned, with unspecified names
  following in alphabetical order. Boundary labels (`"censor"` and
  `"end_of_observation"`) are never combined with event names.
