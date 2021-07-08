#' Parse FORCE parameters file
#'
#' More info at \url{https://force-eo.readthedocs.io/en/latest/components/lower-level/level2/param.html}
#'
#' @param file The parameters file
#' @param key Search key. Leave empty for parsing the whole file
#'
#' @return The contents of the parameters file as a data frame
#' @export
#'
parse_params <- function(file = "data/param/l2param.prm", key = "") {
  if (key == "") {
    return( parse_all(file) )
  } else {
    return( parse_keyvalue(key, file) )
  }
}

#' Parse a key-value pair from the FORCE parameters file
#'
#' @param key Search query (use regex)
#' @param file The parameters file
#'
#' @return The value
#'
parse_keyvalue <- function(key, file = "data/param/l2param.prm") {
  # Import file
  lines <- import_params(file)

  # Filter by key
  mask <- grepl(key, lines)
  line <- lines[mask]

  # Make sure the key exists and is unique
  if (length(line) != 1) {
      msg <- sprintf("The key had %s hits instead of 1", length(line))
      stop(msg)
  }

  # Extract the key-value pair
  keyval <- strsplit(line, " = ")

  # Make sure it is a key-value pair
  if (length(keyval[[1]]) != 2) {
      stop("The key-value pair contains more than one value")
  }

  # Extract only the value
  val <- keyval[[1]][2]

  return(val)
}

#' Import parameters as data frame
#'
#' Checks the FORCE parameter file, and imports its contents as a data frame
#'
#' @param file The parameters file
#'
#' @return The contents of the file, as a data frame
#'
parse_all <- function(file = "data/param/l2param.prm") {
    # Import file
    lines <- import_params(file)

    # Convert to dataframe
    df <- as.data.frame(lines)
    df <- stringr::str_split_fixed(df$lines, " = ", 2)
    colnames(df) <- c("key", "value")

    return(df)
}

#' Import parameters
#'
#' Checks the FORCE parameter file, and imports its contents as a list of lines
#'
#' @param file The parameters file
#'
#' @return The data in the file, line by line, filtering out non-data lines
#'
import_params <- function(file = "data/param/l2param.prm") {
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
