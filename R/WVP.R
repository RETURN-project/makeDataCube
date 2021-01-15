
#' Download Water Vapor Pressure data
#'
#' @param wvpfolder folder where the data should be stored
#' @param logfile log file to keep track of the failed downloads
#' @param endtime the latest date for which WVP data should be downloaded (vector with year, month, date)
#' @param removeTar (optional, default = TRUE) if FALSE, the tar.gz file is kept after download and unpacking
#'
#' @return stores data in output folder
#' @export
#' @import curl
dllWVP <- function(wvpfolder, logfile, endtime, removeTar = TRUE) {
  # Check if the compressed file has been already downloaded
  wvpCompressed <- file.path(wvpfolder, 'wvp-global.tar.gz')
  isDownloaded <- file.exists(wvpCompressed) # Is the .tar.gz still available locally?

  # Check if the files have been unpacked in a previous session
  wvpfiles <- list.files(wvpfolder, pattern = '^WVP_[1:2].*\\.txt$' )
  isUnpacked <- (length(wvpfiles) >= 6675)

  if(isDownloaded | isUnpacked) {
    # Do nothing. The files are already here.
  } else { # If not, download them
    tryCatch({
      curl_download(url = 'http://hs.pangaea.de/sat/MODIS/Frantz-Stellmes_2018/wvp-global.tar.gz',
                    destfile = wvpCompressed,
                    quiet = T,
                    handle = new_handle())
      },
      error=function(cond) {
        line <- sprintf("Failed download of: %s", 'wvp-global.tar.gz\n')
        write(line, file = logfile, append = TRUE)
        message(line)
      }
      )
  }

  # Unpack if neccessary
  if(!isUnpacked) {
    # Extract the files
    system(paste0("tar -xvzf ", wvpCompressed, " -C ", wvpfolder), intern = TRUE, ignore.stderr = TRUE)
    # Move all files into the main wvp directory
    system(paste0("mv -v ", file.path(wvpfolder, 'global', '*'), " ", wvpfolder), intern = TRUE, ignore.stderr = TRUE)
    # Remove the empty folder
    system(paste0("rm -rd ", file.path(wvpfolder, 'global')), intern = TRUE, ignore.stderr = TRUE)
  }

  # Remove the downloaded file if required
  if(removeTar && isDownloaded) system(paste0("rm ", wvpCompressed), intern = TRUE, ignore.stderr = TRUE)

  # Update available water vapor data
  # This list may have changed after unpacking
  wvpfiles <- list.files(wvpfolder, pattern = '^WVP_[1:2].*\\.txt$' )

  # Check the time span of the available data
  wvpdts <- as.Date(wvpfiles, 'WVP_%Y-%m-%d.txt')
  endDate <- as.Date(paste0(endtime[1], '-', endtime[2], '-', endtime[3]))

  # If period is not sufficient, extend dataset
  if(max(wvpdts) < endDate) {
    # create folders
    if(!dir.exists(file.path(wvpfolder,'geo'))){dir.create(file.path(wvpfolder,'geo'))}# geo files
    if(!dir.exists(file.path(wvpfolder,'hdf'))){dir.create(file.path(wvpfolder,'hdf'))}# hdf files
    # check if the .laads file exists
    if(!file.exists(file.path(Sys.getenv("HOME"),'.laads'))){print('No .laads file is found in the home directory. You need authentification to download data from the LAADS DAAC. This works by requesting an App Key from NASA Earthdata (https://ladsweb.modaps.eosdis.nasa.gov/tools-and-services/data-download-scripts/#requesting). You can make this key available to FORCE by putting the character string in a file .laads in your home directory.')}
    # update the dataset
    tryCatch({
      system(paste0("force-lut-modis ",file.path(wvpfolder, 'wrs-2-land.coo')," ",wvpfolder," ",file.path(wvpfolder,'geo')," ",file.path(wvpfolder,'hdf')," ",format(max(wvpdts),"%Y")," ",format(max(wvpdts),"%m")," ",format(max(wvpdts),"%d")," ",format(endDate,"%Y")," ",format(endDate,"%m")," ",format(endDate,"%d")))
      },
      error=function(cond) {
        line <- sprintf("%s not downloaded at %s \n", paste0("force-lut-modis ",file.path(wvpfolder, 'wrs-2-land.coo')," ",wvpfolder," ",file.path(wvpfolder,'geo')," ",file.path(wvpfolder,'hdf')," ",format(max(wvpdts),"%Y")," ",format(max(wvpdts),"%m")," ",format(max(wvpdts),"%d")," ",format(endDate,"%Y")," ",format(endDate,"%m")," ",format(endDate,"%d")), wvpfolder)
        write(line,file=logfile,append=TRUE)
        message(line)
      })

    # Remove the redundant folders
    system(paste0("rm -rd ",file.path(wvpfolder,'geo')), intern = TRUE, ignore.stderr = TRUE)
    system(paste0("rm -rd ",file.path(wvpfolder,'hdf')), intern = TRUE, ignore.stderr = TRUE)

  }
}
