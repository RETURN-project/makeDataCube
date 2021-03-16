#' Parse date from vector
#'
#' Converts vectors like c(2021, 1, 16) into date objects. This is useful when
#' arithmetics involving dates are required (for instance, calculating a time
#' span).
#'
#' This is an auxiliary function.
#'
#' @param vec A vector containing the date in the format c(year, month, day)
#'
#' @return A date object
#' @export
vec_to_date <- function(vec) {
  # Convert vector c(2021, 1, 16) to string "2021-1-16" (year, month, day)
  date_char <- paste(as.character(vec), collapse =  "-")

  # Convert to date
  date <- ymd(date_char)

  return(date)
}

#' Convert date to vector
#'
#' This is an auxiliary function.
#'
#' @param date A date object
#'
#' @return A vector in the format c(2021, 1, 16)
#' @export
date_to_vec <- function(date) {
  # Unpack the date as a vector of integers
  vec <- c(year(date), month(date), day(date))

  return(vec)
}
