file_path <- "../../inst/extdata"

test_that("Analyse rasters handles JSON and rasterfiles", {
   gp_lb <- list(
        "50:50" = list(label1 = 1, label2 = 1), # nolint
        "150:150" = list(label1 = 1, label2 = 1) # nolint
  )

    rasters = normalizePath(list.files (path = file_path, pattern = "r[123].tif$", full.names=TRUE)) # nolint

    #tests for no errors, not for correct output
    expect_no_error(
        analyse_all_spatial(
            raster_files = rasters,
            r_data = gp_lb,
            cellsizes = c(100, 100),
            calculations = c("calc_endemism_central")
        ), message = "analyse_all_spatial should not throw an error")
})

test_that("Analyse rasters handles JSON, raster and spreadsheets", {
   gp_lb <- list(
        "50:50" = list(label1 = 1, label2 = 1), # nolint
        "150:150" = list(label1 = 1, label2 = 1) # nolint
  )

    spreadsheets = normalizePath(list.files (path = file_path, pattern = "r[123].xlsx$", full.names=TRUE)) # nolint
    rasters = normalizePath(list.files (path = file_path, pattern = "r[123].tif$", full.names=TRUE)) # nolint

    expect_no_error(
        analyse_all_spatial(
            r_data = gp_lb,
            raster_files = rasters,
            spreadsheet_data = list(spreadsheets, list("X", "Y"), list("label"), list("count")), #nolint
            cellsizes = c(100, 100),
            calculations = c("calc_endemism_central", "calc_pd", "calc_redundancy"), #nolint
        ), message = "analyse_all_spatial should not throw an error")
})

test_that("Analyse rasters handles JSON, raster and delim files", {
   gp_lb <- list(
        "50:50" = list(label1 = 1, label2 = 1), # nolint
        "150:150" = list(label1 = 1, label2 = 1) # nolint
  )

    delim_files = normalizePath(list.files (path = file_path, pattern = "r[123].csv$", full.names=TRUE)) # nolint
    rasters = normalizePath(list.files (path = file_path, pattern = "r[123].tif$", full.names=TRUE)) # nolint

    expect_no_error(
        analyse_all_spatial(
            r_data = gp_lb,
            raster_files = rasters,
            delimited_text_file_data = list(delim_files, list(1, 2), list(4), list(3)), #nolint
            cellsizes = c(100, 100),
            calculations = c("calc_endemism_central", "calc_pd", "calc_redundancy"), #nolint
        ), message = "analyse_all_spatial should not throw an error")
})

test_that("Analyse rasters handles JSON, raster and shapefiles", {
   gp_lb <- list(
        "50:50" = list(label1 = 1, label2 = 1), # nolint
        "150:150" = list(label1 = 1, label2 = 1) # nolint
  )

    shape_files = normalizePath(list.files(path = file_path, pattern = "r[123].shp$", full.names=TRUE)) # nolint
    rasters = normalizePath(list.files (path = file_path, pattern = "r[123].tif$", full.names=TRUE)) # nolint

    expect_no_error(
        analyse_all_spatial(
            r_data = gp_lb,
            raster_files = rasters,
            shapefile_data = list(shape_files, list(":shape_x", ":shape_y"), list("label"), list("count")), #nolint
            cellsizes = c(100, 100),
            calculations = c("calc_endemism_central", "calc_pd", "calc_redundancy"), #nolint
        ), message = "analyse_all_spatial should not throw an error")
})

test_that("Analyse rasters handles spreadsheet, delim and shapefiles", {
   gp_lb <- list(
        "50:50" = list(label1 = 1, label2 = 1), # nolint
        "150:150" = list(label1 = 1, label2 = 1) # nolint
  )

    spreadsheets = normalizePath(list.files (path = file_path, pattern = "r[123].xlsx$", full.names=TRUE)) # nolint
    delim_files = normalizePath(list.files (path = file_path, pattern = "r[123].csv$", full.names=TRUE)) # nolint
    shape_files = normalizePath(list.files(path = file_path, pattern = "r[123].shp$", full.names=TRUE)) # nolint

    expect_no_error(
        analyse_all_spatial(
            spreadsheet_data = list(spreadsheets, list("X", "Y"), list("label"), list("count")), #nolint
            delimited_text_file_data = list(delim_files, list(1, 2), list(4), list(3)), #nolint
            shapefile_data = list(shape_files, list(":shape_x", ":shape_y"), list("label"), list("count")), #nolint 
            cellsizes = c(100, 100),
            calculations = c("calc_endemism_central", "calc_pd", "calc_redundancy"), #nolint
        ), message = "analyse_all_spatial should not throw an error")
})

test_that("Analyse all files", {
   gp_lb <- list(
        "50:50" = list(label1 = 1, label2 = 1), # nolint
        "150:150" = list(label1 = 1, label2 = 1) # nolint
  )

    spreadsheets = normalizePath(list.files (path = file_path, pattern = "r[123].xlsx$", full.names=TRUE)) # nolint
    delim_files = normalizePath(list.files (path = file_path, pattern = "r[123].csv$", full.names=TRUE)) # nolint
    shape_files = normalizePath(list.files(path = file_path, pattern = "r[123].shp$", full.names=TRUE)) # nolint
    rasters = normalizePath(list.files (path = file_path, pattern = "r[123].tif$", full.names=TRUE)) # nolint

    expect_no_error(
        analyse_all_spatial(
            r_data = gp_lb,
            raster_files = rasters,
            spreadsheet_data = list(spreadsheets, list("X", "Y"), list("label"), list("count")), #nolint
            delimited_text_file_data = list(delim_files, list(1, 2), list(4), list(3)), #nolint
            shapefile_data = list(shape_files, list(":shape_x", ":shape_y"), list("label"), list("count")), #nolint 
            cellsizes = c(100, 100),
            calculations = c("calc_endemism_central", "calc_pd", "calc_redundancy"), #nolint
        ), message = "analyse_all_spatial should not throw an error")
})