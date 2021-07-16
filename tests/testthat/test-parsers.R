# Get the example parameter file
example <- system.file("extdata", "example.prm", package = "makeDataCube")

context("Parameter file parser")

test_that("Parse all", {
  cfg <- import_params(example)

  # Test that it has the appropriate size
  expect_equal(nrow(cfg), 52)

  # Check some specific values
  expect_equal(cfg["DEM_NODATA", ], "-32768")
  expect_equal(cfg["OUTPUT_FORMAT", ], "GTiff")
})

test_that("Parse all (as list)", {
  cfg <- import_params(example, as.list = TRUE)

  # Test that it has the appropriate size
  expect_equal(length(cfg), 52)

  # Check some specific values
  expect_equal(cfg$DEM_NODATA, "-32768")
  expect_equal(cfg$OUTPUT_FORMAT, "GTiff")
})

context("Parameter generator")

test_that("Default", {
  cfg <- gen_params()

  # Test that it has the appropriate size
  expect_equal(nrow(cfg), 52)

  # Check some specific values
  expect_equal(cfg["DEM_NODATA", ], "-32768")
  expect_equal(cfg["OUTPUT_FORMAT", ], "GTiff")
})

test_that("Default (as list)", {
  cfg <- gen_params(as.list = TRUE)

  # Test that it has the appropriate size
  expect_equal(length(cfg), 52)

  # Check some specific values
  expect_equal(cfg$DEM_NODATA, "-32768")
  expect_equal(cfg$OUTPUT_FORMAT, "GTiff")
})

test_that("Override", {
  cfg <- gen_params(OUTPUT_FORMAT = "GeoTiff",
                    NPROC = "6")

  # Test that it has the appropriate size
  expect_equal(nrow(cfg), 52)

  # Check some specific values
  expect_equal(cfg["DEM_NODATA", ], "-32768")
  expect_equal(cfg["OUTPUT_FORMAT", ], "GeoTiff")
  expect_equal(cfg["NPROC", ], "6")
})

test_that("Override (as list)", {
  cfg <- gen_params(OUTPUT_FORMAT = "GeoTiff",
                    NPROC = "6",
                    as.list = TRUE)

  # Test that it has the appropriate size
  expect_equal(length(cfg), 52)

  # Check some specific values
  expect_equal(cfg$DEM_NODATA, "-32768")
  expect_equal(cfg$OUTPUT_FORMAT, "GeoTiff")
  expect_equal(cfg$NPROC, "6")
})

context("Data frame and list conversions")

test_that("Inverse", {
  cfg <- gen_params()

  # Convert to list and back to data frame
  cfg2 <- cfgl_to_df(cfg_to_list(cfg))

  # Check that the original cfg data frame is recovered
  expect_true(identical(cfg, cfg2))
})

test_that("Inverse (as list)", {
  cfgl <- gen_params(as.list = TRUE)

  # Convert to data frame and back to list
  cfgl2 <- cfg_to_list(cfgl_to_df(cfgl))

  # Check that the original cfgl list is recovered
  expect_true(identical(cfgl, cfgl2))
})
