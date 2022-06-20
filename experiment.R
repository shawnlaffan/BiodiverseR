library ("rjson")


sp_data = list (
  '50:50'   = list (label1 = 1, label2 = 1),
  '150:150' = list (label1 = 1, label2 = 1)
)
bd_params = list (
  name = 'blognorb',
  cellsizes = c(100,100)
)

str = list (
  parameters = list (
    spatial_conditions = 'sp_self_only()',
    calculations = c ('calc_endemism', 'calc_richness'),
    result_list = 'SPATIAL_RESULTS'
  ),
  bd = list (data = sp_data, params = bd_params)
)

write (toJSON (str), "somefile.json")


df = data.frame (
  labels = c("a", "b", "c"),
  x = c(1:3),
  y = c(1:3),
  samples = c(1:3)
)
write (toJSON (as.list(df)), "somedf.json")


source ("R/run_oneshot.R")
config = start_service()

# message (config)

str (config)
message ("live? ", config$process$is_alive())
message ("sleep now, perchance to dream")
Sys.sleep (10)
config$process$kill()
message ("live? ", config$process$is_alive())

config$process = NA
