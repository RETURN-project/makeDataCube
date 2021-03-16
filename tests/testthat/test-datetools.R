context("Date time auxiliary functions")

test_that("Vector to date", {
  # Check that the parsing is properly done
  v <- c(2021, 12, 30)
  d <- vec_to_date(v)

  expect_equal(year(d), v[1])
  expect_equal(month(d), v[2])
  expect_equal(day(d), v[3])
})

test_that("Inversion", {
  # Check that the vec_to_date and date_to_vec methods counteract each other
  v <- c(2021, 3, 16)
  identical <- all(date_to_vec(vec_to_date(v)) == v)
  expect_true(identical)

  d <- date("2021-3-16")
  identical <- (vec_to_date(date_to_vec(d)) == d)
  expect_true(identical)
})
