% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/General.R
\name{systemf}
\alias{systemf}
\title{Execute formatted string in system}
\usage{
systemf(
  string,
  ...,
  logfile = NULL,
  intern = FALSE,
  ignore.stdout = FALSE,
  dry.run = FALSE
)
}
\arguments{
\item{string}{Command pattern. Use \%s for string slots}

\item{...}{Substrings to fill each instance of \%s}

\item{logfile}{(Default = NULL) Text file to log input and exit status. Useful for debugging}

\item{intern}{(Default = FALSE) FALSE returns the exit status. TRUE the output}

\item{ignore.stdout}{(Default = FALSE) Ignore stdout and stderr}

\item{dry.run}{(Default = FALSE) Set true for returning command without executing}
}
\value{
With default values, returns void. The command executes in the background
}
\description{
This is just a wrapper of the system function. It comfortably allows for
using C-style formatting in the commands, making the calls more readable.
}
\examples{
\dontrun{
systemf("tar -xvzf \%s -C \%s", wvpCompressed, wvpfolder)
}
}
\references{
\url{https://github.com/RETURN-project/makeDataCube/issues/28}
}
