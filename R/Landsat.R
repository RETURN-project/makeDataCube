#' Download Landsat scenes. Several criteria can be set to select scenes of interest: the extent of the study area,
#' the time period of interest, the preferred sensors, tiers and maximum cloud percentage.
#' Only scenes are downloaded that are not in the queue file yet. After download to a temporary folder, these scenes
#'  are compressed to a .tar.gz file, added to the the queue file and the level1 folder.
#'  Finally, the original downloaded files are removed from the temporary folder.
#'
#' @param l1folder level 1 folder
#' @param queuefolder queue folder
#' @param queuefile queue file
#' @param tmpfolder folder with temporary data
#' @param ext extent of the study area of interest, this should be given as a vector containing - in order - xmin, xmax, ymin, ymax in degrees
#' @param starttime start date (given as a vector with year, month, day)
#' @param endtime end date (given as a vector with year, month, day)
#' @param sensors sensors of interest, can be LC08, LE07, LT05, LT04, LM05, LM04
#' @param tiers tiers of interest, T1 and T2 represent Tier 1 and 2, respectively
#' @param cld maximum cloud percentage
#'
#' @return adds Landsat data to Level 1 folder
#' @export
#' @import reticulate
#'
#' @examples
dllLS <- function(l1folder, queuefolder, queuefile, tmpfolder, ext, starttime, endtime, sensors, tiers, cld){
  # Sync the catalog
  system("pylandsat sync-database")#system("pylandsat sync-database -f")
  # Download tiles that are not in the queue yet
  source_python('../python/dllLandsat.py')
  scenes <- dllLandsat(queuefolder, queuefile, tmpfolder, ext, starttime, endtime, sensors, tiers, cld)

  # compress data to .tar.gz file
  for(i in 1:length(scenes)){
    system(paste0("tar -zcvf ",file.path(tmpfolder,paste0(scenes[i],'.tar.gz'))," -C",file.path(tmpfolder,scenes[i]), " ."), intern = TRUE, ignore.stderr = TRUE)
  }

  # add scenes to queue
  system(paste0("force-level1-landsat ",tmpfolder," ",file.path(l1folder,'landsat')," ",file.path(queuefolder,'queue.txt')," mv"), intern = TRUE, ignore.stderr = TRUE)

  # remove temporary files and folders
  system(paste0("rm ",file.path(tmpfolder,"*.tar.gz")), intern = TRUE, ignore.stderr = TRUE)
  system(paste0("rm -rd ",file.path(tmpfolder,"L*")), intern = TRUE, ignore.stderr = TRUE)
  return(scenes)
}

