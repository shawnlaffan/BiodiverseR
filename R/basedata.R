library("R6")


#  make this exported
basedata = R6Class("basedata",
   cloneable = FALSE, #  we need to dup the server for this to work
   public = list(
    name   = NULL,
    server = NULL,
    initialize = function(name = date(), port=0, use_exe=FALSE, perl_path=NA) {
      self$name = name
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
      self$server$server_object$kill()
      self$server = NULL
    },
    server_status = function () {
      s = self$server$server_object
      #  check status if not NULL
      ifelse (is_null_or_na(s), FALSE, s$is_alive())
    },
    finalize = function () {
      self$stop_server()
    }
  )
)

is_null_or_na = function (x) {
  is.null(x) || is.na(x)
}

