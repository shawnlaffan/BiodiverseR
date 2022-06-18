#' Start the Biodiverse server
#'
#' Starts a Biodiverse server.
#' The server is shut down when the process object is garbage collected,
#' or an explicit kill command is called on it.
#'
#' By default it will find an empty port, but you can select one if you so choose.
#' (OK, this still have to be implemented...)
#'
#' @param port integer
#' @param use_exe boolean
#'
#' @export
#' @examples
#' start_server(port=3001, use_exe=TRUE)

start_server = function(port=3001, use_exe=FALSE){

  process = NULL  #  silence some check warnings

  #  this should not be here - it should be loaded already
  # library("processx")

  #  this runs the perl version - need to find a way to locate it relative to the package
  #  currently we need an env var to locate everything...
  #  maybe this: https://stackoverflow.com/questions/42492572/how-to-find-location-of-package
  server_path = file.path(Sys.getenv('BiodiverseR_base'), 'perl', 'script', 'BiodiverseR')
  message (sprintf("server_path is %s", server_path))
  if (!file.exists(server_path)) {
    message ("Cannot find server_path")
  }

  res = tryCatch ({
    #  need explicit perl call on windows
    # https://processx.r-lib.org/reference/process.html
    cmd = sprintf ("perl %s daemon", server_path)
    message (cmd)
    #  no perl pfx, let the shebang line do its work
    #  need to also send stdout and stderr to a log file
    process_object = process$new(server_path, "daemon")
  },
  error=function(cond){
    message(cond)
    stop()
  })


  config = list (port = port, use_exe = use_exe, process_object = process_object)

  return(config)
}
