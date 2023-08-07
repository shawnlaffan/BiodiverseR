# libraries
#library(sf)
#library(raster)
#library(dplyr)
#library(tidyr)
#library(purrr)

#generic function
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
  if(tif) out <- raster(x)

  if("data.frame" == class(out)[1]) return(agg2groups.data.frame(out, coords, ...))
  if("sf" == class(out)[1]) return(agg2groups.sf(out, ...))
  if("RasterLayer" == class(out)[1]) return(agg2groups.RasterLayer(out, ...))

}

# change to sf based on coords, call sf method
agg2groups.data.frame <- function(x, coords, ...) {

  x <- st_as_sf(x, coords = coords)
  agg2groups.sf(x, ...)
}

# spatial aggregation, count and label columns specified with convenient defaults
agg2groups.sf <- function(x, abund_col = count, ID_col = label, res = 100, origin = c(0,0), ...) {
  # add XY if not present
  if(!all(c("X", "Y") %in% names(x))) x <- data.frame(x, st_coordinates(x))

  abund_col <- enquo(abund_col)
  ID_col <- enquo(ID_col)

  if(!quo_name(abund_col) %in% names(x)){
    message(paste("Column", quo_name(abund_col), "not found. Defaulting to all counts = 1."))
    x <- x %>% mutate(!!abund_col := 1)
  }

  # aggregate and summarise
  out <- x %>% group_by(x = round_any(X, res, origin = origin[1]), y = round_any(Y, res, origin = origin[2]), !!ID_col) %>%
    summarise(sum := sum(as.numeric(!!abund_col))) %>% st_drop_geometry()

  # change to format required by json
  names <- paste(out$x, out$y, sep = ":")
  out <- out %>% ungroup %>% dplyr::select(-x, -y) %>% split(names) %>%
    purrr::map(~tidyr::pivot_wider(.x, names_from = !!ID_col, values_from = sum) %>% unlist())

  return(out)
}

# raster aggregation
agg2groups.RasterLayer <- function(x, res = 100, ...) {
 temp <- aggregate(x, fact = res/res(x), fun = sum, ...) %>%
    as.data.frame(xy = TRUE) %>%
    mutate(x = x - res/2, y = y - res/2)

  # change data format to json
  names <- paste(temp$x, temp$y, sep = ":")
  out <- temp %>% dplyr::select(-x, -y) %>% split(names) %>% purrr::map(unlist)

  return(out)
}

#agg2groups.default <- function(x, ...){} # not implemented, can't think what default behaviour should be.


round_any <- function(number, accuracy = 100, origin = 0, f = floor){
  (f((number-origin)/accuracy) * accuracy) + origin
  }

