

test_that("server starts", {
  if (Sys.getenv("PERLPATH") != "") {
    server = start_server(perl_path = Sys.getenv("PERLPATH"))
  }
  else {
    server = start_server()
  }
  expect_true(server$server_object$is_alive())
})

