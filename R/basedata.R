library("R6")


#' Create a new BiodiverseR::basedata object
#' and its associated server object.
#'
#' Data can then be loaded onto the server,
#' analyses run and results returned.
#'
#' @param name character
#' @param cellsizes numeric
#' @param cellorigins numeric
#' @param name character
#' @param port integer
#' @param use_exe boolean
#' @param perl_path character
#'
#' @export
#' @examples
#' if(interactive()) {
#'   b = BiodiverseR::basedata$new(name = "trial")
#' }
basedata = R6Class("basedata",
   cloneable = FALSE, #  we need to dup the server for this to work
   public = list(
    name   = NULL,
    server = NULL,
    cellsizes   = NULL,
    cellorigins = NULL,
    initialize = function(
        name = paste("BiodiverseR::basedata", date()),
        cellsizes,
        cellorigins,
        port=0, use_exe=FALSE, perl_path=NA
      ) {
      self$name = name

      checkmate::assert_vector(cellsizes, any.missing=FALSE, min.len=1)
      checkmate::assert_numeric(cellsizes)
      self$cellsizes = cellsizes

      if (missing(cellorigins)) {
        cellorigins = cellsizes * 0
      }
      checkmate::assert_vector(cellorigins, any.missing=FALSE, min.len=1)
      checkmate::assert_numeric(cellorigins)
      if (length(cellsizes) != length(cellorigins)) {
        stop("cellsizes and cellorigins vectors must of of same length")
      }
      self$cellorigins = cellorigins

      self$server = BiodiverseR::start_server(
        port=port,
        use_exe=use_exe,
        perl_path=perl_path
      )
      p = list (
        name = self$name,
        cellsizes = self$cellsizes,
        cellorigins = self$cellorigins
      )
      self$call_server (call_path = "init_basedata", params = p)

      return (self)
    },
    set_name = function(val) {
      self$name = val
    },
    stop_server = function () {
      s = self$server$server_object
      tryCatch({
          s$kill()
        },
        error= function (e) {}
      )
      self$server = NULL
    },
    server_status = function () {
      s = self$server$server_object
      result = tryCatch ({
          s$is_alive()
        },
        error = function () {FALSE}
      )
      return (result)
    },
    call_server = function (call_path, params=NULL) {
      target_url <- paste(self$server$server_url, call_path, sep = "/")

#message(target_url)

      #  filter any nulls
      if (!is.null(params)) {
        params[sapply(params, is.null)] <- NULL
        params_as_json <- rjson::toJSON(params)
      }
      else {
        params_as_json = ""
      }
# message ("about to run call, params are:")
# message (params_as_json)
# message ("\n")
      response <- httr::POST(
        url = target_url,
        body = params_as_json,
        encode = "json",
      )
      httr::stop_for_status(response)

      call_results <- httr::content(response, "parsed")
      #  check the error field
      e = call_results[['error']]
      if (
           (checkmate::test_scalar(e) && e != "")
        || !checkmate::test_scalar(e) && length(e)
        ) {
        message ("ERROR is :", e, ":")
        stop (e)
      }

      call_results[['result']]
    },
    load_data = function (params) {
      BiodiverseR:::load_data_(self, params = params)
    },
    run_spatial_analysis = function (
        spatial_conditions = c('sp_self_only()'),
        calculations,
        tree
      ) {
      BiodiverseR:::run_spatial_analysis(
        self,
        calculations = calculations,
        spatial_conditions = spatial_conditions,
        tree = tree
      )
    },
    finalize = function () {
      # message("Finalise called for ", self$name)
      self$stop_server()
    }
  )
)


