
#' Download MapBiomas land cover data
#'
#'This function downloads GeoTIFF files of yearly land cover and land use maps that are derived from Landsat mosaics (project MapBiomas). Each band of the geoTIFF file refers to a particular year. The data have a spatial resolution of 30m and its time span ranges between 1985 and 2019.
#'Each pixel of the raster band contains a value that refers to a land cover type. A description of each land cover class can be found in https://mapbiomas.org/en/codigos-de-legenda?cama_set_language=en.
#'Downloaded from: https://storage.googleapis.com/mapbiomas-public/COLECAO/5/DOWNLOADS/COLECOES/ANUAL/
#'The data can also be visualised here: https://plataforma.mapbiomas.org/map#coverage
#'To be cited as: "Project MapBiomas - Collection [version] of Brazilian Land Cover & Use Map Series, accessed on [date] through the link: [LINK]"
#'"MapBiomas Project - is a multi-institutional initiative to generate annual land cover and use maps using automatic classification processes applied to satellite images. The complete description of the project can be found at http://mapbiomas.org".
#'
#' @param ofolder Full path to store the dataset
#' @param logfile logfile
#'
#' @return stores file to disk
#' @export
#' @import RCurl
#'
dllLandcover <- function(ofolder, logfile){
  # regions for which land cover data is available
  lcregions <- c('AMAZONIA', 'PANTANAL', 'CAATINGA', 'MATAATLANTICA', 'CERRADO', 'PAMPA')
  # base url for download
  baseurl <- 'https://storage.googleapis.com/mapbiomas-public/COLECAO/5/DOWNLOADS/COLECOES/ANUAL/'
  # available land cover files
  lcfiles <- paste0(rep(lcregions, each = 35), '-', 1985:2019, '.tif')
  # urls associated with each land cover file
  lcurl <- paste0(baseurl, rep(lcregions, each = 35), '/', rep(lcregions, each = 35), '-', 1985:2019, '.tif')
  # https://storage.cloud.google.com/mapbiomas-public/COLECAO/4_1/CONSOLIDACAO/amazonia.tif?authuser=1&organizationId=482907382829
# download missing land cover files
miss <- which(! lcfiles %in% list.files(ofolder))# files that are not downloaded yet

if (length(miss)>0){
  for(i in 1:length(miss)){#iterate over the files that should be downloaded
    tryCatch(
      {download.file(lcurl[miss[i]], file.path(ofolder, lcfiles[miss[i]]))},# try to download file
      error=function(cond) {# if download fails, write an error message to the logfile
        line <- sprintf("%s not downloaded at %s \n", lcfiles[miss[i]], ofolder)
        write(line,file=logfile,append=TRUE)
        message(line)
      })
  }
  # sapply(1:length(miss), function(i) download.file(lcurl[miss[i]], file.path(ofolder, lcfiles[miss[i]])))
}}
# dllLandcover <- function(ofolder, logfile){
#   lcfiles <- c('COLECAO_4_1_CONSOLIDACAO_amazonia.tif', 'COLECAO_4_1_CONSOLIDACAO_caatinga.tif', 'COLECAO_4_1_CONSOLIDACAO_cerrado.tif', 'COLECAO_4_1_CONSOLIDACAO_mataatlantica.tif', 'COLECAO_4_1_CONSOLIDACAO_pampa.tif', 'COLECAO_4_1_CONSOLIDACAO_pantanal.tif')
#   lcurl <- c('https://storage.googleapis.com/mapbiomas-public/COLECAO/4_1/CONSOLIDACAO/amazonia.tif', 'https://storage.googleapis.com/mapbiomas-public/COLECAO/4_1/CONSOLIDACAO/caatinga.tif', 'https://storage.googleapis.com/mapbiomas-public/COLECAO/4_1/CONSOLIDACAO/cerrado.tif', 'https://storage.googleapis.com/mapbiomas-public/COLECAO/4_1/CONSOLIDACAO/mataatlantica.tif', 'https://storage.googleapis.com/mapbiomas-public/COLECAO/4_1/CONSOLIDACAO/pampa.tif', 'https://storage.googleapis.com/mapbiomas-public/COLECAO/4_1/CONSOLIDACAO/pantanal.tif')
#
#   # download missing land cover files
#   miss <- which(! lcfiles %in% list.files(ofolder))# files that are not available
#
#   if (length(miss)>0){
#     for(i in 1:length(miss)){
#         tryCatch(
#           {download.file(lcurl[miss[i]], file.path(ofolder, lcfiles[miss[i]]))},
#           error=function(cond) {
#             line <- sprintf("%s not downloaded at %s \n", lcfiles[miss[i]], ofolder)
#             write(line,file=logfile,append=TRUE)
#             message(line)
#           })
#     }
#     # sapply(1:length(miss), function(i) download.file(lcurl[miss[i]], file.path(ofolder, lcfiles[miss[i]])))
#   }}

#' Prepare the MapBiomas land cover data
#'
#' Crop the land cover data to the desired extent and extract the study period of interest
#'
#' @param lc_rst list of the MapBiomas SpatRasters
#' @param datafolder Directory where the processed land cover data will be stored
#' @param ext Geographic extent that should be processed, should be a vector with (xmin, xmax, ymin, ymax)
#' @param fname Output file name
#' @param startyr start date of study period
#' @param endyr end date of study period
#'
#' @return saves land cover raster
#' @export
#' @import raster
#' @import terra
#' @import rgeos
#'
prepLandcover <- function(lc_rst, datafolder, ext, fname = 'landcover.tif', startyr, endyr){
  # check if the start and end time are correct
  if(startyr < as.Date('1985-01-01') || endyr > as.Date('2019-01-01')){
    stop('The selected time period does not match the land cover data. Please select dates between (and including) 1985-01-01 and 2019-01-01')
  }
  # generate a polygon with extent of interest
  poly <- as(raster::extent(ext), "SpatialPolygons")
  proj4string(poly) <- CRS("+proj=longlat +datum=WGS84")
  # iterate over land cover rasters
  it <- 0
  for(i in 1:length(lc_rst)){
    rst <- lc_rst[[i]] # open land cover data file
    # check if spatial extents are overlapping
    do_overlap <- ext_overlap(poly, rst)
    if(do_overlap<4){# raster contains (at least partially) area of interest
      it <- it + 1
      lcc <- terra::crop(rst, ext, snap = 'in')# cut the image to the extent of interest
      if(do_overlap>1){# cropped raster does not necessary contain entire study area
        lcc <- terra::expand(lcc,terra::ext(ext))
      }
      if(it ==1){
        lc <- terra::classify(lcc,matrix(c(27, NA, 2,2), ncol=2, byrow=TRUE), include.lowest=TRUE, filename=file.path(datafolder, 'lcReclass.tif'), overwrite=T)# set missing values to NA
      }else{# if study area covers more than one land cover raster, merge rasters
        sti <- terra::classify(lcc,matrix(c(27, NA, 2,2), ncol=2, byrow=TRUE), include.lowest=TRUE, filename=file.path(datafolder, paste0('lcReclass_',i,'.tif')), overwrite=T)
        lcr <- raster::overlay(stack(file.path(datafolder, 'lcReclass.tif')),
                              stack(file.path(datafolder, paste0('lcReclass_',i,'.tif'))),
                              fun=max_narm,#pmax(...,na.rm=T),#function(x,y){pmax(x,y,na.rm=T)},#max_na
                              filename = file.path(datafolder, paste0('lcReclass.tif')),
                              overwrite=TRUE)# merge all raster stacks to one stack for the study region
        lc <- terra::rast(file.path(datafolder, 'lcReclass.tif'))
        # remove temporary files
        rm(sti,lcr)
      }
      # remove temporary files
      rm(lcc)
    }
    rm(rst)
  }
  # dates of each layer
  dtslc <- as.Date(paste0(1985:2019, '-01-01'), format = '%Y-%m-%d')
  names(lc) <- dtslc
  # crop to study period of interest
  lcfin <- lc[[which((dtslc >= startyr) & (dtslc <= endyr))]]# remove observations outside the predefined observation period
  dtslc <- dtslc[which((dtslc >= startyr) & (dtslc <= endyr))]
  # save results
  # remove temporary files
  # unlink(file.path(datafolder, 'lcReclass.tif'))
  for(i in 2:length(lc_rst)){
    unlink(file.path(datafolder, paste0('lcReclass_',i,'.tif')))
  }
  return(lcfin)
}

#' Download tree cover data
#'
#' This dataset is the result from time-series analysis of Landsat images in characterizing global forest extent and change from 2000 through 2018.
#' The data consists of a geoTIFF layer with tree canopy cover for year 2000 (treecover2000), defined as canopy closure for all vegetation taller than 5m in height. This is encoded as a percentage per output grid cell, in the range 0–100.
#' Additionally a data mask (datamask) layer is provided. This layer contains three values representing areas of no data (0), mapped land surface (1), and permanent water bodies (2).
#'
#' Downloaded from: https://earthenginepartners.appspot.com/science-2013-global-forest/download_v1.6.html
#'
#' Use the following credit when these data are displayed:
#' Source: Hansen/UMD/Google/USGS/NASA
#'
#' Use the following credit when these data are cited:
#' Hansen, M. C., P. V. Potapov, R. Moore, M. Hancher, S. A. Turubanova, A. Tyukavina, D. Thau, S. V. Stehman, S. J. Goetz, T. R. Loveland, A. Kommareddy, A. Egorov, L. Chini, C. O. Justice, and J. R. G. Townshend. 2013. “High-Resolution Global Maps of 21st-Century Forest Cover Change.” Science 342 (15 November): 850–53. Data available on-line from: http://earthenginepartners.appspot.com/science-2013-global-forest.
#'
#' Hansen, M. C., Potapov, P. V., Moore, R., Hancher, M., Turubanova, S. A., Tyukavina, A., ... & Kommareddy, A. (2013). High-resolution global maps of 21st-century forest cover change. science, 342(6160), 850-853.
#'
#' @param ofolder Full path to store the dataset
#' @param ext Geographic extent that should be downloaded, should be a vector with (xmin, xmax, ymin, ymax)
#' @param logfile Full path to the logfile
#'
#' @return stores file to disk
#' @export
#'
dllTreecover <- function(ofolder, ext, logfile){
  # get the extent of the tree cover tiles of interest using the extent of the area of interest
  hanext <- c(floor(min(ext[1:2])/10)*10, ceiling(min(ext[1:2])/10)*10, floor(min(ext[3:4])/10)*10, ceiling(min(ext[3:4])/10)*10)# total extent of the area of the hansen tiles of interest, each tile has an extent of 10 x 10 degrees
  hanfiles <- c()
  hanmaskfiles <- c()

  # iterate over the tiles of interest
  for(i in seq(hanext[1],hanext[2]-1,by = 10)){
    for(ii in seq(hanext[4],hanext[3]+1,by = -10)){
      ULlat <- paste0(sprintf('%02d',abs(ii)), switch(1+(ii<0), "N", "S"))# get the upper left latitude
      ULlon <- paste0('0',sprintf('%02d',abs(i)), switch(1+(i<0), "E", "W"))# get the upper left longitude

      # name of tile of interest
      hanfiles <- c(hanfiles,  paste0('Hansen_GFC-2018-v1.6_treecover2000_',ULlat, '_',ULlon, '.tif'))
      hanmaskfiles <- c(hanmaskfiles,  paste0('Hansen_GFC-2018-v1.6_datamask_',ULlat, '_',ULlon, '.tif'))

      # download treecover file if it is not available
      if(! file.exists(file.path(ofolder, paste0('Hansen_GFC-2018-v1.6_treecover2000_',ULlat, '_',ULlon, '.tif')))){
        tryCatch({download.file(paste0('https://storage.googleapis.com/earthenginepartners-hansen/GFC-2018-v1.6/Hansen_GFC-2018-v1.6_treecover2000_',ULlat, '_',ULlon, '.tif'), file.path(ofolder, paste0('Hansen_GFC-2018-v1.6_treecover2000_',ULlat, '_',ULlon, '.tif')))},
          error=function(cond) {
            line <- sprintf("%s not downloaded at %s \n", paste0('Hansen_GFC-2018-v1.6_treecover2000_',ULlat, '_',ULlon, '.tif'), ofolder)
            write(line,file=logfile,append=TRUE)
            message(line)
          })
      }
      # download mask file if it is not available
      if(! file.exists(file.path(ofolder, paste0('Hansen_GFC-2018-v1.6_datamask_',ULlat, '_',ULlon, '.tif')))){
        tryCatch({download.file(paste0('https://storage.googleapis.com/earthenginepartners-hansen/GFC-2018-v1.6/Hansen_GFC-2018-v1.6_datamask_',ULlat, '_',ULlon, '.tif'), file.path(ofolder, paste0('Hansen_GFC-2018-v1.6_datamask_',ULlat, '_',ULlon, '.tif')))},
                 error=function(cond) {
                   line <- sprintf("%s not downloaded at %s \n",paste0('Hansen_GFC-2018-v1.6_datamask_',ULlat, '_',ULlon, '.tif'), ofolder)
                   write(line,file=logfile,append=TRUE)
                   message(line)
                 })
        }
    }
  }
  out <- list(hanfiles, hanmaskfiles)
  names(out) <- c('hanfiles', 'hanmaskfiles')
  out
}

#' Prepare tree cover dataset
#' Crop the data to the extent of interest, mask out areas of no data and - in case the study area covers multiple rasters - merge rasters
#'
#' @param datafolder folder where the processed tree cover data should be stored
#' @param ext geographic extent of interest
#' @param fname name of the output file
#' @param hanfiles list of the tree cover files
#' @param hanmaskfiles list of the tree cover mask files
#'
#' @return writes processed raster to disk
#' @export
#' @import raster
#' @import terra
#'
prepTreecover <- function(datafolder, ext, fname = 'treecover.tif', hanfiles, hanmaskfiles){
  # iterate over the tree cover tiles
  for (i in 1:length(hanfiles)){
    #extract data
    han <- hanfiles[[i]]
    hanmsk <-  hanmaskfiles[[i]]
    # crop the extent of the rasters to the extent of interest
    han <- terra::crop(han, ext, snap = 'in')
    hanmsk <- terra::crop(hanmsk,ext, snap = 'in')
    # remove irrelevant observations
    han[hanmsk == 0] <- NA
    writeRaster(han,file.path(datafolder,'han.tif'), overwrite=T)
    # merge rasters
    if(i == 1){
      writeRaster(han, file.path(datafolder,'hanMerge.tif'), overwrite=T)
    } else{
      raster::mosaic(raster(file.path(datafolder,'hanMerge.tif')),
                                raster(file.path(datafolder,'han.tif')),
                                fun = max_narm,
                                filename = file.path(datafolder,'hanMerge.tif'),
                                overwrite = T)# if the study area covers more than one tile, merge the tiles into one layer
      }
    # remove temporary variables and files
    rm(han, hanmsk)
    unlink(file.path(datafolder, 'han.tif'))
  }
  han_cov <- rast(file.path(datafolder,'hanMerge.tif'))
  return(han_cov)
}

#' Download CCI fire data
#' GeoTIFF files that contain spatio-temporal information on burned areas. Per month, two layers are provided indicating the date of detection and the confidence level of the pixel detected as burned
#' The date of detection layer corresponds to the day in which the fire was first detected, also commonly called Julian Day. The date of the burned pixel may not be coincident with the actual burning date, but most probably taken from one to several days afterwards, depending on image availability and cloud coverage. For areas with low cloud coverage, the detected date of burn should be very close to the actual date of burn, while for areas with high cloud coverage the date may be from several days or even weeks after the fire is over.
#'
#' Possible values:
#'   • 0 (zero): when the pixel is not burned.
#' • 1 to 366: day of the first detection when the pixel is burned.
#' • -1: when the pixel is not observed in the month.
#' • -2: used for pixels that are not burnable: water bodies, bare areas, urban areas, permanent snow and ice.
#'
#' The confidence level is the probability that the pixel is actually burned. A pixel with a confidence level of 80 means that it is burned with a probability of 80%, which implies that the input data and the algorithm result in a fairly high belief of the pixel being burned. A low value (for instance, 5) would indicate a strong belief of the pixel not being burned. These values can also be called “per pixel” uncertainty (pb). It should be noted that this uncertainty is just a description of how much one can trust the interpretation of the burned/unburned state of a pixel given the uncertainty of the data, the choices done in modelling, etc. It does not give an indication about whether the estimates of BA are close to the truth, as that is really the role of validation.
#'
#' Possible values:
#' - 0 (zero): when the pixel is not observed in the month, or it is not burnable (not vegetated).
#' - 1 to 100: Probability values. The closer to 100, the higher the confidence that the pixel is actually burned. This value expresses the uncertainty of the detection for all pixels, even if they are classified as unburned.
#'
#' More information can be found in the Fire_cci_D4.2_PUG-MODIS_v1.0.pdf document or using the following url: https://www.esa-fire-cci.org/FireCCI51
#'
#' Naming convention: yyyymmdd-ESACCI-L3S_FIRE-BA-MODIS-AREA-fv5.1-JD_crop.tif refers to the julian day layer for year yyyy, month mm and day dd.
#' yyyymmdd-ESACCI-L3S_FIRE-BA-MODIS-AREA-fv5.1-CL_crop.tif refers to the confidence layer for year yyyy, month mm and day dd.

#' Downloaded from: https://www.esa-fire-cci.org/FireCCI51
#' After registering, you can access the data from the ftp (under the folder pixel, version 5.1)
#'
#' To be cited as:
#'   M.L. Pettinari, J. Lizundia-Loiola, E. Chuvieco (2020)ESA CCI ECV Fire Disturbance: D4.2Product User Guide-MODIS, version 1.0. Available at: https://www.esa-fire-cci.org/documents
#'
#' Scientific literature:
#' Lizundia-Loiola, J., Otón, G., Ramo, R., Chuvieco, E. (2020) A spatio-temporal active-fire clustering approach for global burned area mapping at 250 m from MODIS data. Remote Sensing of Environment 236: 111493, https://doi.org/10.1016/j.rse.2019.111493.
#'
#' Chuvieco E., Yue C., Heil A., Mouillot F., Alonso-Canas I., Padilla M., Pereira J. M., Oom D. and Tansey K. (2016). “A new global burned area product for climate assessment of fire impacts.” Global Ecology and Biogeography 25(5): 619-629, https://doi.org/10.1111/geb.12440.
#'
#' Chuvieco E., Lizundia-Loiola J., Pettinari M.L. Ramo R., Padilla M., Tansey K., Mouillot F., Laurent P., Storm T., Heil A., Plummer S. (2018) “Generation and analysis of a new global burned area product based on MODIS 250m reflectance bands and thermal anomalies”. Earth System Science Data 10: 2015-2031, https://doi.org/10.5194/essd-10-2015-2018.
#'
#' @param ofolder Full path to store the dataset
#' @param logfile logfile
#'
#' @return stores file to disk
#' @export
#' @import RCurl
#' @import tidyverse
#'
dllFire <- function(ofolder, logfile){
  # for which years is fire data available?
  yrs <- getURL('ftp://anon-ftp.ceda.ac.uk/neodc/esacci/fire/data/burned_area/MODIS/pixel/v5.1/compressed/',  dirlistonly = TRUE)
  yrs <- as.numeric(strsplit(yrs, "\r*\n")[[1]])
  yrs <- yrs[! is.na(yrs)]

  # list all fire files, and their url
  fireclfiles <- paste0(rep(min(yrs):max(yrs), each = 12),sprintf('%02d',rep(1:12,length(yrs))),'01-ESACCI-L3S_FIRE-BA-MODIS-AREA_2-fv5.1-CL.tif')
  firejdfiles <- paste0(rep(min(yrs):max(yrs), each = 12),sprintf('%02d',rep(1:12,length(yrs))),'01-ESACCI-L3S_FIRE-BA-MODIS-AREA_2-fv5.1-JD.tif')
  fireurl <- paste0('ftp://anon-ftp.ceda.ac.uk/neodc/esacci/fire/data/burned_area/MODIS/pixel/v5.1/compressed/',
                    rep(min(yrs):max(yrs), each =12),'/',rep(min(yrs):max(yrs), each = 12),
                    sprintf('%02d',rep(1:12,length(yrs))),'01-ESACCI-L3S_FIRE-BA-MODIS-AREA_2-fv5.1.tar.gz')
  fireurl <- str_replace(fireurl, "/2007/", "/2007/new-corrected/")# files of year 2007 were corrected
  firetar <- paste0(rep(min(yrs):max(yrs), each = 12),sprintf('%02d',rep(1:12,length(yrs))),'01-ESACCI-L3S_FIRE-BA-MODIS-AREA_2-fv5.1.tar.gz')

  # which files are not downloaded yet?
  miss <- which(! fireclfiles %in% list.files(ofolder))# files that are not available

  # download and untar the missing fire data
  failed <- c()
  if (length(miss)>0){
    for(i in 1:length(miss)) {

      skip_to_next <- FALSE

      tryCatch(
        { download.file(fireurl[miss[i]], file.path(ofolder, firetar[miss[i]]))

          untar(file.path(ofolder, firetar[miss[i]]),files=fireclfiles[miss[i]], exdir = ofolder)
          untar(file.path(ofolder, firetar[miss[i]]),files=firejdfiles[miss[i]], exdir = ofolder)
          unlink(file.path(ofolder, firetar[miss[i]]))
          },
        error = function(e){
          skip_to_next <<- TRUE
          line <- sprintf("%s not downloaded at %s \n",firetar[miss[i]], ofolder)
          write(line,file=logfile,append=TRUE)
          message(line)
        })
      if(skip_to_next) {
        failed <- c(failed, miss[i])
        next
        }
    }
  }
  if (length(failed>1)){
    fireclfiles <- fireclfiles[-failed]
    firejdfiles <- firejdfiles[-failed]
  }
  out <- list(fireclfiles, firejdfiles)
  names(out) <- c('fireclfiles', 'firejdfiles')
  out
}

#' Prepare CCI fire data
#' Create a raster stack of the CCI fire data, crop the stack to the extent of interest, select the period of interest, and convert to binary rasters (1 = fire, 0 = no fire).
#'
#' @param fcl a SpatRaster stack with the fire confidence layers
#' @param fjd a SpatRaster stack with the fire julian day of year layers
#' @param fdts Date object associated with fire layers
#' @param han SpatRaster layer with output grid of interest, the CRS of all datasets should be equal to han
#' @param msk a mask indicating which pixels should be stored (0=should not be processed, 1=should be processed)
#' @param tempRes temporal resolution of interest for the output fire SpatRaster stack, can be 'monthly', 'daily', or 'quart'
#' @param Tconf threshold on the fire confidence, only observations with a fire confidence higher than the threshold are considered to be a true fire
#' @param starttime start time of study period of interest (vector with year, month, day)
#' @param endtime end time of study period of interest (vector with year, month, day)
#' @param extfolder directory where temporary files are stored
#'
#' @return
#' @export
#' @import terra
#' @import lubridate
#' @import zoo
#'
prepFire <- function(fcl, fjd, fdts, han, msk, tempRes, Tconf, starttime, endtime, extfolder){
  # convert to date object
  startyr <- as.Date(paste0(starttime[1],'-',starttime[2],'-',starttime[3]))
  endyr <- as.Date(paste0(endtime[1],'-',endtime[2],'-',endtime[3]))

# check if spatial resolution and CRS of han and msk match
  if ((crs(han) != crs(msk))|| (crs(han) != crs(fcl))|| (crs(han) != crs(fjd))){
    stop("the CRS of the SpatRaster layers do not match")
  }
  # check if the number of layers match the number expected by the supplied dates
  dtsexp <- as.Date(toRegularTS(fdts, fdts, fun='max', resol = 'monthly'))#expected dates if no missing observations
  if(length(dtsexp) != length(fdts) ){
    stop("There are likely missing layers in the fire dataset. Check if all dates were downloaded")
  }
  # check if the number of layers match the number of supplied dates
  if(dim(fcl)[3] != length(fdts) ){
    stop("The number of dates does not match the number of layers in the fire dataset")
  }
  # only resample mask data if needed
  if ((res(han)[1] != res(msk)[1]) || (res(han)[2] != res(msk)[2])||(ext(han) != ext(msk))){
    msk <- terra::resample(msk, han, method ='near')
  }
  # prepare the dataset over the area of interest
  fclc <- terra::crop(fcl, ext(han), snap = 'out')# crop stack to the area of interest
  names(fclc) <- fdts
  fcl <- fclc[[which((fdts >= startyr) & (fdts <= endyr))]]# remove observations outside the predefined observation period

  fjdc <- terra::crop(fjd, ext(han), snap = 'out')# crop stack to the area of interest
  names(fjdc) <- fdts
  fjd <- fjdc[[which((fdts >= startyr) & (fdts <= endyr))]]# remove observations outside the predefined observation period
  fdts <- fdts[which((fdts >= startyr) & (fdts <= endyr))]

# resample fire data to same grid
fcl30 <- terra::resample(fcl, han, method ='near')
names(fcl30) <- fdts

fjd30  <- terra::resample(fjd, han, method ='ngb')
names(fjd30) <- fdts
# generate an image stack containing regular fire time series at the predefined temporal resolution with value 1 if a fire occured and 0 if no fire occured
tsFire <- createFireStack(msk, fcl30, fjd30, fdts, resol= tempRes, thres=Tconf, extfolder)

# Get associated dates
dtsfr <- as.Date(toRegularTS(fdts, fdts, fun='max', resol = tempRes))
if(tempRes == 'monthly'){
  dtsfr <- rollback(dtsfr, roll_to_first = TRUE, preserve_hms = TRUE)
}
names(tsFire) <- dtsfr

# remove temp files
rm(fcl30, fclc, fjd30, fjdc, fcl, fjd)

# extend the fire data time span to the study period
rstNA <- han
values(rstNA) <- rep(NaN,ncell(han))
dtstot <- as.Date(toRegularTS(c(startyr, dtsfr, endyr), c(startyr, dtsfr, endyr), fun='max', resol = tempRes))

tsFire2 <- tsFire
npre <- sum(dtstot<min(dtsfr))
npost <- sum(dtstot>max(dtsfr))
if(npre>0){tsFire2 <- c(rep(rstNA,npre), tsFire2)}
if(npost>0){tsFire2 <- c(tsFire2,rep(rstNA,npost))}
names(tsFire2) <- dtstot
return(tsFire2)
}

#' Extract the extent of each grid tile that covers an area of interest
#'
#' @param cubefolder folder inside the level2 directory where the data cube is stored
#' @param ext extent of the area of interest
#'
#' @return list of extents
#' @import raster
#' @import sp
#' @export
#'
getGrid <- function(cubefolder, ext){
  log1starg(system)(paste0("force-tabulate-grid ", file.path(cubefolder), " ", ext[3]," ", ext[4]," ", ext[1]," ", ext[2], " shp"), intern = TRUE, ignore.stderr = TRUE)
  # load shapefile
  p <- shapefile(file.path(cubefolder, 'shp',"grid.shp"))
  # transform crs to crs of interest
  p_wgs <- spTransform(p, CRS("+proj=longlat +datum=WGS84"))
  # extent of each polygon/tile
  elist <- lapply(1:length(p_wgs), function(i) extent(p_wgs[i,]))# get extent of each tile
  names(elist) <- p_wgs$Tile_ID# associate each extent with the tile ID
  unlink(file.path(cubefolder, 'shp'), recursive = T)# remove shapefile
  return(elist)
}
#' Make a mask without fire information
#' The mask identifies pixels that (i) did not have a non-natural land cover type,
#' (ii) have a tree cover higher than a user-defined threshold and
#' (iii) were classified as forest in a user-defined year
#'
#' @param lc land cover raster stack (SpatRaster object; terra package)
#' @param lcDates dates associated with the layers of the land cover raster stack
#' @param han Hansen tree cover raster (SpatRaster object; terra package)
#' @param extfolder directory where temporary files should be stored
#' @param Tyr year that pixel should be forested
#' @param Ttree threshold on tree cover percentage
#'
#' @return SpatRaster layer with data mask (1 equals )
#' @export
#' @import terra
#'
makeMaskNoFire <- function(lc, lcDates, han, extfolder, Tyr, Ttree){
  # check if extent, spatial resolution and CRS of han and msk match
  if (crs(han) != crs(lc)){
    stop("the CRS of the SpatRaster layers does not match")
  }
  if (dim(lc)[3] != length(lcDates)){
    stop("the number of dates does not match the number of land cover layers")
  }
  # resample and project all rasters to the same grid
  lc30 <- terra::resample(lc, han, method ='ngb')
  names(lc30) <- lcDates

  # select areas that consist of only natural land cover types
  m <- c(NA, NA, 1,
         NaN, NaN, 1,
         0, 0, 1,
         1, 8, 0,
         9, 9, 1,
         10,13,0,
         14,22,1,
         23,23,0,
         24,28,1,
         29,29,0,
         30,31,1,
         32,32,0,
         33,50,1)
  rclmat <- matrix(m, ncol=3, byrow=TRUE)
  rclmat[,1] <- rclmat[,1]-0.1;rclmat[,2]<-rclmat[,2]+0.1
  msklc <- terra::classify(lc30, rclmat, include.lowest=TRUE)
  msklc <- sum(msklc)
  msklc <- (msklc == 0)
  # select areas that were forested in a user-defined year
  mskfor <- (lc30[[paste0(Tyr,'-01-01')]] <6)
  # select areas with tree cover percentage larger than user-defined threshold in 2000
  mskcov <- (han > Ttree)
  # mask without fire information
  msk <- ((msklc == 1) & (mskfor == 1) & (mskcov == 1))*1
  rm(mskcov, mskfor, msklc)
  rm(lc30)
  return(msk)
}


#' Convert CCI fire stack to a stack with a predefined temporal resolution and containing the value 0 when no fire is present and 1 if a fire is present
#'
#' @param x stack of CCI fire imagery, the first layer contains a mask (here the value 0 denotes that the pixel should not be included, the value 1 denotes that the pixel should be included), followed by n fire confidence layers and n fire doy layers
#' @param dts dates associated with the stack
#' @param resol the desired temporal resolution of the output data
#' @param thres threshold on the fire confidence layer, only fires having a confidence higher than the threshold are included
#' @param olen length of the output series
#'
#' @return a stack with with a predefined temporal resolution and containing the value 0 when no fire is present and 1 if a fire is present
#' @export
toFireTS <- function(x, dts, resol, thres, olen){
  msk <- x[1]
  if(msk == 1){
    x <- as.numeric(x[-1])
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
    }}else{
      out <- rep(NA,olen)
    }
  return(out)
}

#' Generate a binary fire stack (0=no fire, 1=fire) at the temporal resolution of interest
#'
#' @param msk mask indicating which pixels should be processed (0=not processed, 1 = processed)
#' @param fcl SpatRaster stack with fire confidence layers
#' @param fjd SpatRaster stack with fire julian date of year
#' @param dts dates associated with the fire layers
#' @param resol temporal resolution of the ouput stack, can be 'daily', 'monthly', or 'quart'
#' @param thres threshold on the fire confidence, observations with a fire confidence higher than the threshold are considered to be a true fire
#' @param extfolder folder where temporary files are stored
#'
#' @return
#' @export
#' @import terra
#'
createFireStack <- function(msk, fcl, fjd, dts, resol, thres, extfolder){
  # derive the length of the output stack
  strtyr <- format(dts[1], "%Y")
  endyr <- format(dts[length(dts)], "%Y")
  if(resol == 'monthly'){
    len <- length(dts)}else if(resol == 'daily'){
      len <- length(seq(as.Date(paste0(strtyr,'-01-01')), as.Date(paste0(endyr,'-12-31')), by = "1 day"))
    }else if (resol == 'quart'){
      len <- length(seq(as.Date(paste0(strtyr,'-01-01')), as.Date(paste0(endyr,'-12-31')), by = "3 months"))
    }
  # iterate over pixels and generate the stack
  tsFire <- terra::app(c(msk,fcl, fjd),
                       function(x){
                         toFireTS(x, dts = dts, resol = resol, thres = thres, olen = len)})#,nodes=1
  return(tsFire)
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

#' Helper function for the toRegularTS function
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
