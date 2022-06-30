#' Use the Biodiverse server to load a set of rasters and then analyse them
#'
#'
#' @param rasters character
#' @param cellsizes numeric
#'
#' @export
#' @examples
#' analyse_rasters_spatial ()

analyse_rasters_spatial = function(
    raster_files, cellsizes,
    calculations=c('calc_endemism'),
    result_list = 'SPATIAL_RESULTS',  #  should be plural and accept char vec
    ...){

  stopifnot("raster_files argument must be a character vector" = any(class(raster_files)=="character"))
  stopifnot(all(file.exists(rasters)))
  stopifnot("cellsizes argument must be a numeric vector" = any(class(cellsizes)=="numeric"))
  stopifnot("cellsizes must have exactly two axes" = length(cellsizes) == 2)

  config = start_server(...)
  str (config)
  message ("server process is live? ", config$process_object$is_alive())
  stopifnot(config$process_object$is_alive())  #  need a better error

  params = list (
    parameters = list (
      spatial_conditions = 'sp_self_only()',
      calculations = calculations,
      result_list = result_list
    ),
    bd = list (
      raster_files = raster_files,
      params = list (
        name = paste ('BiodiversR_analyse_rasters_spatial', Sys.time()),
        cellsizes = cellsizes
      )
    )
  )
  params_as_json = rjson::toJSON(params)


  target_url = paste0(config$server_url, '/analysis_spatial_oneshot')

  message (target_url)
  message ("Posting data ", params_as_json)
  response = httr::POST(
    url = target_url,
    # config = ...,
    body = params_as_json,
    encode = "json",
  )
  httr::stop_for_status(response)

  results = httr::content(response, "parsed")

  return (results)
}

