# It creates a mock database for testing PatientProfiles package

It creates a mock database for testing PatientProfiles package

## Usage

``` r
mockPatientProfiles(
  numberIndividuals = 10,
  ...,
  source = "local",
  con = lifecycle::deprecated(),
  writeSchema = lifecycle::deprecated(),
  seed = lifecycle::deprecated()
)
```

## Arguments

- numberIndividuals:

  Number of individuals to create in the cdm reference.

- ...:

  User self defined tables to put in cdm, it can input as many as the
  user want.

- source:

  Source for the mock cdm, it can either be 'local' or 'duckdb'.

- con:

  deprecated.

- writeSchema:

  deprecated.

- seed:

  deprecated.

## Value

A mock cdm_reference object created following user's specifications.

## Examples

``` r
# \donttest{
library(PatientProfiles)

cdm <- mockPatientProfiles()

# }
```
