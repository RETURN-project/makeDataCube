# ====================== Parse inputs ======================
## Read input and parameters from snakemake file
input <- snakemake@input
pars <- snakemake@params

## Auxiliary functions
# These operations happen several times. It is more practical to encapsulate them as functions
parsepath <- function(str) dirname(normalizePath(str)) # Parses strings representing a path
parsenumtuple <- function(str) as.numeric(unlist(strsplit(str, ","))) # Parses string representing a tuple of numbers

## Transform input to its proper R form
S2auxfolder <- parsepath(input$miscFolder)
ext <- parsenumtuple(pars$ext)
S2folder <- parsepath(input$dataFolder)
starttime <- parsenumtuple(pars$starttime)
endtime <- parsenumtuple(pars$endtime)
queuefile <- normalizePath(input$queueFile)

queuefolder <- dirname(queuefile) #TODO: redundant with queuefile
l1folder <- queuefolder

# ====================== Run the script ======================
## Load required libraries
library(makeDataCube)
library(tidyverse)

## Execute
addSen2queue(S2auxfolder, ext, S2folder, starttime, endtime, queuefolder, 'queue.txt', l1folder)
