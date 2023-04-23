library("ape")

test_that("R side oneshot analysis handles spreadsheets", {

  exp <- list(
    SPATIAL_RESULTS = data.frame( # nolint

      "Axis_0" = c(250, 250, 750, 750),
      "Axis_1" = c(250, 750, 250, 750),
      "ENDC_CWE" = c(0.25, 0.25, 0.25, 0.25),
      "ENDC_RICHNESS" = c(3, 3, 3, 3),
      "ENDC_SINGLE" = c(0.75, 0.75, 0.75, 0.75),
      "ENDC_WE" = c(0.75, 0.75, 0.75, 0.75),
      "REDUNDANCY_ALL"  = c(0.99992743983553, 0.999910222647833, 0.999909793426948, 0.999885974914481), # nolint
      "REDUNDANCY_SET1" = c(0.99992743983553, 0.999910222647833, 0.999909793426948, 0.999885974914481) # nolint
    )
  )
  row.names(exp$SPATIAL_RESULTS) <- c("250:250", "250:750", "750:250", "750:750") # nolint

  #get raster files
  spreadsheets = normalizePath(list.files (path = "../../inst/extdata", pattern = "r[123].xlsx$", full.names=TRUE)) # nolint

  #  sanity check
  expect_equal(length(spreadsheets), 3, label='we found three spreadsheets')

  result <- analyse_all_spatial(
    spreadsheet_files = spreadsheets,
    cellsizes = c(500, 500),
    # calc_pd should not be run as we have no tree
    calculations = c("calc_endemism_central", "calc_pd", "calc_redundancy")
  )

  expect_equal(result, exp) # nolint
})
