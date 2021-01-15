# ================= Before running the script =================
## Read input and parameters from snakemake file
input <- snakemake@input
pars <- snakemake@params

## Source auxiliary functions
source('auxs.R')

# ====================== Run the script ======================
## Load required libraries
library(makeDataCube)
library(tidyverse) #TODO: remove?

## Execute
addSen2queue(S2auxfolder = parsefilefolder(input$miscFolder),
             ext = pars$ext,
             S2folder = parsefilefolder(input$dataFolder),
             starttime = pars$starttime,
             endtime = pars$endtime,
             queuefolder = parsefilefolder(input$queueFile),
             'queue.txt',
             l1folder = parsefilefolder(input$queueFile))
