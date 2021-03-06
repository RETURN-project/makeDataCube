% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/WVP.R
\name{dllWVP}
\alias{dllWVP}
\title{Download Water Vapor Pressure data}
\usage{
dllWVP(wvpfolder, logfile, endtime, removeTar = FALSE)
}
\arguments{
\item{wvpfolder}{folder where the data should be stored}

\item{logfile}{log file to keep track of the failed downloads}

\item{endtime}{the latest date for which WVP data should be downloaded (vector with year, month, date)}

\item{removeTar}{(optional, default = FALSE) if TRUE, the tar.gz file is deleted after download and unpacking}
}
\value{
stores data in output folder
}
\description{
Download Water Vapor Pressure data
}
