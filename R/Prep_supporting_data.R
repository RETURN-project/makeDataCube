
#' Download MapBiomas land cover data
#'Description:
#'GeoTIFF file of yearly land cover and land use maps that are derived from Landsat mosaics. Each band of the geoTIFF file refers to a particular year. The data have a spatial resolution of 30m and its time span ranges between 1985 and 2018.
#'Each pixel of the raster band contains a value that refers to a land cover type. A description of each land cover class can be found in '[en] Legend description collection 4.0.pdf' and the corresponding pixel IDs in 'MAPBIOMAS_Legenda_Cores__1_.xlsx'.
#'Name: COLECAO_4_1_CONSOLIDACAO_amazonia_crop.tif
#'Downloaded from: https://mapbiomas.org/colecoes-mapbiomas?cama_set_language=en
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
  lcfiles <- c('COLECAO_4_1_CONSOLIDACAO_amazonia.tif', 'COLECAO_4_1_CONSOLIDACAO_caatinga.tif', 'COLECAO_4_1_CONSOLIDACAO_cerrado.tif', 'COLECAO_4_1_CONSOLIDACAO_mataatlantica.tif', 'COLECAO_4_1_CONSOLIDACAO_pampa.tif', 'COLECAO_4_1_CONSOLIDACAO_pantanal.tif')
  lcurl <- c('https://storage.googleapis.com/mapbiomas-public/COLECAO/4_1/CONSOLIDACAO/amazonia.tif', 'https://storage.googleapis.com/mapbiomas-public/COLECAO/4_1/CONSOLIDACAO/caatinga.tif', 'https://storage.googleapis.com/mapbiomas-public/COLECAO/4_1/CONSOLIDACAO/cerrado.tif', 'https://storage.googleapis.com/mapbiomas-public/COLECAO/4_1/CONSOLIDACAO/mataatlantica.tif', 'https://storage.googleapis.com/mapbiomas-public/COLECAO/4_1/CONSOLIDACAO/pampa.tif', 'https://storage.googleapis.com/mapbiomas-public/COLECAO/4_1/CONSOLIDACAO/pantanal.tif')

  # download missing land cover files
  miss <- which(! lcfiles %in% list.files(ofolder))# files that are not available

  if (length(miss)>0){
    for(i in 1:length(miss)){
        tryCatch(
          {download.file(lcurl[miss[i]], file.path(ofolder, lcfiles[miss[i]]))},
          error=function(cond) {
            line <- sprintf("%s not downloaded at %s \n", lcfiles[miss[i]], ofolder)
            write(line,file=logfile,append=TRUE)
            message(line)
          })
    }
    # sapply(1:length(miss), function(i) download.file(lcurl[miss[i]], file.path(ofolder, lcfiles[miss[i]])))
  }}

#' Prepare the MapBiomas land cover data:
#' Crop the land cover data to the desired extent and extract the study period of interest
#'
#' @param ifolder Directory of the MapBiomas files
#' @param datafolder Directory where the processed land cover data will be stored
#' @param ext Geographic extent that should be processed
#' @param fname Output file name
#' @param startyr start date of study period
#' @param endyr end date of study period
#'
#' @return saves land cover raster
#' @export
#' @import raster
#'
prepLandcover <- function(ifolder, datafolder, ext, fname = 'landcover.tif', startyr, endyr){
  lcfiles <- c('COLECAO_4_1_CONSOLIDACAO_amazonia.tif', 'COLECAO_4_1_CONSOLIDACAO_caatinga.tif', 'COLECAO_4_1_CONSOLIDACAO_cerrado.tif', 'COLECAO_4_1_CONSOLIDACAO_mataatlantica.tif', 'COLECAO_4_1_CONSOLIDACAO_pampa.tif', 'COLECAO_4_1_CONSOLIDACAO_pantanal.tif')
  # Generate land cover file for the study area
  rst <- stack(file.path(ifolder, lcfiles[1])) # open land cover data file
  lcc <- crop(rst, ext, filename=file.path(datafolder, 'lcCrop.tif'))# cut the image to the extent of interest
  lc <- reclassify(lcc,c(27,27, NA), filename=file.path(datafolder, 'lcReclass.tif'))# set missing values to NA
  # remove temporary files
  rm('rst', 'lcc')
  unlink(file.path(datafolder, 'lcCrop.tif'))
  unlink(file.path(datafolder, 'lcReclass.tif'))

  for(i in 2:length(lcfiles)){
    rst <- stack(file.path(ifolder, lcfiles[i])) # open land cover data file
    stci <- crop(rst, ext, filename=file.path(datafolder, 'lcCrop.tif'))# cut the image to the extent of interest
    sti <- reclassify(stci,c(27,27, NA), filename=file.path(datafolder, 'lcReclass.tif'))
    lc <- overlay(lc, sti, fun=max, filename = file.path(datafolder, paste0('lc_',i,'.tif')))# merge all raster stacks to one stack for the study region
    # remove temporary files
    rm('rst', 'stci', 'sti')
    unlink(file.path(datafolder, 'lcCrop.tif'))
    unlink(file.path(datafolder, 'lcReclass.tif'))
  }

  dtslc <- as.Date(paste0(1985:2018, '-01-01'), format = '%Y-%m-%d')# dates of each layer
  names(lc) <- dtslc
  lc <- lc[[which((dtslc >= startyr) & (dtslc <= endyr))]]# remove observations outside the predefined observation period
  dtslc <- dtslc[which((dtslc >= startyr) & (dtslc <= endyr))]
  # remove temporary files
  for(i in 2:length(lcfiles)){unlink(file.path(datafolder, paste0('lc_',i,'.tif')))}

  # save results
  save(dtslc, file = file.path(datafolder,'lcDates'))
  writeRaster(lc, file.path(datafolder, fname), format="GTiff", overwrite=TRUE)# save the raster as geoTIFF file
}


#' Download tree cover
#' This dataset is the result from time-series analysis of Landsat images in characterizing global forest extent and change from 2000 through 2018.
#' The data consists of a geoTIFF layer with tree canopy cover for year 2000 (treecover2000), defined as canopy closure for all vegetation taller than 5m in height. This is encoded as a percentage per output grid cell, in the range 0–100.
#' Additionally a data mask (datamask) layer is provided. This layer contains three values representing areas of no data (0), mapped land surface (1), and permanent water bodies (2).
#' Hansen_GFC-2018-v1.6_datamask_crop.tif: data mask
#' Hansen_GFC-2018-v1.6_treecover2000_crop.tif: tree cover layer for the year 2000
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
#' @param ext Geographic extent that should be processed
#' @param logfile logfile
#'
#' @return stores file to disk
#' @export
#'
dllTreecover <- function(ofolder, ext, logfile){
  hanext <- c(floor(min(ext[1:2])/10)*10, ceiling(min(ext[1:2])/10)*10, floor(min(ext[3:4])/10)*10, ceiling(min(ext[3:4])/10)*10)# total extent of the area of the hansen tiles of interest, each tile has an extent of 10 x 10 degrees
  hanfiles <- c()
  hanmaskfiles <- c()

  # iterate over the tiles of interest
  for(i in seq(hanext[1],hanext[2]-1,by = 10)){
    for(ii in seq(hanext[4],hanext[3]+1,by = -10)){
      ULlat <- paste0(sprintf('%02d',abs(ii)), switch(1+(ii<0), "N", "S"))# get the upper left lattitude
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
#' @param ifolder folder where tree cover data and their corresponding masks are stored
#' @param datafolder folder where the processed tree cover data should be stored
#' @param ext geographic extent of interest
#' @param fname name of the output file
#' @param hanfiles names of the tree cover files
#' @param hanmaskfiles names of the tree cover mask files
#'
#' @return writes processed raster to disk
#' @export
#' @import raster
#'
prepTreecover <- function(ifolder, datafolder, ext, fname = 'treecover.tif', hanfiles, hanmaskfiles){
  # iterate over the tree cover tiles
  for (i in 1:length(hanfiles)){
    #load data
    han <- raster(file.path(ifolder, hanfiles[i]))
    hanmsk <- raster(file.path(ifolder, hanmaskfiles[i]))
    # crop the extent of the rasters to the extent of interest
    han <- crop(han, ext, filename = file.path(datafolder, 'hanCrop.tif'))
    hanmsk <- crop(hanmsk,ext, filename = file.path(datafolder, 'hanmskCrop.tif'))
    # remove irrelevant observations
    han[hanmsk == 0] <- NA
    if(i == 1){
      han_cov <- han
    } else{
      han_cov <- merge(han_cov, han, filename = file.path(datafolder,paste0('hanMerge',i,'.tif')))# if the study area covers more than one tile, merge the tiles into one layer
    }
    # remove temporary variables and files
    rm(han, hanmsk)
    unlink(file.path(datafolder, 'hanCrop.tif'))
    unlink(file.path(datafolder, 'hanmskCrop.tif'))
  }
  # write result to file
  writeRaster(han_cov, file.path(datafolder, fname), format="GTiff", overwrite=TRUE)# save the raster as geoTIFF file
  # remove temporary files
  for(i in 2:length(hanfiles)){unlink(file.path(datafolder,paste0('hanMerge',i,'.tif')))}
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
#' Create a raster stack of the CCI fire data, crop the stack to the extent of interest, and select the period of interest.
#'
#' @param ifolder folder where the CCI file files are stored
#' @param datafolder folder where the output files should be stored
#' @param ext geographic extent of interest
#' @param fjdname output file name of the fire julian date raster stack
#' @param fclname ouput file name of the fire confidence raster stack
#' @param startyr start date of the observation period
#' @param endyr end date of the observation period
#' @param fireclfiles names of the fire confidence layers
#' @param firejdfiles names of the fire julian date layers
#'
#' @return saves raster stacks to disk
#' @export
#' @import raster
#'
prepFire <- function(ifolder, datafolder, ext, fjdname = 'fireJD.tif', fclname = 'fireCL.tif', startyr, endyr, fireclfiles, firejdfiles){
  # prepare the dataset over the area of interest
  st <- stack(file.path(ifolder,fireclfiles))# create a stack of all confidence layer files
  stc <- crop(st, ext, filename = file.path(datafolder, 'fireclCrop.tif'))# crop stack to the area of interest
  fdts<- as.Date(fireclfiles, format = "%Y%m%d-ESACCI-L3S_FIRE-BA-MODIS-AREA_2-fv5.1-CL.tif") # dates associated with the fire data stack
  names(stc) <- fdts
  fcl <- stc[[which((fdts >= startyr) & (fdts <= endyr))]]# remove observations outside the predefined observation period
  fdts <- fdts[which((fdts >= startyr) & (fdts <= endyr))]
  writeRaster(fcl, file.path(datafolder, fclname), format="GTiff", overwrite=TRUE)# save the raster as geoTIFF file
  rm(st, stc)
  unlink(file.path(datafolder, 'fireclCrop.tif'))

  st <- stack(file.path(ifolder,firejdfiles))# create a stack of all julian date files
  stc <- crop(st, ext, filename = file.path(datafolder, 'firejdCrop.tif'))# crop stack to the area of interest
  fdts<- as.Date(firejdfiles, format = "%Y%m%d-ESACCI-L3S_FIRE-BA-MODIS-AREA_2-fv5.1-JD.tif") # dates associated with the fire data stack
  names(stc) <- fdts
  fjd <- stc[[which((fdts >= startyr) & (fdts <= endyr))]]# remove observations outside the predefined observation period
  fdts <- fdts[which((fdts >= startyr) & (fdts <= endyr))]
  writeRaster(fjd, file.path(datafolder, fjdname), format="GTiff", overwrite=TRUE)# save the raster as geoTIFF file
  save(fdts, file = file.path(datafolder,'fireDates'))
  rm(st,stc)
  unlink(file.path(datafolder, 'firejdCrop.tif'))
}
