test_that("R side oneshot analysis works", {
#    gp_lb <- c(
#        "50:50" = c(label1 = 1, label2 = 1),
#       "150:150" = c(label1 = 1, label2 = 1)
#   )

#    oneshot_data <- c(
#        bd = c(
#            params = c(name = "ironman", cellsizes = c(100, 100)),
#            data = gp_lb
#        ),
#        analysis_config = c(
#            calculations = c("calc_endemism_central")
#        )
#    )
#   as_json <- jsonlite::toJSON(oneshot_data)

    exp <- list(
        SPATIAL_RESULTS = data.frame ( # nolint
            "ELEMENT" = c("150:150", "50:50"),
            "Axis_0" = c(150, 50),
            "Axis_1" = c(150, 50),
            "ENDC_CWE" = c(0.5, 0.5),
            "ENDC_RICHNESS" = c(2, 2),
            "ENDC_SINGLE" = c(1.0, 1.0),
            "ENDC_WE" = c(1, 1)
        )
    )



    expect_true(analyse_rasters_spatial(c("../../inst/extdata/r1.tif"), c(100, 100)) == exp) # nolint
    #current issue is I believe we are getting a null output.
})
