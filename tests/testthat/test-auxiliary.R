# Auxiliary function
#
# This copies the functionality o a script that Wanda wrote some time ago,
# and that I want to simplify
gen_params_as_wanda <- function() {
  library(lubridate)

  # Generate parameters with Wanda's Python script
  reticulate::import("pylandsat")
  reticulate::py_config()

  # ========= Parameters =========
  # the folder where the datacube (and auxilliary data) will be stored
  forcefolder <- normalizePath(file.path('data'))
  # a directory where all temporary R files should be stored
  Rtmpfolder <- forcefolder
  #extent of the area of interest, vector with xmin, xmax, ymin, ymax in degrees
  ext <- c(-62.225300382434575,-62.115437101184575,1.7039980451907109,1.7973382355954262)
  # minimum and maximum cloud cover of the Landsat images (images outside this cloud cover range will not be downloaded)
  cld <- c(0,50)
  # start date of the study period: year, month, day
  starttime <- date_to_vec("2000-11-1")
  # end date of the study period: year, month, day
  endtime <- date_to_vec("2001-5-28")
  #Tier level of Landsat data (gives information about the quality of the data)
  tiers <- 'T1'
  # Sensors of interest
  sensors <- c('LC08', 'LE07', 'LT05', 'LT04')# valid sensors: LT04 - Landsat 4 TM, LT05 - Landsat 5 TM, LE07 - Landsat 7 ETM+, LC08 - Landsat 8 OLI, S2A - Sentinel-2A MSI, S2B - Sentinel-2B MSI
  nsubintervals <- 1
  nproc <- '6'
  nthread <- '1'
  subintervals <- partition_dates(starttime, endtime, nsubintervals)
  starttimes <- lapply(int_start(subintervals), date_to_vec) # Extract starttimes as vectors
  endtimes <- lapply(int_end(subintervals), date_to_vec) # Extract endtimes as vectors

  # set the folder to store temporary data
  # unixtools::set.tempdir(Rtmpfolder)
  # generate folder structure
  fldrs <- setFolders(forcefolder)
  tmpfolder <- fldrs['tmpfolder']
  l1folder <- fldrs['l1folder']
  l2folder <- fldrs['l2folder']
  queuefolder <- fldrs['queuefolder']
  queuefile <- fldrs['queuefile']
  demfolder <- fldrs['demfolder']
  wvpfolder <- fldrs['wvpfolder']
  logfolder <- fldrs['logfolder']
  paramfolder <- fldrs['paramfolder']
  demlogfile <- fldrs['demlogfile']
  wvplogfile <- fldrs['wvplogfile']
  metafolder <- fldrs['metafolder']
  S2auxfolder <- fldrs['S2auxfolder']

  paramfile <- 'l2param.prm'
  demfile <- 'srtm.vrt'

  reticulate::source_python(system.file("python", "makeParFile.py", package = "makeDataCube"))

  makeParFile(paramfolder,
              file.path(paramfolder, paramfile),
              FILE_QUEUE = file.path(queuefolder, queuefile),
              DIR_LEVEL2 = l2folder,
              DIR_LOG = logfolder,
              DIR_TEMP = tmpfolder,
              FILE_DEM = file.path(demfolder, demfile),
              ORIGIN_LON = '-90',
              ORIGIN_LAT = '60',
              RESAMPLING = 'NN',
              DIR_WVPLUT = wvpfolder,
              RES_MERGE = 'REGRESSION',
              NPROC = nproc,
              NTHREAD = nthread,
              DELAY = '10',
              OUTPUT_DST = 'TRUE',
              OUTPUT_VZN = 'TRUE',
              OUTPUT_HOT = 'TRUE',
              OUTPUT_OVV = 'TRUE',
              DEM_NODATA= '-32768',
              TILE_SIZE = '3000',
              BLOCK_SIZE = '300')

  cfg <- import_params(file.path(paramfolder, paramfile))

  return(cfg)
}

context("Compare Python and R config parsers")

test_that("Compare", {
  # Generate parameters with Python (old method)
  cfg_py <- gen_params_as_wanda()

  # Generate parameters with R
  nproc <- '6'
  nthread <- '1'

  forcefolder <- normalizePath(file.path('data'))
  fldrs <- setFolders(forcefolder) # TODO: generate folder structure using config as input, and not the other way around

  cfg_r <- gen_params(FILE_QUEUE = file.path(fldrs['queuefolder'], fldrs['queuefile']),
                      DIR_LEVEL2 = fldrs['l2folder'],
                      DIR_LOG = fldrs['logfolder'],
                      DIR_TEMP = fldrs['tmpfolder'],
                      FILE_DEM = file.path(fldrs['demfolder'], 'srtm.vrt'),
                      ORIGIN_LON = '-90',
                      ORIGIN_LAT = '60',
                      RESAMPLING = 'NN',
                      DIR_WVPLUT = fldrs['wvpfolder'],
                      RES_MERGE = 'REGRESSION',
                      NPROC = nproc,
                      NTHREAD = nthread,
                      DELAY = '10',
                      OUTPUT_DST = 'TRUE',
                      OUTPUT_VZN = 'TRUE',
                      OUTPUT_HOT = 'TRUE',
                      OUTPUT_OVV = 'TRUE',
                      DEM_NODATA= '-32768',
                      TILE_SIZE = '3000',
                      BLOCK_SIZE = '300')

  # TODO: this passes at regular testing, but fails at build and codecov report
  # (https://github.com/RETURN-project/makeDataCube/issues/46)
  # Check that both objects are identical
  expect_true(identical(cfg_py, cfg_r))

  # The default parameters should be different
  expect_false(identical(cfg_py, gen_params()))
})
