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

  # Create content
  header <- "++PARAM_LEVEL2_START++"
  data <- paste(config$key, config$value, sep = " = ")
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
#'
#' @return The contents of the file, as a data frame
#'
import_params <- function(file = "data/param/l2param.prm") {
    # Import file
    lines <- import_lines(file)

    # Convert to dataframe
    df <- as.data.frame(lines)
    df <- as.data.frame(stringr::str_split_fixed(df$lines, " = ", 2))
    colnames(df) <- c("key", "value")

    # Use key as row identifier instead of as value
    rownames(df) <- df[, "key"] # Assign keys to rownames...
    df[, "key"] <- NULL # ... and drop their values

    return(df)
}

#' Auxiliary function for generating a parameters' data frame
#'
#' More info at
#' \url{https://force-eo.readthedocs.io/en/latest/components/lower-level/level2/param.html}
#'
#' @param FILE_QUEUE
#' @param DIR_LEVEL2
#' @param DIR_LOG
#' @param DIR_TEMP
#' @param FILE_DEM
#' @param DEM_NODATA
#' @param DO_REPROJ
#' @param DO_TILE
#' @param FILE_TILE
#' @param TILE_SIZE
#' @param BLOCK_SIZE
#' @param RESOLUTION_LANDSAT
#' @param RESOLUTION_SENTINEL2
#' @param ORIGIN_LON
#' @param ORIGIN_LAT
#' @param PROJECTION
#' @param RESAMPLING
#' @param DO_ATMO
#' @param DO_TOPO
#' @param DO_BRDF
#' @param ADJACENCY_EFFECT
#' @param MULTI_SCATTERING
#' @param DIR_WVPLUT
#' @param WATER_VAPOR
#' @param DO_AOD
#' @param DIR_AOD
#' @param ERASE_CLOUDS
#' @param MAX_CLOUD_COVER_FRAME
#' @param MAX_CLOUD_COVER_TILE
#' @param CLOUD_BUFFER
#' @param SHADOW_BUFFER
#' @param SNOW_BUFFER
#' @param CLOUD_THRESHOLD
#' @param SHADOW_THRESHOLD
#' @param RES_MERGE
#' @param DIR_COREG_BASE
#' @param COREG_BASE_NODATA
#' @param IMPULSE_NOISE
#' @param BUFFER_NODATA
#' @param TIER
#' @param NPROC
#' @param NTHREAD
#' @param PARALLEL_READS
#' @param DELAY
#' @param TIMEOUT_ZIP
#' @param OUTPUT_FORMAT
#' @param OUTPUT_DST
#' @param OUTPUT_AOD
#' @param OUTPUT_WVP
#' @param OUTPUT_VZN
#' @param OUTPUT_HOT
#' @param OUTPUT_OVV
#'
#' @return A data frame containing the parameters and its values
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
                       OUTPUT_OVV = "TRUE") {
  # Use introspection to read the arguments' names and values
  values <- as.list(environment()) # Arguments' values (at this moment the
  # environment only contains the input parameters)
  keys <- formalArgs("gen_params") # Arguments' names ("FILE_QUEUE", ...)

  # Store as data frame
  cfg <- data.frame() # Initialize ...
  for (i in 1:length(keys)) { # ... and fill row by row
    cfg <- rbind(cfg, data.frame(row.names = keys[i], value = values[i][[1]]))
  }

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
