# ================= Before running the script =================
## Read input and parameters from snakemake file
input <- snakemake@input
pars <- snakemake@params

## Source auxiliary functions
source('auxs.R')

# ====================== Run the script ======================
## Load required libraries
library(makeDataCube)

## Execute
flsDEM <- dllDEM(ext = pars$ext,
                 dl_dir = parsefilefolder(input$demFolder),
                 logfile = parsefilefolder(input$demlogfile))
