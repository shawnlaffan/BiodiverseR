#' Create groups for Biodiverse
#'
#'Use R to aggregate input data from several formats into user-defined groups
#'
#'
#' @param x input data as path, data source name to be passed to st_read, data.frame, sf object, or SpatRaster object
#' @param layer in case of shapefile data format: name of layer to be passed to st_read
#' @param coords in case of point data: names or numbers of the numeric columns holding coordinates, to be passed to st_as_sf. Required if reading data from .xls file or inputting data.frame
#' @param abund_col character vector containing the name of column(s) with abundances; defaults to "count" and is assumed to be 1 for all records if no column specified and count column is absent
#' @param ID_col character vector containing the name of column(s) with data labels or species names. Defaults to "label"
#' @param group_col character vector containing the name of column(s) with attribute data by which to group observations.
#' @param cellsize numeric vector indicating the size of desired groups in up to 4 dimensions. If 0, exact point matches are aggregated. A negative number will aggregate based on attributes in group_col.
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
agg2groups.sf <- function(x, abund_col = c("count"), ID_col = c("label"), group_col, cellsize = 100, origin = c(0,0), fun = sum, ...) {
  # add XY if not present
  if(!all(c("X", "Y") %in% names(x))) x <- data.frame(x, st_coordinates(x))

  #abund_col <- enquo(abund_col)
  #ID_col <- enquo(ID_col)

  # check for existence of abund_col names
  if(!all(abund_col %in% names(x))){
    missing <- abund_col[!abund_col %in% names(x)]
    if(length(abund_col) > 1){
      if(length(missing) == length(abund_col)){
        message("Abundance columns not found. Reverting to default: count = 1 for all rows.")
        abund_col <- "count"
        x <- x %>% mutate("{abund_col}" = 1)

      }else{message(paste("Column ", missing[1], " not found. Missing columns are ignored."))
        abund_col <- abund_col[abund_col %in% names(x)]
      }

    }
    if(length(abund_col) == 1){
      message(paste("Column ", missing, " not found. Defaulting to count = 1."))
      x <- x %>% mutate("{abund_col}" = 1)
    }
  }


  # aggregate and summarise
  if(length(cellsize) == 1){
    if(cellsize > 0){
      out <- x %>% mutate(x = round_any(X, cellsize, origin = origin[1]),
                          y = round_any(Y, cellsize, origin = origin[2])) %>%
        group_by(across(c(x, y, all_of(ID_col)))) %>%
        summarise(value := across(all_of(abund_col), fun)) %>% st_drop_geometry()
    }
    if(cellsize == 0 ){
      out <- x %>% group_by(across(c(x=X, y=Y, all_of(ID_col)))) %>%
        summarise(value := across(all_of(abund_col), fun)) %>% st_drop_geometry()
    }
    if(cellsize < 0){
      out <- x %>% group_by(all_of(group_col), all_of(ID_col)) %>%
        summarise(value := across(all_of(abund_col), fun)) %>% st_drop_geometry()
    }
  }else if(length(cellsize) == 2) {
    out <- x %>% group_by(x = round_any(X, cellsize[1], origin = origin[1]),
                          y = round_any(Y, cellsize[2], origin = origin[2]),
                          all_of(ID_col)) %>%
      summarise(value := across(all_of(abund_col), fun)) %>% st_drop_geometry()
  }


  # change to format required by json
  #names <- paste(out$x, out$y, sep = ":")
  names <- out %>% select(group_cols()) %>% apply(1, paste, collapse = ":")
  out <- out %>% split(names) %>%
    purrr::map(~tidyr::pivot_wider(.x, names_from = all_of(ID_col), values_from = value) %>% unlist())

  return(out)
}

# raster aggregation
agg2groups.SpatRaster <- function(x, cellsize = 100, ...) {
 temp <- aggregate(x, fact = cellsize/res(x), fun = sum, ...) |>
    as.data.frame(xy = TRUE) |>
    mutate(x = x - cellsize/2, y = y - cellsize/2) # change xy to represent bottom left corner rather than centre of cell

  # change data format to json
  names <- paste(temp$x, temp$y, sep = ":")
  out <- temp |> dplyr::select(-x, -y) |> split(names) |> purrr::map(unlist)

  return(out)
}


round_any <- function(number, accuracy = 100, origin = 0, f = floor){
  (f((number-origin)/accuracy) * accuracy) + origin
  }

