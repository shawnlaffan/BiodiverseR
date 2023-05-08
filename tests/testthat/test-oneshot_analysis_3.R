test_that("Analyse rasters handles JSON and rasterfiles", {
   gp_lb <- list(
       "50:50" = list(label1 = 1, label2 = 1), # nolint
      "150:150" = list(label1 = 1, label2 = 1) # nolint
  )

    rasters = normalizePath(list.files (path = "../../inst/extdata", pattern = "r[123].tif$", full.names=TRUE)) # nolint

    #since exp is random expect equal is false. Test for errors
    expect_no_error(
        analyse_all_spatial(
            raster_files = rasters,
            r_data = gp_lb,
            cellsizes = c(100, 100),
            calculations = c("calc_endemism_central")
        ), message = "analyse_all_spatial should not throw an error")
})

# test_that("Analyse rasters handles JSON and spreadsheets", {
#    gp_lb <- list(
#        "50:50" = list(label1 = 1, label2 = 1), # nolint
#       "150:150" = list(label1 = 1, label2 = 1) # nolint
#   )

#     # exp <- list(
#     #     #this data is currently random
#     #     SPATIAL_RESULTS = data.frame(
#     #         "This_data_has_no_meaning" = c(0, 0)
#     #     )
#     # )
#     # row.names(exp$SPATIAL_RESULTS) <- c("150:150", "50:50")

#     spreadsheets = normalizePath(list.files (path = "../../inst/extdata", pattern = "r[123].xlsx$", full.names=TRUE)) # nolint

#     #since exp is random expect equal is false. Test for errors
#     expect_no_error(
#         analyse_all_spatial(
#             spreadsheet_files = spreadsheets,
#             r_data = gp_lb,
#             cellsizes = c(100, 100),
#             calculations = c("calc_endemism_central"),
#         ), message = "analyse_all_spatial should not throw an error")
# })

# test_that("Analyse rasters handles raster and spreadsheets", {
#     # exp <- list(
#     #     #this data is currently random
#     #     SPATIAL_RESULTS = data.frame(
#     #         "This_data_has_no_meaning" = c(0, 0)
#     #     )
#     # )
#     # row.names(exp$SPATIAL_RESULTS) <- c("150:150", "50:50")
    
#     rasters = normalizePath(list.files (path = "../../inst/extdata", pattern = "r[123].tif$", full.names=TRUE)) # nolint
#     spreadsheets = normalizePath(list.files (path = "../../inst/extdata", pattern = "r[123].xlsx$", full.names=TRUE)) # nolint

#     #since exp is random expect equal is false. Test for errors
#     expect_no_error(
#         analyse_all_spatial(
#             raster_files = rasters,
#             spreadsheet_files = spreadsheets,
#             cellsizes = c(100, 100),
#             calculations = c("calc_endemism_central"),
#         ), message = "analyse_all_spatial should not throw an error")
# })