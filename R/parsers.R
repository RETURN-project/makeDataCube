#' Export parameters to file
#'
#' @param config Configuration data frame (as loaded by parse_params)
#' @param file Filename where the parameters will be exported
#'
#' @return Nothing
#' @export
#'
export_params <- function(config, file) {
  header <- "++PARAM_LEVEL2_START++"
  data <- paste(config$key, config$value, sep = " = ")
  footer <- "++PARAM_LEVEL2_END++"

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
