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
  if (!dir.exists(forcefolder)){
    stop('directory does not exist')
  }
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

  if(!dir.exists(forcefolder)){dir.create(forcefolder)}
  if(!dir.exists(tmpfolder)){dir.create(tmpfolder)}
  if(!dir.exists(l1folder)){dir.create(l1folder)}
  if(!dir.exists(file.path(l1folder,'landsat'))){dir.create(file.path(l1folder,'landsat'))}
  if(!dir.exists(file.path(l1folder,'sentinel'))){dir.create(file.path(l1folder,'sentinel'))}
  if(!dir.exists(l2folder)){dir.create(l2folder)}
  if(!dir.exists(queuefolder)){dir.create(queuefolder)}
  if(!dir.exists(demfolder)){dir.create(demfolder, recursive = TRUE)}
  if(!dir.exists(wvpfolder)){dir.create(wvpfolder, recursive = TRUE)}
  if(!dir.exists(logfolder)){dir.create(logfolder)}
  if(!dir.exists(S2auxfolder)){dir.create(S2auxfolder)}

  if(!file.exists(demlogfile)){file.create(demlogfile)}# logfile for DEM
  if(!file.exists(wvplogfile)){file.create(wvplogfile)}# logfile for WVP
  if(!file.exists(landsatlogfile)){file.create(landsatlogfile)}# logfile for DEM
  if(!file.exists(lclogfile)){file.create(lclogfile)}# logfile for DEM
  if(!file.exists(firelogfile)){file.create(firelogfile)}# logfile for DEM
  if(!file.exists(tclogfile)){file.create(tclogfile)}# logfile for DEMS
  if(!file.exists(Sskiplogfile)){file.create(Sskiplogfile)}# logfile for skipped scenes
  if(!file.exists(Ssuccesslogfile)){file.create(Ssuccesslogfile)}# logfile for successful scenes
  if(!file.exists(Smissionlogfile)){file.create(Smissionlogfile)}# logfile for scenes with an unknown mission
  if(!file.exists(Sotherlogfile)){file.create(Sotherlogfile)}# logfile for scenes with an unrecoginized processing status
  if(!file.exists(file.path(queuefolder,queuefile))){file.create(file.path(queuefolder,queuefile))}# generate a queue file
  if(!dir.exists(paramfolder)){dir.create(paramfolder)}
  if(!dir.exists(lcfolder)){dir.create(lcfolder)}
  if(!dir.exists(tcfolder)){dir.create(tcfolder)}
  if(!dir.exists(firefolder)){dir.create(firefolder)}

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
