library("BiodiverseR")

test_that("Cluster analysis basic", {
  file_path <- system.file("extdata", package ="BiodiverseR")

  r_data = list (
    data = list(
      '250:250' = list (r1 = 13, r2 = 13, r3 = 13),
      '250:750' = list (r2 = 11, r3 = 11, r4 = 10),
      '750:250' = list (r3 = 10),
      '750:750' = list (r1 =  8, r3 =  8)
    )
  )
  #tree = ape::read.nexus (fs::path(file_path, "tree.nex"))

  table = data.frame (
    Axis_0  = as.character(1:7),
    COLOUR  = rep(NA, 7),
    LENGTHTOPARENT = c(0, 0.0611111111111111, 0.216666666666667, 0.2, 0.2, 0.416666666666667, 0.477777777777778),
    NAME = c('2___', '1___', '0___', '250:250', '750:750', '750:250', '250:750'),
    NODE_NUMBER = 1:7,
    PARENTNODE = as.character(c(0, 1, 2, 3, 3, 2, 1)),
    TREENAME = rep ('TREE', 7)
  )
  row.names(table) = as.character(1:7)

  tree = list (
    'Nnode' = 3,
    'edge' = c( 5, 6, 7, 7, 5, 6, 1, 2, 3, 4, 6, 7 ),
    'edge.length' = c(
      0.477777777777778,  0.416666666666667, 0.2, 0.2,
      0.0611111111111111, 0.216666666666667
    ),
    'node.label' = c( '1___', '0___' ),
    'root.edge' = 0,
    'tip.label' = c('250:750', '750:250', '250:250', '750:750' )
  )
  tree$edge = matrix (tree$edge, ncol=2)
  class (tree) = "phylo"

  expected = list (lists = list (), dendrogram = tree, node_values = table)

  bd = basedata$new(cellsizes=c(500,500))

  params = list (bd_params = r_data, raster_params = NULL)
  result = bd$load_data(params)

  expect_equal(result, 1, info=paste ("load_data"))

  results = bd$run_cluster_analysis (
    # calculations = calculations,
    # tree = tree
  )
  expect_equal (results, expected, info="expected cluster results")


  # #  now a two element subset
  # r_data[['data']][['750:750']] = NULL
  # r_data[['data']][['750:250']] = NULL
  #
  # bd = basedata$new(cellsizes=c(500,500))
  #
  # params = list (bd_params = r_data)
  # result = bd$load_data(params)
  #
  # expect_equal(result, 1, info=paste ("load_data"))
  #
  # results = bd$run_cluster_analysis (
  #   # calculations = calculations,
  #   # tree = tree
  # )
  # expect_equal (results, expected, info="expected cluster results")

})
