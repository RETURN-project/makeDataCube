context("Prepare supporting data")

test_that("Prepare fire time series", {
  library(terra)
  #mask
  r_empty <- terra::rast(ncol=3, nrow=3)
  m <- r_empty; values(m) <- c(1,1,0,1,1,1,1,1,1)
  # confidence
  cl1<- r_empty;  values(cl1) <- rep(0, 9)
  cl2<- r_empty; values(cl2) <- c(96,0,0,0,0,0,15,0,0)
  cl3<- r_empty; values(cl3) <- c(0,97,0,0,0,0,0,0,0)
  cl4<- r_empty; values(cl4) <- c(0,0,97,0,0,0,0,0,0)
  cl5<- r_empty; values(cl5) <- c(0,0,0,99,0,0,0,0,0)
  cl6<- r_empty; values(cl6) <- c(0,0,0,0,98,0,0,0,0)
  cl7<- r_empty; values(cl7) <- c(0,0,0,0,0,96,0,0,0)
  cl8<- r_empty; values(cl8) <- c(99,0,0,0,0,0,99,0,0)
  cl9<- r_empty; values(cl9) <- c(0,0,0,0,0,0,0,99,97)
  cl10<- r_empty; values(cl10) <- c(0,0,0,0,0,0,0,0,0)
  cl11<- r_empty; values(cl11) <- c(0,0,0,0,0,0,0,0,0)
  cl12<- r_empty; values(cl12) <- c(0,0,0,0,0,0,0,0,0)

  # day of observation
  jd1<- r_empty; values(jd1) <- c(0,0,0,0,0,0,0,0,0)
  jd2<- r_empty; values(jd2) <- c(33,0,0,0,0,0,0,0,0)# 2 feb
  jd3<- r_empty; values(jd3) <- c(0,62,0,0,0,0,0,0,0)# 3 mar
  jd4<- r_empty; values(jd4) <- c(0,0,94,0,0,0,0,0,0)# 4 apr
  jd5<- r_empty; values(jd5) <- c(0,0,0,125,0,0,0,0,0)#5 may
  jd6<- r_empty; values(jd6) <- c(0,0,0,0,157,0,0,0,0)#6jun
  jd7<- r_empty; values(jd7) <- c(0,0,0,0,0,188,0,0,0)#7jul
  jd8<- r_empty; values(jd8) <- c(220,0,0,0,0,0,232,0,0)#8aug & 20 aug
  jd9<- r_empty; values(jd9) <- c(0,0,0,0,0,0,0,252,254)#9sep 11sep
  jd10<- r_empty; values(jd10) <- c(0,0,0,0,0,0,0,0,0)
  jd11<- r_empty; values(jd11) <- c(0,0,0,0,0,0,0,0,0)
  jd12<- r_empty; values(jd12) <- c(0,0,0,0,0,0,0,0,0)

  #create stack
  fcl <- c(cl1,cl2,cl3,cl4,cl5,cl6,cl7,cl8,cl9,cl10,cl11,cl12)
  fjd <- c(jd1,jd2,jd3,jd4,jd5,jd6,jd7,jd8,jd9,jd10,jd11,jd12)
  dts <- seq(as.Date(paste0(2001,'-01-01')), as.Date(paste0(2001,'-12-31')), by = "1 month")

  extfolder <- normalizePath('./data')
  # to monthly observations
  firemo <- createFireStack(m, fcl, fjd, dts, resol= 'monthly', thres=95, extfolder)
  mfmo <- firemo[,]#rast::as.matrix(firemo)
  # to daily observations
  fireday <- createFireStack(m, fcl, fjd, dts, resol= 'daily', thres=95, extfolder)
  mfday <- fireday[,]#raster::as.matrix(fireday)

  d1 <- rep(0,365)
  d1[c(33,220)] <- 1
  d7 <- rep(0,365)
  d7[232] <- 1

  # case 1 - monthly
  expect_equal(as.numeric(mfmo[1,]), c(0,1,0,0,0,0,0,1,0,0,0,0), tolerance = 1e-4)
  expect_equal(as.numeric(mfmo[7,]), c(0,0,0,0,0,0,0,1,0,0,0,0), tolerance = 1e-4)
  expect_equal(sum(is.na(mfmo[3,])), 12, tolerance = 1e-4)
  # case 2 - daily
  expect_equal(as.numeric(mfday[1,]), d1, tolerance = 1e-4)
  expect_equal(as.numeric(mfday[7,]), d7, tolerance = 1e-4)
  unlink(file.path(extfolder, 'tsFire.tif'))
})

test_that("max with NA", {
  x <- c(1,8,3,9,4,5,NA,20)
  expect_equal(mmax(x),20)
})

test_that("generate regular ts",{
  library(zoo)
  library(bfast)
  library(lubridate)
  tsi <-  c(1, 2, 1,20, 1, 30, -12, -2, -11, -21, -10, -30, -9, -39, -8,-48, -7, -57, -6, -66)
  dts <- as.Date(c('2001-01-02','2001-01-03','2001-02-02','2001-02-04','2001-03-02','2001-03-04','2001-04-02','2001-04-05','2001-05-02','2001-05-12',
                   '2001-06-02','2001-06-03','2001-07-02','2001-07-22','2001-08-02','2001-08-12','2001-09-02','2001-09-22','2001-12-02','2001-10-02'))
  dts <- as.Date(dts, format = "X%Y.%m.%d") ## needed as input in the helper function of get_m_agg

  # create time series of monthly max
  brmomax <- toRegularTS(tsi, dts, fun = 'max', resol = 'monthly')
  names(brmomax) <- as.Date(toRegularTS(dts, dts, fun = 'max', resol = 'monthly'))
  # create time series of monthly mean values
  brmomean <- toRegularTS(tsi, dts, fun = 'mean', resol = 'monthly')
  names(brmomean) <- as.Date(toRegularTS(dts, dts, fun = 'mean', resol = 'monthly'))
  # create daily time series
  brday <- toRegularTS(tsi, dts, fun = 'max', resol = 'daily')
  names(brday) <- date_decimal(as.numeric(time(bfastts(rep(1,length(dts)), dts, type = "irregular"))))
  # create quarterly time series
  brquart <- toRegularTS(tsi, dts, fun = 'max', resol = 'quart')
  names(brquart) <- as.Date(toRegularTS(dts, dts, fun = 'mean', resol = 'quart'))

  # case 1 - monthly max
  expect_equal(as.numeric(brmomax), c(2,20,30,-2,-11,-10,-9,-8,-7,-66,NA,-6), tolerance = 1e-4)
  # case 2 - monthly mean
  expect_equal(as.numeric(brmomean), c(1.5,10.5,15.5,-7.0,-16.0,-20.0,-24.0,-28.0,-32.0,-66.0,NA,-6.0), tolerance = 1e-4)
  # case 3 - daily
  expect_equal(as.numeric(brday[c(1,2,32,34,60,62,91,94,121,131,152,153,182,202,213,223,244,264,274,335)]),
               c(1,2,1,20,1,30,-12,-2,-11,-21,-10,-30,-9,-39,-8,-48,-7,-57,-66,-6), tolerance = 1e-4)
  # case 4 - quarterly
  expect_equal(as.numeric(brquart),c(30,-2, -7,-6))
})

test_that("make mask without fire data",{
  library(terra)
  empty_rast <- rast(nrows =5, ncols = 5)
  lc1 <- empty_rast; values(lc1) <- c(1,2,3,4,5,6,7,1,3,4,5,12,1,1,1,3,9,4,2,3,1,1,5,6,4)
  lc2 <- empty_rast; values(lc2) <- c(1,2,3,4,5,6,7,1,3,4,5,12,1,9,1,3,9,4,2,3,1,1,5,6,4)
  lc <- c(lc1,lc2)
  empty_rast2 <- rast(nrows = 5, ncols = 5)#, xmin = -99, xmax = 99, ymin = -33, ymax = 33
  han <- empty_rast2; values(han) <- c(99,86,87,82,88,96,94,92,93,99,86,87,82,88,96,94,92,93,99,86,87,82,88,96,94)
  extfolder <- normalizePath('./data')
  lcDates <- as.Date(c('2000-01-01','2001-01-01'))

  out <- makeMaskNoFire(lc, lcDates, han, extfolder, Tyr = 2000, Ttree = 85)

  empty_rast2 <- rast(nrows = 3, ncols = 3, xmin = -99, xmax = 99, ymin = -33, ymax = 33)#, xmin = -99, xmax = 99, ymin = -33, ymax = 33
  han <- empty_rast2; values(han) <- c(99,86,87,82,88,96,94,92,93)
  out2 <- makeMaskNoFire(lc, lcDates, han, extfolder, Tyr = 2000, Ttree = 85)

  expect_equal(as.numeric(out[,]),c(1,1,1,0,1,0,0,1,1,1,1,0,0,0,1,1,0,1,1,1,1,0,1,0,1))
  expect_equal(as.numeric(out2[,]),c(0,1,1,0,1,0,0,1,1))
})

test_that("prepare fire data",{
  library(terra)
  empty_rast <- rast(nrows =3, ncols = 3)
  fcl1 <- empty_rast; values(fcl1) <- c(99,3,5,9,1,5,0,0,0)
  fcl2 <- empty_rast; values(fcl2) <- c(2,0,0,0,0,0,0,0,0)
  fcl3 <- empty_rast; values(fcl3) <- c(2,0,96,0,0,0,0,0,0)
  fcl4 <- empty_rast; values(fcl4) <- c(2,0,0,0,0,0,0,0,97)
  fcl5 <- empty_rast; values(fcl5) <- c(98,0,0,99,0,0,0,0,0)
  fcl6 <- empty_rast; values(fcl6) <- c(2,0,0,0,0,0,99,0,0)
  fcl <- c(fcl1,fcl2,fcl3,fcl4,fcl5,fcl6)
  jd1 <- empty_rast; values(jd1) <- c(75,76,77,79,71,78,0,0,0)#mar
  jd2 <- empty_rast; values(jd2) <- c(102,0,0,0,0,0,0,0,0)#apr
  jd3 <- empty_rast; values(jd3) <- c(132,0,136,0,0,0,0,0,0)#may
  jd4 <- empty_rast; values(jd4) <- c(162,0,0,0,0,0,0,0,167)#jun
  jd5 <- empty_rast; values(jd5) <- c(208,0,0,210,0,0,0,0,0)#jul
  jd6 <- empty_rast; values(jd6) <- c(232,0,0,0,0,0,239,0,0)#aug
  fjd <- c(jd1,jd2,jd3,jd4,jd5,jd6)
  # empty_rast2 <- rast(nrows = 5, ncols = 5)#, xmin = -99, xmax = 99, ymin = -33, ymax = 33

  han <- empty_rast; values(han) <- c(99,86,87,82,88,96,94,92,93)
  extfolder <- normalizePath('./data')
  fdts <- as.Date(c('2001-03-01','2001-04-01','2001-05-01','2001-06-01','2001-07-01','2001-08-01'))
  msk <- empty_rast; values(msk) <- c(1,1,0,1,1,1,1,1,1)
  tempRes <- 'monthly'
  starttime <- c(2001,1,1)
  endtime <- c(2001,12,1)
  extfolder <- normalizePath('./data')

  # same spatial resolution and extent
  out <- prepFire(fcl, fjd, fdts, han, msk, tempRes, Tconf = 85, starttime, endtime, extfolder)
  outm <- out[,]

  # different spatial resolution and extent, need to extend observation period
  empty_rast2 <- rast(nrows = 3, ncols = 3, xmin = -180, xmax = 180, ymin = -90, ymax = 27)#, xmin = -99, xmax = 99, ymin = -33, ymax = 33
  han <- empty_rast2; values(han) <- c(99,86,87,82,88,96,94,92,93)
  msk <- empty_rast2; values(msk) <- c(1,1,0,1,1,1,1,1,1)
  out2 <- prepFire(fcl, fjd, fdts, han, msk, tempRes, Tconf = 85, starttime, endtime, extfolder)
  out2m <- out2[,]

  # start date of study period later than start of fire dataset
  starttime <- c(2001,4,1)
  out3 <- prepFire(fcl, fjd, fdts, han, msk, tempRes, Tconf = 85, starttime, endtime, extfolder)
  out3m <- out3[,]

  expect_equal(as.numeric(outm[1,]),c(NaN,NaN,1,0,0,0,1,0,NaN, NaN, NaN, NaN))
  expect_equal(as.numeric(outm[3,]),c(NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN, NaN, NaN, NaN))
  expect_equal(as.numeric(out2m[1,]),c(NaN,NaN,0,0,0,0,1,0,NaN, NaN, NaN, NaN))
  expect_equal(as.numeric(out3m[1,]),c(0,0,0,1,0,NaN, NaN, NaN, NaN))
})
