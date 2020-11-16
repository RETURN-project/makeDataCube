#' Load RData file and returns it. This function is a substitute for the load function, allowing to assign a user defined variable name when loading a RData file.
#'
#' @param fileName the path to the Rdata file that needs to be loaded
#'
#' @return R object
#' @export
loadRData <- function(fileName){
  #loads an RData file, and returns it
  load(fileName)
  get(ls()[ls() != "fileName"])
}

#' Set and generate folder structure to store data for the FORCE processing workflow
#'
#' @param forcefolder the main folder where all data needs to be stored (full path)
#'
#' @return generates a folder structure
#' @export
#'
setFolders <- function(forcefolder){
  # Proceed only if the main folder exists
  if (!dir.exists(forcefolder)) { stop('Directory does not exist') }

  # Create the tree identifiers
  tmpfolder <- file.path(forcefolder, 'temp')
  l1folder <- file.path(forcefolder, 'level1')
  l2folder <- file.path(forcefolder, 'level2')
  queuefolder <- file.path(forcefolder, 'level1')
  queuefile <- 'queue.txt'
  demfolder <- file.path(forcefolder, 'misc','dem')
  wvpfolder <- file.path(forcefolder, 'misc','wvp')
  logfolder <- file.path(forcefolder, 'log')
  paramfolder <- file.path(forcefolder, 'param')
  paramfile <- 'l2param.prm'
  lcfolder <- file.path(forcefolder, 'misc','lc')# raw land cover data
  tcfolder <- file.path(forcefolder, 'misc','tc')# raw tree cover data
  firefolder <- file.path(forcefolder, 'misc','fire')# raw fire data
  S2auxfolder <- file.path(forcefolder, 'misc', 'S2')# auxiliary S2 data (eg tile grid)

  demlogfile <- file.path(logfolder,'DEM.txt')
  wvplogfile <- file.path(logfolder,'WVP.txt')
  landsatlogfile <- file.path(logfolder, 'Landsat.txt')
  lclogfile <- file.path(logfolder, 'LC.txt')
  firelogfile <- file.path(logfolder,'fire.txt')
  tclogfile <- file.path(logfolder, 'tc.txt')
  Sskiplogfile <- file.path(logfolder, 'Sskip.txt')
  Ssuccesslogfile <- file.path(logfolder, 'Ssuccess.txt')
  Smissionlogfile <- file.path(logfolder, 'Smission.txt')
  Sotherlogfile <- file.path(logfolder, 'Sother.txt')

  # Create the tree
  # Auxiliary functions: creates the path and files only if they don't exist already
  # It is actually very similar to dir.create(path, showWarnings = FALSE)
  dir.create.safe <- function(path, recursive = FALSE) {
    if(!dir.exists(path)) { dir.create(path, recursive = recursive) }
  }

  file.create.safe <- function(path) {
    if(!file.exists(path)) { file.create(path) }
  }

  dir.create.safe(tmpfolder)
  dir.create.safe(l1folder)
  dir.create.safe(file.path(l1folder, 'landsat'))
  dir.create.safe(file.path(l1folder, 'sentinel'))
  dir.create.safe(l2folder)
  dir.create.safe(queuefolder)
  dir.create.safe(demfolder, recursive = TRUE)
  dir.create.safe(wvpfolder, recursive = TRUE)
  dir.create.safe(logfolder)
  dir.create.safe(S2auxfolder)

  file.create.safe(demlogfile) # logfile for DEM
  file.create.safe(wvplogfile) # logfile for WVP
  file.create.safe(landsatlogfile) # logfile for DEM
  file.create.safe(lclogfile)# logfile for DEM
  file.create.safe(firelogfile) # logfile for DEM
  file.create.safe(tclogfile)# logfile for DEMS
  file.create.safe(Sskiplogfile) # logfile for skipped scenes
  file.create.safe(Ssuccesslogfile)# logfile for successful scenes
  file.create.safe(Smissionlogfile) # logfile for scenes with an unknown mission
  file.create.safe(Sotherlogfile) # logfile for scenes with an unrecoginized processing status
  file.create.safe(file.path(queuefolder, queuefile))# generate a queue file

  dir.create.safe(paramfolder)
  dir.create.safe(lcfolder)
  dir.create.safe(tcfolder)
  dir.create.safe(firefolder)

  # Output information
  out <- c(tmpfolder, l1folder, l2folder, queuefolder, queuefile, demfolder, wvpfolder, logfolder, paramfolder, paramfile,
         lcfolder, tcfolder, firefolder, S2auxfolder, demlogfile, wvplogfile, landsatlogfile, lclogfile, firelogfile, tclogfile, Sskiplogfile, Ssuccesslogfile, Smissionlogfile, Sotherlogfile)
  names(out) <- c('tmpfolder', 'l1folder', 'l2folder', 'queuefolder', 'queuefile', 'demfolder', 'wvpfolder', 'logfolder', 'paramfolder', 'paramfile',
                  'lcfolder', 'tcfolder', 'firefolder', 'S2auxfolder', 'demlogfile', 'wvplogfile', 'landsatlogfile', 'lclogfile', 'firelogfile', 'tclogfile','Sskiplogfile', 'Ssuccesslogfile', 'Smissionlogfile', 'Sotherlogfile')
  return(out)
}

#' Screenes the FORCE log file and add scenes to logfiles dependent on their processing category. Four categories are defined:
#' successful processing, failed due to unrecognized mission, skipped, and other
#'
#' @param scenes the names of the log files to be screened
#' @param logfolder full path to the folder where the logfiles are located
#' @param Sskiplogfile full path to the log file for skipped scenes
#' @param Ssuccesslogfile full path to the log file for successful scenes
#' @param Smissionlogfile full path to the log file for scenes with unknown mission
#' @param Sotherlogfile full path to the log file for other scenes
#'
#' @return adds scenes to logfile based on processing category
#' @export
#' @import readtext
#'
checkLSlog <- function(scenes, logfolder, Sskiplogfile, Ssuccesslogfile, Smissionlogfile, Sotherlogfile){
  lgs <- readtext(file.path(logfolder,scenes))
  ct <- rep(0,dim(lgs)[1])
  # which scenes were succesfully processed?
  ct[grepl('product(s) written. Success! Processing time', lgs, fixed = TRUE)] <- 1
  # which scenes were skipped?
  ct[grepl('. Skip. Processing time', lgs, fixed = TRUE)] <- 2
  # which scenes were not processed due to unknown Satellite Mission?
  ct[grepl('unknown Satellite Mission. Parsing metadata failed.', lgs, fixed = TRUE)] <- 3
  # add scenes to each log file category
  line <- paste(c(lgs$doc_id[ct == 0],''), collapse = '\n')
  write(line,file=Sotherlogfile,append=TRUE)
  line <- paste(c(lgs$doc_id[ct == 1],''), collapse = '\n')
  write(line,file=Ssuccesslogfile,append=TRUE)
  line <- paste(c(lgs$doc_id[ct == 2],''), collapse = '\n')
  write(line,file=Sskiplogfile,append=TRUE)
  line <- paste(c(lgs$doc_id[ct == 3],''), collapse = '\n')
  write(line,file=Smissionlogfile,append=TRUE)
}

#' Check if a polygon and raster contain each other, intersect, or are not overlapping
#'
#' @param pol polygon
#' @param rst SpatRaster object
#'
#' @return 1 if raster contains the polygon, 2 if polygon contains the raster or polygon, 3 if polygon and raster intersect,
#' and 3 if there is no overlap
#' @export
#' @import rgeos
#' @import rgdal
#' @import terra
#'
ext_overlap <- function(pol,rst){
  ext_lst <- as.list(ext(rst))#array of extent
  ei <- as(extent(unlist(ext_lst)), "SpatialPolygons")# spatial polygon of extent
  proj4string(ei) <- showP4(crs(rst))# assign crs to polygon
  if (gContainsProperly(ei, pol)) {
    return(1)# (" polygon fully within raster")
  } else if(gContainsProperly(pol,ei)){
    return(2)# raster fully within polygon
    } else if (gIntersects(ei, pol)) {
    return(3) #print ("intersects")
  } else {
    return(4) #print ("fully without")
  }
}

#' Maximum value without NA value
#'
#' @param x vector of observations
#' @param ... other options
#'
#' @return maximum value
#' @export
#'
max_narm = function(x,...){
  if(sum(is.na(x))==length(x)){
    return(NA)
  }else{
    return(max(x,na.rm=TRUE))
  }}
