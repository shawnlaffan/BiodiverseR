library("ape")

file_path <- "../../inst/extdata"

test_that("R side oneshot analysis works 2 no tree", {

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
  rasters = normalizePath(list.files (path = file_path, pattern = "r[123].tif$", full.names=TRUE)) # nolint

  #  sanity check
  expect_equal(length(rasters), 3, label='we found three rasters')

  result <- analyse_rasters_spatial(
    raster_files = rasters,
    cellsizes = c(500, 500),
    # calc_pd should not be run as we have no tree
    calculations = c("calc_endemism_central", "calc_pd", "calc_redundancy")
  )

  expect_equal(result, exp) # nolint
})


test_that("R side oneshot analysis works 2 with tree", {

    exp <- list(
        SPATIAL_RESULTS = data.frame( # nolint

            "Axis_0" = c(250, 250, 750, 750),
            "Axis_1" = c(250, 750, 250, 750),
            "ENDC_CWE" = c(0.25, 0.25, 0.25, 0.25),
            "ENDC_RICHNESS" = c(3, 3, 3, 3),
            "ENDC_SINGLE" = c(0.75, 0.75, 0.75, 0.75),
            "ENDC_WE" = c(0.75, 0.75, 0.75, 0.75),
            "PD" = c(4, 4, 4, 4),
            "PD_P" = c(1, 1, 1, 1),
            "PD_P_per_taxon" = c(0.333333333333333, 0.333333333333333, 0.333333333333333, 0.333333333333333), # nolint
            "PD_per_taxon" = c(1.33333333333333, 1.33333333333333, 1.33333333333333, 1.33333333333333), # nolint
            "REDUNDANCY_ALL"  = c(0.99992743983553, 0.999910222647833, 0.999909793426948, 0.999885974914481), # nolint
            "REDUNDANCY_SET1" = c(0.99992743983553, 0.999910222647833, 0.999909793426948, 0.999885974914481) # nolint
        )
    )
    row.names(exp$SPATIAL_RESULTS) = c("250:250", "250:750", "750:250", "750:750")

    rasters = normalizePath(list.files (path = file_path, pattern = "r[123].tif$", full.names=TRUE))
    tree <- read.nexus("../../inst/extdata/tree.nex")

    #  sanity check
    expect_equal (length(rasters), 3, label='we found three rasters')

    result = analyse_all_spatial(
      raster_files=rasters,
      cellsizes=c(500, 500),
      calculations=c("calc_endemism_central", "calc_pd", "calc_redundancy"),
      tree=tree
    )

    expect_equal(result, exp) # nolint
})

test_that("Analyse all files and tree", {
   gp_lb <- list(
        "50:50" = list(label1 = 1, label2 = 1), # nolint
        "150:150" = list(label1 = 1, label2 = 1) # nolint
  )

    spreadsheets = normalizePath(list.files (path = file_path, pattern = "r[123].xlsx$", full.names=TRUE)) # nolint
    delim_files = normalizePath(list.files (path = file_path, pattern = "r[123].csv$", full.names=TRUE)) # nolint
    shape_files = normalizePath(list.files(path = file_path, pattern = "r[123].shp$", full.names=TRUE)) # nolint
    rasters = normalizePath(list.files (path = file_path, pattern = "r[123].tif$", full.names=TRUE)) # nolint

    tree <- read.nexus("../../inst/extdata/tree.nex")
    
    #since exp is random expect equal is false. Tests for errors
    expect_no_error(
        analyse_all_spatial(
            r_data = gp_lb,
            raster_files = rasters,
            spreadsheet_data = list(spreadsheets, list("X", "Y"), list("label"), list("count")), #nolint
            delimited_text_file_data = list(delim_files, list(1, 2), list(4), list(3)), #nolint
            shapefile_data = list(shape_files, list(":shape_x", ":shape_y"), list("label"), list("count")), #nolint 
            cellsizes = c(100, 100),
            calculations = c("calc_endemism_central", "calc_pd", "calc_redundancy"), #nolint
            tree = tree
        ), message = "analyse_all_spatial should not throw an error")
})