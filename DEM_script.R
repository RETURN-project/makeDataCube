# ====================== Parse inputs ======================
## Read input and parameters from snakemake file
input <- snakemake@input
pars <- snakemake@params

## Auxiliary parser
# Parsing is needed because some inputs are given in inconvenient formats
# These operations happen several times. It is practical to encapsulate them as functions
parsefilepath <- function(filepath) dirname(normalizePath(filepath)) # Parses strings representing a path

# ====================== Run the script ======================
## Load required libraries
library(makeDataCube)

## Execute
flsDEM <- dllDEM(ext = pars$ext,
                dl_dir = parsefilepath(input$demFolder),
                logfile = parsefilepath(input$demlogfile))
