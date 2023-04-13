test_that("Analyse rasters handles JSON", {
   gp_lb <- list(
       "50:50" = list(label1 = 1, label2 = 1), # nolint
      "150:150" = list(label1 = 1, label2 = 1) # nolint
  )

   oneshot_data <- list(
       bd = list(
           params = list(name = "ironman", cellsizes = list(100, 100)),
           data = gp_lb
       ),
       analysis_config = list(
           calculations = list("calc_endemism_central")
       )
   )

    exp <- list(
        SPATIAL_RESULTS = data.frame(
            "Axis_0" = c(150, 50),
            "Axis_1" = c(150, 50),
            "ENDC_CWE" = c(0.5, 0.5),
            "ENDC_RICHNESS" = c(2, 2),
            "ENDC_SINGLE" = c(1.0, 1.0),
            "ENDC_WE" = c(1, 1)
        )
    )
    row.names(exp$SPATIAL_RESULTS) <- c("150:150", "50:50")

    #make it import the right one
    results <- analyse_all_spatial(
        oneshot_data,
        c(100, 100),
        calculations = c("calc_endemism_central")
    )

    expect_equal(results, exp)
})
