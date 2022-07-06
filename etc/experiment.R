devtools::load_all()
library ("rjson")
library("httpuv")  #  should be loaded?
library("processx")
library("httr")
library("fs")

#  from https://stackoverflow.com/questions/39285570/error-in-curlcurl-fetch-memoryurl-handle-handle-couldnt-connect-to-ser
#  need to look into what exactly it does, and its portability
# set_config(use_proxy(url="10.3.100.207",port=8080))
# set_config(
#   use_proxy(url="127.0.0.1", port=8080)
# )


sp_data = list (
  '50:50'   = list (label1 = 1, label2 = 1),
  '150:150' = list (label1 = 1, label2 = 1)
)
bd_params = list (
  name = 'blognorb',
  cellsizes = c(100,100)
)

params_str = list (
  parameters = list (
    spatial_conditions = 'sp_self_only()',
    calculations = c ('calc_endemism', 'calc_richness'),
    result_lists = c('SPATIAL_RESULTS')
  ),
  bd = list (data = sp_data, params = bd_params)
)
params_str_as_json = toJSON(params_str)


raster_files = fs::path_abs(list.files(path="./inst/perl/t/data", pattern=".tif$", full.names=TRUE))
params_str_rasters = list (
  parameters = list (
    spatial_conditions = 'sp_self_only()',
    calculations = c ('calc_endemism', 'calc_richness'),
    result_lists = c('SPATIAL_RESULTS')
  ),
  bd = list (raster_files = raster_files, params = bd_params)
)
params_str_rasters_as_json = toJSON(params_str_rasters)

# write (toJSON (params_str), "somefile.json")


# df = data.frame (
#   labels = c("a", "b", "c"),
#   x = c(1:3),
#   y = c(1:3),
#   samples = c(1:3)
# )
# write (toJSON (as.list(df)), "somedf.json")


call_running_server = function (p = params_str_as_json) {
  message ("Posting data to already running server")
  response = POST(
    url = 'http://127.0.0.1:3000/analysis_spatial_oneshot',
    # config = ...,
    body = p,
    encode = "raw",
  )
  results = content(response)
  # message(results[[1]])
  return (results)
}


call_bd_server = function (p = params_str_as_json) {
  # source ("R/run_oneshot.R")
  config = start_server()

  # message (config)

  str (config)
  message ("server process is live? ", config$process_object$is_alive())

  server_url = config$server_url

  # Sys.sleep(2)

  # browser()

  message ("getting data")
  message (server_url)
  response = tryCatch(
    {
      GET(
        url = server_url,
      )
    },
    error = function (c) {
      message("Got an error")
    }
  )
  # message (config$process_object$read_error_lines())
  # message (str(response))
  # message (response)

  # browser()

  #options(internet.info = 0)
  # message ("Calling POST")
  message (paste0(server_url, '/analysis_spatial_oneshot'))
  message ("Posting data ", p)
  response = POST(
    url = paste0(server_url, '/analysis_spatial_oneshot'),
    # config = ...,
    body = p,
    encode = "json",
  )
  #
  # str (response)
  return (response)
}

call_bd_server_w_rasters = function (p = params_str_rasters_as_json, use_exe=FALSE) {
  # source ("R/run_oneshot.R")
  config = start_server(use_exe = use_exe)

  # message (config)

  str (config)
  message ("server process is live? ", config$process_object$is_alive())

  server_url = config$server_url

  # Sys.sleep(2)

  # browser()

  message ("getting data")
  message (server_url)
  response = tryCatch(
    {
      GET(
        url = server_url,
      )
    },
    error = function (c) {
      message("Got an error")
    }
  )
  # message (config$process_object$read_error_lines())
  # message (str(response))
  # message (response)

  # browser()

  #options(internet.info = 0)
  # message ("Calling POST")
  message (paste0(server_url, '/analysis_spatial_oneshot'))
  message ("Posting data ", p)
  response = POST(
    url = paste0(server_url, '/analysis_spatial_oneshot'),
    # config = ...,
    body = p,
    encode = "json",
  )
  #
  # str (response)
  return (response)
}


# message ("sleep now, perchance to dream")
# Sys.sleep (5)
# # config$process$kill()
# config$process_object = NA
# gc()
# # message ("live? ", config$process_object$is_alive())
#


