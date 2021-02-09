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
getScenes(pars$ext, 
          file.path(input$queuefile),
          parsefilefolder(input$queuefile), #l1Folder
          parsefilefolder(input$metafolder), 
          parsefilefolder(input$tmpfolder), 
          cld = pars$cld, 
          starttime = pars$starttime, 
          endtime = pars$endtime, 
          tiers = pars$tiers, 
          sensors = pars$sensors)

system("touch data/level1/.control")
