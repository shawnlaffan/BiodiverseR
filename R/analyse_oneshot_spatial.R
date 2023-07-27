#' Use the Biodiverse server to load a set of rasters and then analyse them
#'
#' @param raster_files character
#' @param cellsizes numeric
#' @param calculations character
#' @param tree class phylo
#' @param ... passed on to start_server call
#'
#' @export
#' @examples
#' if(interactive()) {
#'   analyse_oneshot_spatial (
#'     raster_files = c("r1.tif", "r2.tif"),
#'     calculations = c("calc_endemism_central", "calc_richness", "calc_pd"),
#'     tree = some_phylo_tree
#'   )
#' }
#format for data is list(list(files), list(group_columns), list(label_columns), list(sample_count_columns)) # nolint
analyse_oneshot_spatial <- function(
    raster_files = NULL,
    r_data = NULL,
    spreadsheet_data = NULL,
    delimited_text_file_data = NULL,
    shapefile_data = NULL,
    cellsizes,
    calculations = c("calc_richness", "calc_endemism_central"),
    tree = NULL,
    ...) {

  stopifnot("cellsizes argument must be a numeric vector" = any(class(cellsizes) == "numeric")) # nolint
  stopifnot("cellsizes must have exactly two axes" = length(cellsizes) == 2)

  if (!is.null(tree)) {
    stopifnot("tree must be of class phylo or inherit from it" = inherits (tree, "phylo")) # nolint
  }

  config <- start_server(...)

  #prints out config, used for debugging
  message("server process is live? ", config$server_object$is_alive())
  stopifnot(config$server_object$is_alive())  #  need a better error

  #  unique-ish name that is human readable
  sp_output_name <- paste("BiodiversR_analyse_rasters_spatial", Sys.time())
  params <- list(
    analysis_config = list(
      spatial_conditions = "sp_self_only()",  #  limited options for now
      calculations = calculations
    ),
    raster_params = list(
      files = raster_files
    ),
    spreadsheet_params = convert_to_params(spreadsheet_data),
    delimited_text_params = convert_to_params(delimited_text_file_data),
    shapefile_params = convert_to_params(shapefile_data),
    bd = list(
      params = list(
        name = sp_output_name,
        cellsizes = cellsizes
      ),
    data = r_data
    ),
    tree = tree
  )
  params_as_json <- rjson::toJSON(params)

  target_url <- paste0(config$server_url, "/analysis_spatial_oneshot")

  response <- httr::POST(
    url = target_url,
    body = params_as_json,
    encode = "json",
  )
  httr::stop_for_status(response)

  call_results <- httr::content(response, "parsed")

  #  terminate the server - don't wait for garbage collection
  config$server_object$kill()

  processed_results <- list()
  #apply? - nah.  There will never be more than ten list elements
  #  convert list structure to a data frame
  #  maybe the server could give a more DF-like structure,
  #  but this is already an array
  for (list_name in sort(names(call_results))) {
    #Spatial results is the only result in our test case. Which contains a list of expected stuff # nolint
    message("Processing ", list_name)

    results <- call_results[[list_name]]  #  need to handle when it is not there
    header <- unlist(results[[1]])
    results[[1]] <- NULL  #  remove the header
    #99 percent sure this removes the names of the rows, like axis_0, can always check  #nolint

    df <- do.call(rbind, lapply(results, rbind)) |> as.data.frame()
    df[df == "NULL"] <- NA
    colnames(df) <- header
    if (header[1] == "ELEMENT") {
      #  make the element names the row names, and remove from main table
      row.names(df) <- df$ELEMENT
      df[[1]] <- NULL
      #  the other data are numeric for raster inputs
      for (c in colnames(df)) {
        df[[c]] <- as.numeric(df[[c]])
      }
    }
    processed_results[[list_name]] <- df
  }
  #check if the processign happened before this function, using  utils::str (call_results)

  return(processed_results)
}

#' Doodle and fiddle to get some args in the right format
#' @param list list
#' @noRd
convert_to_params <- function(list) {
  if (!is.null(list)) {

    #Check if the first file passed in is a shapefile or spreadsheet
    file_ends <- list(".shp", ".xlsx", ".xls", ".ods", ".sxc")
    flag <- FALSE
    for (i in seq(1, length(file_ends))) {
      if (grepl(file_ends[i], list[[1]][[1]])) {
        flag <- TRUE
      }
    }

    if (flag) {
      #format for shapefiles and spreadsheets
      return(list(files = list[[1]], group_field_names = list[[2]], label_field_names = list[[3]], sample_count_col_names = list[[4]])) # nolint
    } else {
      #format for delimited text files
      return(list(files = list[[1]], group_columns = list[[2]], label_columns = list[[3]], sample_count_columns = list[[4]])) # nolint
    }
  }
}
