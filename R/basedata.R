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
        name = date(),
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
    },
    set_name = function(val) {
      self$name = val
    },
    stop_server = function () {
      s = self$server$server_object
      if (!is_null_or_na(s)) {
        s$kill()
      }
      self$server = NULL
    },
    server_status = function () {
      s = self$server$server_object
      #  check status if not NULL
      ifelse (is_null_or_na(s), FALSE, s$is_alive())
    },
    finalize = function () {
      # message("Finalise called for ", self$name)
      self$stop_server()
    }
  )
)

is_null_or_na = function (x) {
  is.null(x) || is.na(x)
}

