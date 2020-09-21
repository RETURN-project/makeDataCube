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

test_that("Maximum value with NA",{
  expect_equal(max_narm(c(1,5,NA, NaN)), 5)
})
