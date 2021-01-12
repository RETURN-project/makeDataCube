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
library(tidyverse)

## Execute
addSen2queue(S2auxfolder = parsefilepath(input$miscFolder), 
             ext = pars$ext,
             S2folder = parsefilepath(input$dataFolder), 
             starttime = pars$starttime, 
             endtime = pars$endtime, 
             queuefolder = parsefilepath(input$queueFile),
             'queue.txt', 
             l1folder = parsefilepath(input$queueFile))
