#' Logs the first argument passed to a function with minimal effort
#'
#' This function will help us rewriting the system calls in a better way.
#'
#' @param f The function to be called.
#' @param filename The log file (default = 'log1starg.txt').
#'
#' @return Void. The argument is written to the desired file.
#' @export
#'
#' @examples
#' \dontrun{
#' Imagine you want to log the first argument of the call:
#' paste("Hi", "there!") # i.e.: you want to log "Hi"
#' you can do it by:
#' log1starg(paste)("Hi", "there")
#'
#' This will be particularly useful in the structures:
#' system(paste0("text", par, "text", par, ...), intern = TRUE, ignore.stderr = TRUE)
#' By substituting system by log1starg(system) all the console commands will be
#' logged in a human readable format.
#' }
log1starg <- function(f, filename = 'log1starg.txt') {

  wrapper <- function(x, ...) {
    # Log it before executing, so error-generating arguments are logged
    write(x, file = filename, append = TRUE)

    # Execute normally
    res <- f(x, ...)

    # This is a wrapper structure, so the resulting function has to be returned
    return(res)
  }

}
