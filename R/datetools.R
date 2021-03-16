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

#' Given a start and an endtime, creates n partitions of equal or similar sizes
#'
#' @param starttime Start time, as a vector
#' @param endtime End time, as a vector
#' @param n Number of desired partitions
#'
#' @return A vector of intervals containing all partitions
#' @export
partition_dates <- function(starttime, endtime, n) {
  # Measure the input data
  start_date <- vec_to_date(starttime)
  end_date <- vec_to_date(endtime)
  n_days <- as.integer(end_date - start_date)

  # Number of days per partition
  # Notice that often it is not possible to make n partitions of equal sizes
  # (e.g.: 11 days in 3 partitions cannot be partitioned as 3,3,3 nor as 4,4,4).
  # This is why we have to use integer division here.
  n_days_par <- n_days %/% n

  # Create and populate the partitions
  timespan <- interval()
  for(i in 1:n) {
    # Each element of time span represents a subinterval
    timespan[i] <- interval(start_date + n_days_par * (i - 1),
                            start_date + n_days_par * i)
  }

  # Override the last interval to make sure it goes all the way to the end
  # in case of integer division problems
  int_end(timespan[n]) <- end_date

  return(timespan)
}
