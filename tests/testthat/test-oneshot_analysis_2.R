
#complete work in progess
test_that("R side oneshot analysis works 2", {
    # gp_lb <- list(
    #     "50:50" = list(label1 = 1, label2 = 1),
    #     "150:150" = list(label1 = 1, label2 = 1)
    # )
    #
    # oneshot_data <- list(
    #     bd = list(
    #         params = list(name = "ironman", cellsizes = list(100, 100)),
    #         data = gp_lb
    #     ),
    #     analysis_config = list(
    #         calculations = list("calc_endemism_central")
    #     )
    # )
    #
    # #might not need to do this.
    # as_json <- jsonlite::toJSON(oneshot_data)

    exp <- list(
        SPATIAL_RESULTS = data.frame( # nolint
            "ELEMENT" = c("250:250", "250:750", "750:250", "750:750"),
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

    rasters = normalizePath(list.files (path = "../../inst/extdata", pattern = "r[123].tif$", full.names=TRUE))

    #  sanity check
    expect_equal (length(rasters), 3, label='we found three rasters')

    result = analyse_rasters_spatial(raster_files=rasters, cellsizes=c(100, 100))

    expect_true(result == exp) # nolint
})
