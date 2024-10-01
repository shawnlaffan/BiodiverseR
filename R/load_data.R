#' Load data onto the server associated with
#' a BiodiverseR::basedata object
#'
#'
#' @param bd class R6 basedata
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
  if(!is.null(params[["bd_params"]])) {
    # assert bd_params[["data"]] is not null

  }
  #  if we have bd_params then it must have a "data" item

  result = bd$call_server("bd_load_data", params)

  result
}
