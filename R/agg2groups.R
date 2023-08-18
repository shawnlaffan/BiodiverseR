#' Create groups for Biodiverse
#'
#'Use R to aggregate input data from several formats into user-defined groups
#'
#'
#' @param x input data as path, data source name to be passed to st_read, data.frame, sf object, or SpatRaster object
#' @param layer in case of shapefile data format: name of layer to be passed to st_read
#' @param coords in case of point data: names or numbers of the numeric columns holding coordinates, to be passed to st_as_sf. Required if reading data from .xls file or inputting data.frame
#' @param abund_col name of column containing abundances; defaults to "count" and is assumed to be 1 for all records if no column specified and count column is absent
#' @param ID_col name of column containing data labels or species names. In the event of multiple label columns, further names can be passed in using ... parameter
#' @param res numeric; size of desired groups
#' @param origin numeric vector of 2 numbers specifying the x and y dimensions of the spatial groups into which data needs to be aggregated. Units should be the same as the data projection, usually metres.
#' @param fun name of aggregation function to be used. Defaults to sum.
#' @param ... passed on to agg2groups call as grouping/ID variables.
#'
#' @return Named list of numeric vectors corresponding to the result of the aggregation function for each unique label in the data. Names correspond to coordinates of bottom left corner of each group. This format is needed to pass through to Biodiverse server.
#'
#' @examples
#' agg2groups("./inst/extdata/r1.tif")
#' agg2groups("./inst/extdata/", layer = "r1")
#'


agg2groups <- function (x, ...) {
  UseMethod("agg2groups", x)
}

# read in files from path names, call appropriate method
agg2groups.character <- function(x, layer, coords = NULL, ...) {
  # recognise file type at end of path
  csv <- grepl(pattern = ".*?\\.csv$", x = x)
  xls <- grepl(pattern = ".*?\\.xlsx$", x = x)
  tif <- grepl(pattern = ".*?\\.tif$", x = x)
  shp <- grepl(pattern = ".*?/$", x = x)
  if(!csv & !xls & !tif) shp <- TRUE  #assume shp file if other types not recognised

  # read in data accordingly, as spatial object if possible.
  if(csv){
    out <- st_read(x, options=c("X_POSSIBLE_NAMES=x*, X*,lon*","Y_POSSIBLE_NAMES=y*, Y*, lat*"), quiet = T)
    if(!"sf" %in% class(out)) out <- st_as_sf(out, coords = coords, ...) # if coords not in defaults, add coords to make sf
  } else if(xls) {out <- st_read(x, quiet = TRUE)
    if(!is.null(coords)) out <- st_as_sf(out, coords = coords, ...)} # if coords specified, make sf
  if(shp) out <- st_read(x, layer = layer)
  if(tif) out <- rast(x)

  if("data.frame" == class(out)[1]) return(agg2groups.data.frame(out, coords, ...))
  if("sf" == class(out)[1]) return(agg2groups.sf(out, ...))
  if("SpatRaster" == class(out)[1]) return(agg2groups.SpatRaster(out, ...))

}

# change to sf based on coords, call sf method
agg2groups.data.frame <- function(x, coords, ...) {

  x <- st_as_sf(x, coords = coords)
  agg2groups.sf(x, ...)
}

# spatial aggregation, count and label columns specified with convenient defaults
agg2groups.sf <- function(x, abund_col = count, ID_col = label, res = 100, origin = c(0,0), fun = sum, ...) {
  # add XY if not present
  if(!all(c("X", "Y") %in% names(x))) x <- data.frame(x, st_coordinates(x))

  abund_col <- enquo(abund_col)
  ID_col <- enquo(ID_col)

  if(!quo_name(abund_col) %in% names(x)){
    message(paste("Column", quo_name(abund_col), "not found. Defaulting to all counts = 1."))
    x <- x %>% mutate(!!abund_col := 1)
  }

  # aggregate and summarise
  out <- x %>% group_by(x = round_any(X, res, origin = origin[1]),
                        y = round_any(Y, res, origin = origin[2]),
                        !!ID_col,
                        !!! ensym(...)) %>%
    summarise(value := fun(as.numeric(!!abund_col))) %>% st_drop_geometry()

  # change to format required by json
  names <- paste(out$x, out$y, sep = ":")
  out <- out %>% ungroup %>% dplyr::select(-x, -y) %>% split(names) %>%
    purrr::map(~tidyr::pivot_wider(.x, names_from = c(!!ID_col, !!! ensym(...)), values_from = value) %>% unlist())

  return(out)
}

# raster aggregation
agg2groups.SpatRaster <- function(x, res = 100, ...) {
 temp <- aggregate(x, fact = res/res(x), fun = sum, ...) |>
    as.data.frame(xy = TRUE) |>
    mutate(x = x - res/2, y = y - res/2) # change xy to represent bottom left corner rather than centre of cell

  # change data format to json
  names <- paste(temp$x, temp$y, sep = ":")
  out <- temp |> dplyr::select(-x, -y) |> split(names) |> purrr::map(unlist)

  return(out)
}


round_any <- function(number, accuracy = 100, origin = 0, f = floor){
  (f((number-origin)/accuracy) * accuracy) + origin
  }

