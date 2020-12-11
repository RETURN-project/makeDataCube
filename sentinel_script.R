#!/usr/bin/env Rscript

# Parse args
args <- commandArgs(trailingOnly = TRUE)

S2auxfolder <- dirname(normalizePath(args[1]))
ext <- as.numeric(unlist(strsplit(args[2], ",")))
S2folder <- dirname(normalizePath(args[3]))
starttime <- as.numeric(unlist(strsplit(args[4], ",")))
endtime <- as.numeric(unlist(strsplit(args[5], ",")))
queuefile <- normalizePath(args[6])

queuefolder <- dirname(queuefile) #TODO: redundant with queuefile
l1folder <- queuefolder

# Run the script
library(makeDataCube)
library(tidyverse)
addSen2queue(S2auxfolder, ext, S2folder, starttime, endtime, queuefolder, 'queue.txt', l1folder) #TODO: ask Wanda about queue.txt
