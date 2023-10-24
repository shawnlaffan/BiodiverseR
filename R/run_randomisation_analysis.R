#' Load data onto the server associated with
#' a BiodiverseR::basedata object
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

