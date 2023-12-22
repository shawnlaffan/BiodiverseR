#' Load data onto the server associated with
#' a BiodiverseR::basedata object
#'
#'
#' @param bd list
#' @param params list
#'
#' @export
#' @examples
#' if(interactive()) {
#'   b = BiodiverseR::basedata$new(name = "trial")
#'   success = b$load_data()
#' }
load_data_ = function (
    bd,
    params = list()
  ) {
  checkmate::assertR6(bd, c("basedata"))
  stopifnot(bd$server_status())

  #  a bit messy but allows for later expansion
  #  and still needs thought
  # params = as.list(match.call())
  # params[["bd"]] = NULL
  checkmate::assert_list(params, all.missing=FALSE)
  if(!is.null(params[["r_data"]])) {
    params[["bd_params"]] = params[["r_data"]]
    params[["r_data"]] = NULL
  }

  storage <- list()
  if(!is.null(params[["spreadsheet_params"]])) {
    coords_params <- c(params[["spreadsheet_params"]][["group_field_names"]][[1]], params[["spreadsheet_params"]][["group_field_names"]][[2]])
    ID_col_params <- params[["spreadsheet_params"]][["label_field_names"]][[1]]
    abund_col_params <- params[["spreadsheet_params"]][["sample_count_col_names"]][[1]]
    for (i in 1:length(params[["spreadsheet_params"]][["files"]])) {
      result <- agg2groups(x = params[["spreadsheet_params"]][["files"]][i], coords = coords_params, ID_col = ID_col_params, abund_col = abund_col_params)
      storage <- append(storage, result)
    }
  } 
  if(!is.null(params[["delimited_text_params"]])) {
    message("DT PARAMS")
    print(params[["delimited_text_params"]])
  }
  if(!is.null(params[["shapefile_params"]])) {
    message("SHAPEFILE PARAMS")
    print(params[["shapefile_params"]])
  }
  params[["r_data"]] = storage

  result = bd$call_server("bd_load_data", params)

  result
}
