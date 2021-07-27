context("Dry run level 2")

test_that("Level 2 dry run", {
  paramfolder <- "data/param"
  paramfile <- "l2param.prm"
  l2folder <- "data/level2"

  cmds <- process2L2(paramfolder, paramfile, l2folder, dry.run = TRUE)

  expect_equal(cmds[[1]], "force-level2 data/param/l2param.prm")
  expect_equal(cmds[[2]], "force-mosaic data/level2")
})
