#' Load data onto the server associated with
#' a BiodiverseR::basedata object
#'
#'
#' @param bd list
#' @param r_data list
#' @param raster_params list
#' @param spreadsheet_params list
#' @param delimited_text_params list
#' @param shapefile_params list
#'
#' @export
#' @examples
#' if(interactive()) {
#'   b = BiodiverseR::basedata$new(name = "trial")
#' }
load_data_ = function (
    bd,
    params = list()
    # r_data = NULL,
    # raster_params = NULL,
    # spreadsheet_params = NULL,
    # delimited_text_params = NULL,
    # shapefile_params = NULL
  ) {
  checkmate::assertR6(bd, c("basedata"))
  stopifnot(bd$server_status())

  # params = list (
  #   raster_params = raster_params,
  #   spreadsheet_params = spreadsheet_params,
  #   delimited_text_params = delimited_text_params,
  #   shapefile_params = shapefile_params,
  #   bd_params = r_data  # messy
  # )
  #  a bit messy but allows for later expansion
  #  and still needs thought
  # params = as.list(match.call())
  # params[["bd"]] = NULL
  checkmate::assert_list(params, all.missing=FALSE)
  if(!is.null(params[["r_data"]])) {
    params[["bd_params"]] = params[["r_data"]]
    params[["r_data"]] = NULL
  }
message(params)
  #  server now instantiates a basedata on call to new()
  # gp_count = bd$call_server("bd_get_group_count")
  # message (gp_count)
  # stopifnot (
  #   checkmate::test_scalar(gp_count),
  #   "basedata has been instantiated on server"
  # )

  result = bd$call_server("bd_load_data", params)

  result
}
