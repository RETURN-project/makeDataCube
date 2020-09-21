Sys.setenv("R_TESTS" = "")
library(testthat)
library(makeDataCube)

test_check("makeDataCube")
