#' Copy the scenes over area of extent and time span of interest from an input folder to a level 1 folder and add these scenes to a queue file
#'
#' @param S2auxfolder directory with auxilliarity Sentinel-2 data, e.g. tile grid
#' @param ext extent of the area of interest (vector with xmin, xmax, ymin, ymax in degrees)
#' @param S2folder directory where all Sentinel-2 data are stored
#' @param starttime start date of the time span of interest (vector with year, month, day)
#' @param endtime end date of the time span of interest (vector with year, month, day)
#' @param queuefolder directory where the queue file is stored
#' @param queuefile name of the queue file
#' @param l1folder directory of the level 1 folder
#'
#' @return adds Sentinel-2 data to the level1 folder and queue
#' @export
#' @import tidyverse
#' @import readtext
#' @import sf
addSen2queue <- function(S2auxfolder, ext, S2folder, starttime, endtime, queuefolder, queuefile, l1folder){
  # get the Sentinel-2 tile grid
  if(!file.exists(file.path(S2auxfolder, 'S2grid.kml'))){
    download.file('https://sentinel.esa.int/documents/247904/1955685/S2A_OPER_GIP_TILPAR_MPC__20151209T095117_V20150622T000000_21000101T000000_B00.kml', file.path(S2auxfolder, 'S2grid.kml'))
  }
  s2grid <- st_read(file.path(S2auxfolder, 'S2grid.kml'),'Features')

  # search which tiles intersect with area of interest
  df <- data.frame(
    lon = c(ext[1], ext[2], ext[2], ext[1], ext[1]),
    lat = c(ext[3], ext[3], ext[4], ext[4], ext[3])
  )
  aoi <- df %>%
    st_as_sf(coords = c("lon", "lat"), crs = 4326) %>%
    summarise(geometry = st_combine(geometry)) %>%
    st_cast("POLYGON")#polygon with area of interest

  tiles <- s2grid[which(st_within(s2grid, aoi, sparse = F) == T | st_intersects(s2grid, aoi, sparse = F) == T),]# tiles of interest

  # list of scenes of interest
  s2sc <- list.files(S2folder,pattern = '*.zip')# all available scenes
  spl <- str_split(s2sc,'_')
  s_dts <- as.Date(substr(unlist(lapply(spl, `[[`, 4)),1,8),'%Y%m%d')# dates of available scenes
  s_tls <- unlist(lapply(spl, `[[`, 7))# tile numbers of available scenes
  startdt <- as.Date(paste(sprintf("%02d", starttime),collapse =''),'%Y%m%d')# start period of interest
  enddt <- as.Date(paste(sprintf("%02d", endtime),collapse =''),'%Y%m%d')# end period of interest
  s2sel <- s2sc[which((s_dts > startdt) & (s_dts < enddt) & (s_tls %in% paste0('T',tiles$Name)))]# scenes that meet requirements

  # check which scenes are already added to level-1 folder
  queue <- readtext(file.path(queuefolder,queuefile))
  queue <- str_split(queue$text,'\n')
  squeue <- queue[[1]][str_starts(queue[[1]],file.path(l1folder,'sentinel'))]# queue list - tiles that have already been added
  squeue <- sapply(strsplit(squeue," "), `[`, 1)
  newt <- file.path(l1folder,'sentinel',substr(s2sel,50,55), paste0(substr(s2sel,12,71),'.SAFE'))# tiles tot meet requirements
  s2add <- s2sel[newt %in% setdiff(newt, squeue)]# scenes that are not added yet

  # generate level 1 tile folders
  for(i in 1:length(tiles$Name)){
    # generate the folder for the Sentinel-2 tile
    if(!dir.exists(file.path(l1folder,'sentinel',paste0('T',tiles$Name[i])))){dir.create(file.path(l1folder,'sentinel',paste0('T',tiles$Name[i])))}
  }

  # unzip scenes in the right folder
  if(length(s2add>0)){
    walk(s2add, ~ unzip(zipfile = file.path(S2folder, .x, substr(.x,12,75)),
                        exdir = file.path(l1folder,'sentinel',substr(.x,50,55))))
    # add scenes to queue
    line <-paste(paste0(file.path(l1folder,'sentinel',substr(s2sel,50,55), paste0(substr(s2sel,12,71),'.SAFE')),' QUEUED'), collapse = '\n')
    write(line,file=file.path(queuefolder,queuefile),append=TRUE)
  }
}
