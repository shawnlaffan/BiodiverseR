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
  # Call aggregate function for spreadsheets
  if(!is.null(params[["spreadsheet_params"]])) {
    coords_params <- c(params[["spreadsheet_params"]][["group_field_names"]][[1]], params[["spreadsheet_params"]][["group_field_names"]][[2]])
    ID_col_params <- params[["spreadsheet_params"]][["label_field_names"]][[1]]
    abund_col_params <- params[["spreadsheet_params"]][["sample_count_col_names"]][[1]]
    for (i in 1:length(params[["spreadsheet_params"]][["files"]])) {
      # result <- agg2groups(x = params[["spreadsheet_params"]][["files"]][i], coords = coords_params, ID_col = ID_col_params, abund_col = abund_col_params)
      storage <- append(storage, result)
    }
  } 
  # Call aggregate functions for delimited text
  if(!is.null(params[["delimited_text_params"]])) {
    for (i in 1:length(params[["delimited_text_params"]][["files"]])) {
      file_col_names <- colnames(read.csv(params[["delimited_text_params"]][["files"]][i]))
      ID_col_index <- params[["delimited_text_params"]][["label_columns"]][[1]]
      abund_col_index <- params[["delimited_text_params"]][["sample_count_columns"]][[1]]
      ID_col_params <- file_col_names[ID_col_index + 1]
      abund_col_params <- file_col_names[abund_col_index + 1]
      group_col_params <- c(file_col_names[params[["delimited_text_params"]][["group_columns"]][[1]] + 1], file_col_names[params[["delimited_text_params"]][["group_columns"]][[2]] + 1])
      # result <- agg2groups(x = params[["delimited_text_params"]][["files"]][i], abund_col = abund_col_params, ID_col = ID_col_params, group_col = group_col_params)
      storage <- append(storage, result)
    }
  }
  # Call aggregate functions for shapefiles
  if(!is.null(params[["shapefile_params"]])) {
    layer_params <- c(params[["shapefile_params"]][["group_field_names"]][[1]], params[["shapefile_params"]][["group_field_names"]][[2]])
    ID_col_params <- params[["shapefile_params"]][["label_field_names"]][[1]]
    abund_col_params <- params[["shapefile_params"]][["sample_count_col_names"]][[1]]
    for (i in 1:length(params[["shapefile_params"]][["files"]])) {
      # result <- agg2groups(x = params[["shapefile_params"]][["files"]][i], coords = layer_params, ID_col = ID_col_params, abund_col = abund_col_params)
      storage <- append(storage, result)
    }
  }
  # Call aggregate functions for raster
  if(!is.null(params[["raster_params"]])) {
    message("RASTER PARAMS")
    print(params[["raster_params"]])
    for (i in 1:length(params[["raster_params"]][["files"]])) {
      if (is.null(params[["raster_params"]][["files"]][i])) {
        next
      }
      # result <- agg2groups(x = params[["raster_params"]][["files"]][i])
      storage <- append(storage, result)
    }
  }
  # Append the aggregate data to r_data
  # params[["r_data"]] = storage

  result = bd$call_server("bd_load_data", params)

  result
}
