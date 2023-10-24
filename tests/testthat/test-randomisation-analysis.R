library("BiodiverseR")

test_that("Randomisation analysis basic", {
  file_path <- system.file("extdata", package ="BiodiverseR")

  r_data = list (
    data = list(
      '250:250' = list (r1 = 13, r2 = 13, r3 = 13),
      '250:750' = list (r2 = 11, r3 = 11, r4 = 10),
      '750:250' = list (r3 = 10),
      '750:750' = list (r1 =  8, r3 =  8)
    )
  )

  bd = basedata$new(cellsizes=c(500,500))

  params = list (bd_params = r_data, raster_params = NULL)
  result = bd$load_data(params)

  expect_equal(result, 1, info=paste ("load_data"))

  results = bd$run_spatial_analysis (
    name = "sp1",
    calculations = c("calc_richness", "calc_endemism_central"),
    spatial_conditions = "sp_self_only()"
  )

  r = bd$run_randomisation_analysis (name = 'bork', iterations = 99)

  #  we only really need to check we have the right result names
  #  the values are tested under the Biodiverse test suite
  expected = c(
    "bork>>p_rank>>SPATIAL_RESULTS",
    "bork>>SPATIAL_RESULTS",
    "bork>>z_scores>>SPATIAL_RESULTS",
    "SPATIAL_RESULTS"
  )
  results = bd$get_analysis_results ("sp1")
  expect_equal (sort(names(results)), sort(expected))

})
