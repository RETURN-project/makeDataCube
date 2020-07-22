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
#' @examples
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
  demlogfile <- file.path(logfolder,'DEM.txt')
  wvplogfile <- file.path(logfolder,'WVP.txt')
  landsatlogfile <- file.path(logfolder, 'Landsat.txt')
  lclogfile <- file.path(logfolder, 'LC.txt')
  firelogfile <- file.path(logfolder,'fire.txt')
  tclogfile <- file.path(logfolder, 'tc.txt')

  if(!dir.exists(forcefolder)){dir.create(forcefolder)}
  if(!dir.exists(tmpfolder)){dir.create(tmpfolder)}
  if(!dir.exists(l1folder)){dir.create(l1folder)}
  if(!dir.exists(l2folder)){dir.create(l2folder)}
  if(!dir.exists(queuefolder)){dir.create(queuefolder)}
  if(!dir.exists(demfolder)){dir.create(demfolder, recursive = TRUE)}
  if(!dir.exists(wvpfolder)){dir.create(wvpfolder, recursive = TRUE)}
  if(!dir.exists(logfolder)){dir.create(logfolder)}
  if(!file.exists(demlogfile)){file.create(demlogfile)}# logfile for DEM
  if(!file.exists(wvplogfile)){file.create(wvplogfile)}# logfile for WVP
  if(!file.exists(landsatlogfile)){file.create(landsatlogfile)}# logfile for DEM
  if(!file.exists(lclogfile)){file.create(lclogfile)}# logfile for DEM
  if(!file.exists(firelogfile)){file.create(firelogfile)}# logfile for DEM
  if(!file.exists(tclogfile)){file.create(tclogfile)}# logfile for DEM
  if(!file.exists(file.path(queuefolder,queuefile))){file.create(file.path(queuefolder,queuefile))}# generate a queue file
  if(!dir.exists(paramfolder)){dir.create(paramfolder)}
  if(!dir.exists(lcfolder)){dir.create(lcfolder)}
  if(!dir.exists(tcfolder)){dir.create(tcfolder)}
  if(!dir.exists(firefolder)){dir.create(firefolder)}

  out <- c(tmpfolder, l1folder, l2folder, queuefolder, queuefile, demfolder, wvpfolder, logfolder, paramfolder, paramfile,
         lcfolder, tcfolder, firefolder, demlogfile, wvplogfile, landsatlogfile, lclogfile, firelogfile, tclogfile)
  names(out) <- c('tmpfolder', 'l1folder', 'l2folder', 'queuefolder', 'queuefile', 'demfolder', 'wvpfolder', 'logfolder', 'paramfolder', 'paramfile',
                  'lcfolder', 'tcfolder', 'firefolder', 'demlogfile', 'wvplogfile', 'landsatlogfile', 'lclogfile', 'firelogfile', 'tclogfile')
  return(out)

}

#' Convert CCI fire stack to a stack with a predefined temporal resolution and containing the value 0 when no fire is present and 1 if a fire is present
#'
#' @param x stack of CCI fire imagery, the first layer contains a mask (here the value 0 denotes that the pixel should not be included, the value 1 denotes that the pixel should be included), followed by n fire confidence layers and n fire doy layers
#' @param dts dates associated with the stack
#' @param resol the desired temporal resolution of the output data
#' @param thres threshold on the fire confidence layer, only fires having a confidence higher than the threshold are included
#'
#' @return a stack with with a predefined temporal resolution and containing the value 0 when no fire is present and 1 if a fire is present
#' @export
createFireStack <- function(x, dts, resol, thres)
{
  msk <- x[,1]
  x <- x[,-1]
  i <- (msk == 1)
  strtyr <- format(dts[1], "%Y")
  endyr <- format(dts[length(dts)], "%Y")
  if(resol == 'monthly'){
    len <- length(dts)}else if(resol == 'daily'){
      len <- length(seq(as.Date(paste0(strtyr,'-01-01')), as.Date(paste0(endyr,'-12-31')), by = "1 day"))
    }else if (resol == 'quart'){
      len <- length(seq(as.Date(paste0(strtyr,'-01-01')), as.Date(paste0(endyr,'-12-31')), by = "3 months"))
    }
  res <- matrix(NA, length(i), len)
  if(sum(i, na.rm = T)>0){
    if(sum(i) == 1) {
      res[i,] <- toFireTS(x[i,], dts, resol = resol, thres = thres)
    } else if(sum(i) > 1) {
      res[i,] <- t(apply(x[i,], 1, toFireTS, dts, resol, thres))
    }
  }
  res
}

#' Create a time series with the desired temporal resolution that has the value 0 if no fire occurs and the value 1 if a fire occurs
#'
#' @param x a time series, the first n values contain the fire confidence values, the subsequent n values the doy of the fires
#' @param dts date values associated with the time series observations (Date object)
#' @param resol desired temporal resolution of the output
#' @param thres threshold on the fire confidence (value between 0 and 100). The higher the confidence value, the more likely the fire really occured. Only fires with a value above the threshold are taken into account.
#'
#' @return vector with 0 if no fire occurs and 1 if a fire occurs
#' @export
toFireTS <- function(x, dts, resol, thres = 95){
  x <- as.numeric(x)
  len <- length(x)
  cl <- x[1:(len/2)] # confidence values
  jd <- x[(1+(len/2)):len] # doy of fire
  if(resol == 'monthly'){
    out <- rep(0,length(cl)) # initialise a vector of zeros
    out[cl>thres & jd>0] <- 1 # dates with high fire confidence and doy of fire > 0 are set to 1
  }else if (resol == 'daily'){
    # create daily time series and associated dates
    strtyr <- format(dts[1], "%Y") # start year of the fire dataset
    endyr <- format(dts[length(dts)], "%Y") # end year of the fire dataset
    tsdts <- seq(as.Date(paste0(strtyr,'-01-01')), as.Date(paste0(endyr,'-12-31')), by = "1 day")  # all potential fire dates
    out <- rep(0,length(tsdts))# initialise output vector with zeros

    # get timing of fires
    ind <- which(cl>thres & jd>0) # find observations with high fire confidence and doy of fire > 0
    fireyr <- format(dts[ind], "%Y") # year of the observed fires
    firedoy <- jd[ind] # doy of the observed fires
    firedate <- as.Date(paste0(fireyr,'-',firedoy),'%Y-%j')# create fire observation dates
    out[tsdts %in% firedate] = 1# set fire observation dates to 1
  }else if (resol == 'quart'){
    outm <- rep(0,length(cl)) # initialise a vector of zeros
    outm[cl>thres & jd>0] <- 1 # dates with high fire confidence and doy of fire > 0 are set to 1
    out <- toRegularTS(outm, dts, 'max', 'quart')
  }
  out
}

#' Create regular time series
#'
#' @param tsi vector of observations
#' @param dts dates associated with the observations. This should be a Date object.
#' @param fun function used to aggregate observations to monthly observations. This should be 'max' or 'mean'.
#' @param resol desired temporal resolution of the output. This could be 'monthly', 'quart', or 'daily'
#'
#' @return a vector with a regular time series object
#' @export
#' @import zoo
#' @import bfast
toRegularTS <- function(tsi, dts, fun, resol){
  # len <- length(tsi)
  # tdist <- tsi[1:(len/2)]
  # tsi <- tsi[(1+(len/2)):len]
  tsi <- as.numeric(tsi)
  if(resol == 'monthly'){
    z <- zoo(tsi, dts) ## create a zoo (time) series
    if(fun == 'max'){
      mz <- as.ts(aggregate(z, as.yearmon, mmax)) ## max
    }
    if(fun == 'mean'){
      mz <- as.ts(aggregate(z, as.yearmon, mean)) ## mean
    }
  }else if (resol == 'daily'){
    mz <- bfastts(tsi, dts, type = "irregular")
  }else if (resol == 'quart'){
    z <- zoo(tsi, dts) ## create a zoo (time) series
    if(fun == 'max'){
      mz <- as.ts(aggregate(z, as.yearqtr, mmax)) ## max
    }
    if(fun == 'mean'){
      mz <- as.ts(aggregate(z, as.yearqtr, mean)) ## mean
    }
  }
  return(mz)
}


#' Convert a raster stack with irregular time observations to regular time series
#'
#' @param x stack of observations, the first raster is a mask (with values 0 and 1). The pixels of the mask that have a value 1 are processed, the pixels with a 0 value are not processed.
#' @param dts dates of the observations
#' @param fun unction used to aggregate observations to monthly observations. This should be 'max' or 'mean'.
#' @param resol desired temporal resolution of the output. This could be 'monthly', 'quart', or 'daily'
#'
#' @return stack with regular observations
#' @export
toRegularTSStack <- function(x, dts, fun, resol)
{
  msk <- x[,1]
  x <- x[,-1]
  mask <- apply(x, 1, FUN = function(x) { sum(is.na(x)) / length(x) } )
  i <- ((mask < 1) & (msk == 1))
  len <- length(toRegularTS(dts, dts, fun=fun, resol = resol))
  res <- matrix(NA, length(i), len)
  if(sum(i) == 1) {
    res[i,] <- toRegularTS(x[i,], dts, fun=fun, resol = resol)
  } else if(sum(i) > 1) {
    res[i,] <- t(apply(x[i,], 1, toRegularTS, dts, fun, resol))
  }
  res
}

#' Helper function for the toRegularTSStack function
#'
#' @param x vector of observations
#'
#' @return the maximum value of the vector
#' @export
mmax <- function(x) {
  if(length(which.max(x)) == 0) {
    out <- NA
  } else {
    out <- as.numeric(x[which.max(x)])
  }
  return(out)
}
