## Auxiliary parsers
# Parsing is needed because some inputs are given in inconvenient formats
# These operations happen several times. It is practical to encapsulate them as functions

#' Returns the full path of the folder containing a file
#'
#' This is just a shorthand for the more verbose dirname(normalizePath(x))
#'
#' @param filepath String representing a file's path: ~/path/to/file.txt
#'
#' @return # String representing the folder's path: ~/path/to
parsefilefolder <- function(filepath) dirname(normalizePath(filepath))
