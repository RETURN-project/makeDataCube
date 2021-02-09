
#' Download SRTM DEM at 1 arcsecond
#' https://lpdaac.usgs.gov/products/srtmgl1v003/
#'
#' @param ext vector with xmin, xmax, ymin, ymax in degrees
#' @param dl_dir where do you want to store the data?
#' @param logfile logfile
#'
#' @return stores files to disk
#' @export
#'
dllDEM <- function(ext, dl_dir= Sys.getenv("HOME"), logfile){
  # web_page <- readLines("https://e4ftl01.cr.usgs.gov/MEASURES/SRTMGL1.003/2000.02.11/SRTMGL1_page_4.html")
  # sam <- web_page[startsWith(web_page,"   <td><a href=\"http://e4ftl01.cr.usgs.gov/MEASURES/SRTMGL1.003/2000.02.11/")]
  # sam <- sam[endsWith(sam, '.hgt.zip.xml</a> </td>')]
  # urls <- sapply(strsplit(sam, '"'), "[", 2)

  # http://e4ftl01.cr.usgs.gov/MEASURES/SRTMGL1.003/2000.02.11/N59W155.SRTMGL1.hgt.zip.xml
  # https://e4ftl01.cr.usgs.gov/MEASURES/SRTMGL1.003/2000.02.11/SRTMGL1_page_4.html

  lon <- floor(ext[1]):ceiling(ext[2])
  lat<- floor(ext[3]):ceiling(ext[4])
  lons <- paste0(sapply(lon, function(x){switch(1+(sign(x)<0),'E','W')}), sprintf('%03i',abs(lon)))
  lats <- paste0(sapply(lat, function(x){switch(1+(sign(x)<0),'N','S')}), sprintf('%02i',abs(lat)))
  cmb <- expand.grid(lats,lons)
  cmb <- paste0(cmb[,1],cmb[,2])
  todll <- paste0(cmb,'.SRTMGL1.hgt')#files that meet the criteria
  # check if the files are not present in the target dir
  fls <- list.files(path = dl_dir, pattern ='*.hgt')# all files that are already downloaded
  fls <- gsub(".hgt", ".SRTMGL1.hgt", fls)
  todll <- setdiff(todll, fls)# files that meet criteria and are not downloaded yet
  if(length(todll)>0){
    urls <- paste0('http://e4ftl01.cr.usgs.gov/MEASURES/SRTMGL1.003/2000.02.11/',todll,'.zip')#urls that meet  the criteria
    # download
    dllLPDAAC(dl_dir, urls, logfile)

    # Unzip the downloaded files...
    systemf("unzip '%s' -d %s", file.path(dl_dir, "*.zip"), dl_dir)
    # ... and remove the zip files after unzipping
    systemf("rm %s", file.path(dl_dir, "*.zip"))

  }
   # return a list of downloaded files
  todll
}

#' Download data from LP DAAC DATa Pool
#'
#' @param dl_dir where do you want to store the data?
#' @param files url of the files to download. This should either be (i) a single url, (ii) a list of urls, or (iii) the full path the a text file that contains the urls of interest
#' @param logfile logfile
#'
#' @return Downloads data from LP DAAC Data Pool
#' @export
#' @import sys
#' @import getPass
#' @import httr
#'
dllLPDAAC<- function(dl_dir = Sys.getenv("HOME"), files, logfile){
  # ------------------------------------------------------------------------------------------------ #
  # How to Access the LP DAAC Data Pool with R
  # The following function configures a connection to download data from an
  # Earthdata Login enabled server, specifically the LP DAAC Data Pool.
  # ------------------------------------------------------------------------------------------------ #
  # Author: Cole Krehbiel
  # Last Updated: 11/14/2019
  # https://git.earthdata.nasa.gov/projects/LPDUR/repos/daac_data_download_r/browse
  # https://lpdaac.usgs.gov/resources/e-learning/how-access-lp-daac-data-command-line/

  # ---------------------------------SET UP ENVIRONMENT--------------------------------------------- #
  netrc <- EartDataLogin()

  # Loop through all files
  for (i in 1:length(files)) {
    filename <-  file.path(dl_dir,tail(strsplit(files[i], '/')[[1]], n = 1)) # Keep original filename

    # Write file to disk (authenticating with netrc) using the current directory/filename
    response <- GET(files[i], write_disk(filename, overwrite = TRUE), progress(),
                    config(netrc = TRUE, netrc_file = netrc), set_cookies("LC" = "cookies"))

    # Check to see if file downloaded correctly
    if (response$status_code == 200) {
      print(sprintf("%s downloaded at %s", filename, dl_dir))
    } else {
      print(sprintf("%s not downloaded. Verify that the url is valid and your username and password are correct in %s", filename, netrc))
      line <- sprintf("%s not downloaded at %s \n", filename, dl_dir)
      write(line,file=logfile,append=TRUE)
    }
  }

}

#' Set Up Direct Access the LP DAAC Data Pool with R
#' The function configures a netrc profile that will allow users to download data from
#'  an Earthdata Login enabled server.
#'
#' @return generates a .netrc profile
#' @export
#' @import sys
#' @import getPass
#'
EartDataLogin <- function(){
  # ------------------------------------------------------------------------------------------------ #
  # How to Set Up Direct Access the LP DAAC Data Pool with R
  # The following R code will configure a netrc profile that will allow users to download data from
  # an Earthdata Login enabled server.
  # ------------------------------------------------------------------------------------------------ #
  # Author: Cole Krehbiel
  # Last Updated: 11/20/2018
  # https://git.earthdata.nasa.gov/projects/LPDUR/repos/daac_data_download_r/browse/EarthdataLoginSetup.R
  # -----------------------------------SET UP ENVIRONMENT------------------------------------------- #
  usr <- file.path(Sys.getenv("USERPROFILE"))  # Retrieve user directory (for netrc file)
  if (usr == "") {usr = Sys.getenv("HOME")}    # If no user profile exists, use home directory
  netrc <- file.path(usr,'.netrc', fsep = .Platform$file.sep) # Path to netrc file

  # ----------------------------------CREATE .NETRC FILE-------------------------------------------- #
  # If you do not have a  .netrc file with your Earthdata Login credentials stored in your home dir,
  # below you will be prompted for your NASA Earthdata Login Username and Password and a netrc file
  # will be created to store your credentials (home dir). Create an account at: urs.earthdata.nasa.gov
  if (file.exists(netrc) == FALSE || grepl("urs.earthdata.nasa.gov", readLines(netrc)) == FALSE) {
    netrc_conn <- file(netrc)

    # User will be prompted for NASA Earthdata Login Username and Password below
    writeLines(c("machine urs.earthdata.nasa.gov",
                 sprintf("login %s", getPass(msg = "Enter NASA Earthdata Login Username \n (or create an account at urs.earthdata.nasa.gov):")),
                 sprintf("password %s", getPass(msg = "Enter NASA Earthdata Login Password:"))), netrc_conn)
    close(netrc_conn)
  }
  netrc
}
