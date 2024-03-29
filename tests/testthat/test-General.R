context("General functions")

test_that("polygon and raster overlap", {
  # polygon inside raster
  pol <- as(extent(c(-60,60,-60,60)), "SpatialPolygons")
  proj4string(pol) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

  rst1 <- terra::rast(nrows=4, ncols=4, nlyrs=1, xmin=-70, xmax=70,ymin=-70, ymax=70, crs = "+proj=longlat +datum=WGS84")
  values(rst1) <- rep(0,16)
  # raster inside polygon
  rst2 <- terra::rast(nrows=4, ncols=4, nlyrs=1, xmin=-50, xmax=50,ymin=-50, ymax=50, crs = "+proj=longlat +datum=WGS84")
  values(rst2) <- rep(0,16)
  # intersect
  rst3 <- terra::rast(nrows=4, ncols=4, nlyrs=1, xmin=-50, xmax=50,ymin=-50, ymax=70, crs = "+proj=longlat +datum=WGS84")
  values(rst3) <- rep(0,16)
  # outside
  rst4 <- terra::rast(nrows=4, ncols=4, nlyrs=1, xmin=80, xmax=90,ymin=80, ymax=90, crs = "+proj=longlat +datum=WGS84")
  values(rst4) <- rep(0,16)
  # check if function gives expected output
  expect_equal(ext_overlap(pol,rst1),1)
  expect_equal(ext_overlap(pol,rst2),2)
  expect_equal(ext_overlap(pol,rst3),3)
  expect_equal(ext_overlap(pol,rst4),4)
})

test_that("Generate FORCE folder structure", {
  forcefolder <- tempdir()
  fldrs <- setFolders(forcefolder)
  expect_equal(fldrs[['tmpfolder']], file.path(forcefolder, 'temp'))
  expect_equal(file.exists(fldrs[['tmpfolder']]),TRUE)
  expect_equal(fldrs[['l1folder']], file.path(forcefolder, 'level1'))
  expect_equal(file.exists(fldrs[['l1folder']]),TRUE)
  expect_equal(fldrs[['l2folder']], file.path(forcefolder, 'level2'))
  expect_equal(file.exists(fldrs[['l2folder']]),TRUE)
  expect_equal(fldrs[['queuefolder']], file.path(forcefolder, 'level1'))
  expect_equal(file.exists(fldrs[['queuefolder']]),TRUE)
  expect_equal(fldrs[['queuefile']], 'queue.txt')
  expect_equal(file.exists(file.path(forcefolder, 'level1/queue.txt')),TRUE)
  expect_equal(fldrs[['demfolder']], file.path(forcefolder, 'misc/dem'))
  expect_equal(file.exists(fldrs[['demfolder']]),TRUE)
  expect_equal(fldrs[['wvpfolder']], file.path(forcefolder, 'misc/wvp'))
  expect_equal(file.exists(fldrs[['wvpfolder']]),TRUE)
  expect_equal(fldrs[['logfolder']], file.path(forcefolder, 'log'))
  expect_equal(file.exists(fldrs[['logfolder']]),TRUE)
  expect_equal(fldrs[['paramfolder']], file.path(forcefolder, 'param'))
  expect_equal(file.exists(fldrs[['paramfolder']]),TRUE)
  expect_equal(fldrs[['paramfile']], 'l2param.prm')
  expect_equal(fldrs[['lcfolder']], file.path(forcefolder, 'misc/lc'))
  expect_equal(file.exists(fldrs[['lcfolder']]),TRUE)
  expect_equal(fldrs[['tcfolder']], file.path(forcefolder, 'misc/tc'))
  expect_equal(file.exists(fldrs[['tcfolder']]),TRUE)
  expect_equal(fldrs[['firefolder']], file.path(forcefolder, 'misc/fire'))
  expect_equal(file.exists(fldrs[['firefolder']]),TRUE)
  expect_equal(fldrs[['S2auxfolder']], file.path(forcefolder, 'misc/S2'))
  expect_equal(file.exists(fldrs[['S2auxfolder']]),TRUE)
  expect_equal(fldrs[['demlogfile']], file.path(forcefolder, 'log/DEM.txt'))
  expect_equal(file.exists(fldrs[['demlogfile']]),TRUE)
  expect_equal(fldrs[['wvplogfile']], file.path(forcefolder, 'log/WVP.txt'))
  expect_equal(file.exists(fldrs[['wvplogfile']]),TRUE)
  expect_equal(fldrs[['landsatlogfile']], file.path(forcefolder, 'log/Landsat.txt'))
  expect_equal(file.exists(fldrs[['landsatlogfile']]),TRUE)
  expect_equal(fldrs[['lclogfile']], file.path(forcefolder, 'log/LC.txt'))
  expect_equal(file.exists(fldrs[['lclogfile']]),TRUE)
  expect_equal(fldrs[['firelogfile']], file.path(forcefolder, 'log/fire.txt'))
  expect_equal(file.exists(fldrs[['firelogfile']]),TRUE)
  expect_equal(fldrs[['tclogfile']], file.path(forcefolder, 'log/tc.txt'))
  expect_equal(file.exists(fldrs[['tclogfile']]),TRUE)
  expect_equal(fldrs[['Sskiplogfile']], file.path(forcefolder, 'log/Sskip.txt'))
  expect_equal(file.exists(fldrs[['Ssuccesslogfile']]),TRUE)
  expect_equal(fldrs[['Ssuccesslogfile']], file.path(forcefolder, 'log/Ssuccess.txt'))
  expect_equal(file.exists(fldrs[['Sskiplogfile']]),TRUE)
  expect_equal(fldrs[['Smissionlogfile']], file.path(forcefolder, 'log/Smission.txt'))
  expect_equal(file.exists(fldrs[['Smissionlogfile']]),TRUE)
  expect_equal(fldrs[['Sotherlogfile']], file.path(forcefolder, 'log/Sother.txt'))
  expect_equal(file.exists(fldrs[['Sotherlogfile']]),TRUE)

  unlink(forcefolder, recursive = T)
})

test_that("Maximum value with NA",{
  expect_equal(max_narm(c(1,5,NA, NaN)), 5)
})

test_that("System call dry run", {
  command <- systemf('touch %s', 'deleteme.txt', dry.run = TRUE) # Create a command without executing it

  expect_equal(command, "touch deleteme.txt") # Check that the correct command was generated
  expect_false(file.exists('deleteme.txt')) # Check that the command was not executed
})

test_that("System call with formatted string", {
  # This snippet ensures that the file is always deleted, even if the test fails
  on.exit(file.remove('deleteme.txt'))

  systemf('touch %s', 'deleteme.txt') # Create a file with systemf, ...
  expect_true(file.exists('deleteme.txt')) # ... check that it was indeed created
})

test_that("Shape string", {
  ext <- 1:4
  expected_str <- "1/4,2/4,2/3,1/3,1/4"
  str <- extToStr(ext)

  expect_equal(str, expected_str)
})
