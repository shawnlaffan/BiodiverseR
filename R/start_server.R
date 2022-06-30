#' Start the Biodiverse server
#'
#' Starts a Biodiverse server.
#' The server is shut down when the process object is garbage collected,
#' or an explicit kill command is called on it.
#'
#' By default it will find an empty port, but you can select one if you so choose.
#'
#' @param port integer
#' @param use_exe boolean
#'
#' @export
#' @examples
#' start_server(port=3001, use_exe=TRUE)

start_server = function(port=0, use_exe=FALSE){

  process = NULL  #  silence some check warnings
  bd_base_dir = Sys.getenv("Biodiverse_basepath")
  if (bd_base_dir == "") {
    message ("Env var Biodiverse_basepath not set, assuming ", getwd())
    bd_base_dir = getwd()
  }

  #  this runs the perl version - need to find a way to locate it relative to the package
  #  currently we need an env var to locate everything...
  #  maybe this: https://stackoverflow.com/questions/42492572/how-to-find-location-of-package
  if (use_exe) {
    #  non-windows won't have exe extension
    server_path = file.path(bd_base_dir, 'inst', 'perl', "BiodiverseR")
    if (Sys.info()[['sysname']] == "Windows") {
      server_path = sprintf("%s.exe", server_path)
    }
  } else {
    server_path = file.path(bd_base_dir, 'inst', 'perl', 'script', 'BiodiverseR')
  }
  message (sprintf("server_path is %s", server_path))
  if (!file.exists(server_path)) {
    message ("Cannot find server_path")
    stop()
  }

  host = "127.0.0.1"
  if (port == 0) {
    port = httpuv::randomPort(min = 1024L, max = 49151L, host = host, n = 20)
  }
  server_url = sprintf ("http://%s:%d", host, port)

  res = tryCatch ({
      #  need explicit perl call on windows
      # https://processx.r-lib.org/reference/process.html
      cmd = sprintf ("Command: %s daemon -l %s", server_path, server_url)
      message (cmd)
      #  no perl pfx on unix, let the shebang line do its work
      #  need to also send stdout and stderr to a log file
      message (paste (server_path, "daemon", "-l", server_url))

      process_object = processx::process$new(
        server_path, c("daemon", "-l", server_url),
        stdout = "",  #  dump log to stdout and stderr for debug
        stderr = ""
      )
    },
    error=function(err){
      message(paste("Server call resulted in an error:  ", err))
      stop()
    }
  )


  config = list (
    port = port,
    using_exe = use_exe,
    process_object = process_object,
    server_url = server_url
  )

  server_running = 0
  max_tries = 5
  trycount = 1
  while (server_running == 0 && trycount <= max_tries) {
    Sys.sleep(1) #  give the server a chance to get going
    response = tryCatch(
      {
        httr::GET(url = server_url)
        server_running = 1
      },
      error = function (c) {
        message(
          sprintf(
            "Server still coming up, trying again in 1 second (attempt %d of %d)",
            trycount, max_tries
          )
        )
      },
      finally = {
        trycount = trycount + 1
      }
    )
  }
  if (server_running == 0) {
    message ("server did not start in time")
    stop ()
  }

  return(config)
}

