#' Export parameters to file
#'
#' @param config Configuration data frame (as loaded by parse_params)
#' @param file Filename where the parameters will be exported
#' @param overwrite (Default FALSE) Set TRUE to overwrite the parameters file
#'
#' @return Nothing
#' @export
#'
export_params <- function(config, file, overwrite = FALSE) {
  # Remove if already exists
  if (file.exists(file) && overwrite) file.remove(file)
  if (file.exists(file) && !overwrite) stop("The parameter file already exists")

  # If the config input is a list, transform it to data frame
  if (inherits(config, "list")) config <- cfgl_to_df(config)

  # Create content
  header <- "++PARAM_LEVEL2_START++"
  data <- paste(rownames(config), config$value, sep = " = ")
  footer <- "++PARAM_LEVEL2_END++"

  # Write to file
  fileConn <- file(file)
  writeLines(c(header, data, footer), con = fileConn)
  close(fileConn)
}

#' Import parameters as data frame
#'
#' Checks the FORCE parameter file, and imports its contents as a data frame
#' More info at
#' \url{https://force-eo.readthedocs.io/en/latest/components/lower-level/level2/param.html}
#'
#' @param file The parameters file
#' @param as.list Import as list instead of as data.frame
#'
#' @return The contents of the file, as a data frame or a list
#'
import_params <- function(file = "data/param/l2param.prm", as.list = FALSE) {
    # Import file
    lines <- import_lines(file)

    # Convert to dataframe
    df <- as.data.frame(lines)
    df <- as.data.frame(stringr::str_split_fixed(df$lines, " = ", 2))
    colnames(df) <- c("key", "value")

    # Use key as row identifier instead of as value
    rownames(df) <- df[, "key"] # Assign keys to rownames...
    df[, "key"] <- NULL # ... and drop their values

    # Convert to list if desired
    if(as.list) df <- cfg_to_list(df)

    return(df)
}

#' Auxiliary function for generating a parameters' data frame
#'
#' More info at
#' \url{https://force-eo.readthedocs.io/en/latest/components/lower-level/level2/param.html}
#'
#' @param FILE_QUEUE See link above
#' @param DIR_LEVEL2 See link above
#' @param DIR_LOG See link above
#' @param DIR_TEMP See link above
#' @param FILE_DEM See link above
#' @param DEM_NODATA See link above
#' @param DO_REPROJ See link above
#' @param DO_TILE See link above
#' @param FILE_TILE See link above
#' @param TILE_SIZE See link above
#' @param BLOCK_SIZE See link above
#' @param RESOLUTION_LANDSAT See link above
#' @param RESOLUTION_SENTINEL2 See link above
#' @param ORIGIN_LON See link above
#' @param ORIGIN_LAT See link above
#' @param PROJECTION See link above
#' @param RESAMPLING See link above
#' @param DO_ATMO See link above
#' @param DO_TOPO See link above
#' @param DO_BRDF See link above
#' @param ADJACENCY_EFFECT See link above
#' @param MULTI_SCATTERING See link above
#' @param DIR_WVPLUT See link above
#' @param WATER_VAPOR See link above
#' @param DO_AOD See link above
#' @param DIR_AOD See link above
#' @param ERASE_CLOUDS See link above
#' @param MAX_CLOUD_COVER_FRAME See link above
#' @param MAX_CLOUD_COVER_TILE See link above
#' @param CLOUD_BUFFER See link above
#' @param SHADOW_BUFFER See link above
#' @param SNOW_BUFFER See link above
#' @param CLOUD_THRESHOLD See link above
#' @param SHADOW_THRESHOLD See link above
#' @param RES_MERGE See link above
#' @param DIR_COREG_BASE See link above
#' @param COREG_BASE_NODATA See link above
#' @param IMPULSE_NOISE See link above
#' @param BUFFER_NODATA See link above
#' @param TIER See link above
#' @param NPROC See link above
#' @param NTHREAD See link above
#' @param PARALLEL_READS See link above
#' @param DELAY See link above
#' @param TIMEOUT_ZIP See link above
#' @param OUTPUT_FORMAT See link above
#' @param OUTPUT_DST See link above
#' @param OUTPUT_AOD See link above
#' @param OUTPUT_WVP See link above
#' @param OUTPUT_VZN See link above
#' @param OUTPUT_HOT See link above
#' @param OUTPUT_OVV See link above
#' @param as.list Output a list instead of a data.frame
#'
#' @return A data frame or list containing the parameters and its values
#' @export
#'
gen_params <- function(FILE_QUEUE = "data/level1/queue.txt",
                       DIR_LEVEL2 = "data/level2",
                       DIR_LOG = "data/log",
                       DIR_TEMP = "data/temp",
                       FILE_DEM = "data/misc/dem/srtm.vrt",
                       DEM_NODATA = "-32768",
                       DO_REPROJ = "TRUE",
                       DO_TILE = "TRUE",
                       FILE_TILE = "NULL",
                       TILE_SIZE = "3000",
                       BLOCK_SIZE = "300",
                       RESOLUTION_LANDSAT = "30",
                       RESOLUTION_SENTINEL2 = "10",
                       ORIGIN_LON = "-90",
                       ORIGIN_LAT = "60",
                       PROJECTION = "GLANCE7",
                       RESAMPLING = "NN",
                       DO_ATMO = "TRUE",
                       DO_TOPO = "TRUE",
                       DO_BRDF = "TRUE",
                       ADJACENCY_EFFECT = "TRUE",
                       MULTI_SCATTERING = "TRUE",
                       DIR_WVPLUT = "data/misc/wvp",
                       WATER_VAPOR = "NULL",
                       DO_AOD = "TRUE",
                       DIR_AOD = "NULL",
                       ERASE_CLOUDS = "FALSE",
                       MAX_CLOUD_COVER_FRAME = "75",
                       MAX_CLOUD_COVER_TILE  = "75",
                       CLOUD_BUFFER = "300",
                       SHADOW_BUFFER = "90",
                       SNOW_BUFFER = "30",
                       CLOUD_THRESHOLD= "0.225",
                       SHADOW_THRESHOLD = "0.02",
                       RES_MERGE = "REGRESSION",
                       DIR_COREG_BASE = "NULL",
                       COREG_BASE_NODATA = "-9999",
                       IMPULSE_NOISE = "TRUE",
                       BUFFER_NODATA = "FALSE",
                       TIER = "1",
                       NPROC = "1",
                       NTHREAD = "1",
                       PARALLEL_READS = "FALSE",
                       DELAY = "10",
                       TIMEOUT_ZIP = "30",
                       OUTPUT_FORMAT = "GTiff",
                       OUTPUT_DST = "TRUE",
                       OUTPUT_AOD = "FALSE",
                       OUTPUT_WVP = "FALSE",
                       OUTPUT_VZN = "TRUE",
                       OUTPUT_HOT = "TRUE",
                       OUTPUT_OVV = "TRUE",
                       as.list = FALSE) {
  # Use introspection to read the arguments' names and values
  values <- as.list(environment()) # Arguments' values (at this moment the
  # environment only contains the input parameters)
  keys <- formalArgs("gen_params") # Arguments' names ("FILE_QUEUE", ...)

  # Store as data frame
  cfg <- data.frame() # Initialize ...
  for (i in 1:(length(keys)-1)) { # ... and fill row by row (ignoring as.list)
    cfg <- rbind(cfg, data.frame(row.names = keys[i], value = values[i][[1]]))
  }

  # Convert to list if desired
  if (as.list) cfg <- cfg_to_list(cfg)

  return(cfg)
}

#' Import parameters
#'
#' Checks the FORCE parameter file, and imports its contents as a list of lines
#' This is an auxiliary function
#'
#' @param file The parameters file
#'
#' @return The data in the file, line by line, filtering out non-data lines
#'
import_lines <- function(file = "data/param/l2param.prm") {
    # Import files
    lines <- readLines(file)

    # Drop comments and empty lines
    lines <- lines[!grepl("^#", lines)]
    lines <- lines[!grepl("^$", lines)]

    # Assert that the file is properly formatted ...
    if (lines[1]             != "++PARAM_LEVEL2_START++" |
        lines[length(lines)] != "++PARAM_LEVEL2_END++") {
          stop("The parameter file is not properly formatted")
    }

    # ... and drop those lines after asserting they are right
    lines <- lines[!grepl("^\\+\\+PARAM_LEVEL2_START\\+\\+$", lines)]
    lines <- lines[!grepl("^\\+\\+PARAM_LEVEL2_END\\+\\+$", lines)]

    return(lines)
}

#' Convert config data frame to list
#'
#' Using a list instead of a data frame can be practical. For instance, it
#' allows using the $ operator for extracting values.
#'
#' @param cfg The configuration data frame
#'
#' @return The configuration list
#'
cfg_to_list <- function(cfg) {
  cfgl <- as.list(t(cfg))
  names(cfgl) <- rownames(cfg)

  return(cfgl)
}

#' Convert config list to data frame
#'
#' @param cfgl The configuration list
#'
#' @return The configuration data frame
#'
cfgl_to_df <- function(cfgl) {
  cfg <- as.data.frame(t(as.data.frame(cfgl)))
  colnames(cfg) <- "value"

  return(cfg)
}
