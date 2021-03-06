% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/datetools.R
\name{vec_to_date}
\alias{vec_to_date}
\title{Parse date from vector}
\usage{
vec_to_date(vec)
}
\arguments{
\item{vec}{A vector containing the date in the format c(year, month, day)}
}
\value{
A date object
}
\description{
Converts vectors like c(2021, 1, 16) into date objects. This is useful when
arithmetics involving dates are required (for instance, calculating a time
span).
}
\details{
This is an auxiliary function.
}
