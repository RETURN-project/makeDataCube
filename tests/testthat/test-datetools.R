context("Date time parsers")

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

context("Date partition")

test_that("Controlled example", {
  starttime <- c(2021, 1, 1)
  endtime <- c(2021, 1, 13)

  partition <- partition_dates(starttime, endtime, n = 2)

  # Check the partition manually
  expected <- c(interval(vec_to_date(starttime), vec_to_date(c(2021, 1, 7))),
                interval(vec_to_date(c(2021, 1, 7)), vec_to_date(endtime)))

  expect_equal(partition, expected)
})

test_that("Integer / noninteger division", {
  starttime <- c(1999, 12, 1)
  endtime <- c(2021, 3, 16) # Time difference of 7776 days

  # 7776 is divisible by 8 ...
  partition_even <- partition_dates(starttime, endtime, n = 8)
  # ... so we expect 8 subpartitions ...
  expect_equal(length(partition_even), 8)
  # ... all of them equal ...
  lengths <- int_length(partition_even)
  expect_true(all(lengths == max(lengths)))
  # ... and adding up to the total, initial interval
  expect_equal(sum(partition_even), 7776 * 3600 * 24) # In seconds

  # 7776 is not divisible by 7 ...
  partition_uneven <- partition_dates(starttime, endtime, n = 7)
  # ... so we expect 8 subpartitions ...
  expect_equal(length(partition_uneven), 7)
  # ... the last of them, larger than the rest ...
  lengths <- int_length(partition_uneven)
  expect_true(all(lengths[1:6] == max(lengths[1:6])))
  expect_true(lengths[7] > lengths[1])
  # ... and adding up to the total, initial interval
  expect_equal(sum(partition_uneven), 7776 * 3600 * 24) # In seconds
})
