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
run_randomisation_analysis = function (
    bd,
    rand_function = 'rand_structured',
    iterations = 999,
    name = NULL,
    spatial_conditions = NULL,
    def_query = NULL,
    ...
) {
  checkmate::assertR6(bd, c("basedata"))
  stopifnot(bd$server_status())

  params = list (
    "function" = rand_function,
    name = name,
    spatial_conditions = spatial_conditions,
    definition_query = def_query,
    ...
  )

  call_results = bd$call_server("bd_run_randomisation_analysis", params)

  return(call_results)
}


process_tabular_results = function (call_results) {
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

  processed_results
}
