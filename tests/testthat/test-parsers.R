# Get the example parameter file
example <- system.file("extdata", "example.prm", package = "makeDataCube")

context("Parameter file parsers")

test_that("Parse all", {
  config <- parse_params(example)

  # Test that it has the appropriate size
  expect_equal(nrow(config), 52)
})

test_that("Parse key value pair", {
  key <- "^OUTPUT_FORMAT\\b"
  val <- parse_params(example, key)

  # Test that the value has been properly read
  expect_equal(val, "GTiff")
})
