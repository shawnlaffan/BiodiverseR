#' Runs a randomisation analysis by calling the server
#' using a basedata object
#'
#'
#' @param bd list
#' @param rand_function character
#' @param iterations integer
#' @param name character
#' @param spatial_conditions character
#' @param def_query character
#' @param ...
#'
#' @return Returns the results from calling the server
#' 
#' @export
#' @examples
#' if(interactive()) {
#'   run_randomisation_analysis (
#'     bd                 = basedata$new(cellsizes=c(500,500))
#'     rand_function      = 'some_rand_function'
#'     iterations         = integer
#'     name               = 'some_name',
#'     spatial_conditions = c("calc_endemism_central", "calc_richness", "calc_pd"),
#'     def_query          = 'some_def_query'
#'     ...
#'   )
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

