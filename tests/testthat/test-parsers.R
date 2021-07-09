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

context("Parameter generator")

test_that("Default", {
  cfg <- gen_params()

  # Test that it has the appropriate size
  expect_equal(nrow(cfg), 52)

  # Check some specific values
  expect_equal(cfg["DEM_NODATA", ], "-32768")
  expect_equal(cfg["OUTPUT_FORMAT", ], "GTiff")
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
