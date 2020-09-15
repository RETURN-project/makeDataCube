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
  firemo <- createFireStack(m, fcl, fjd, dts, resol= 'monthly', thres=95, extfolder)
  mfmo <- firemo[,]#rast::as.matrix(firemo)
  fireday <- createFireStack(m, fcl, fjd, dts, resol= 'daily', thres=95, extfolder)
  mfday <- fireday[,]#raster::as.matrix(fireday)
  # firemo <- calc(st, function(x){createFireStack(x, dts, resol = 'monthly', thres = 95)})
  # fireday <- calc(st, function(x){createFireStack(x, dts, resol = 'daily', thres = 95)})


  d1 <- rep(0,365)
  d1[c(33,220)] <- 1
  d7 <- rep(0,365)
  d7[232] <- 1

  # case 1 - monthly
  # toFireTS(c(m[,][1,],fcl[,][1,],fjd[,][1,]), dts = dts, resol = 'monthly', thres = 95, olen = 12)
  expect_equal(as.numeric(mfmo[1,]), c(0,1,0,0,0,0,0,1,0,0,0,0), tolerance = 1e-4)
  expect_equal(as.numeric(mfmo[7,]), c(0,0,0,0,0,0,0,1,0,0,0,0), tolerance = 1e-4)
  expect_equal(sum(is.na(mfmo[3,])), 12, tolerance = 1e-4)
  # case 2 - daily
  expect_equal(as.numeric(mfday[1,]), d1, tolerance = 1e-4)
  expect_equal(as.numeric(mfday[7,]), d7, tolerance = 1e-4)
  unlink(file.path(extfolder, 'tsFire.tif'))
})

