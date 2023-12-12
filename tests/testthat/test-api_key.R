

test_that("Test when wrong server api key is passed", {
  if (Sys.getenv("PERLPATH") != "") {
    server = start_server(perl_path = Sys.getenv("PERLPATH"))
  }
  else {
    server = start_server()
  }
  # Grab correct api key
  generated_api_key = server$server_api_key

  # Ensures the fake api key is not the same as the actual api key
  expect_false(generated_api_key == "invalidkey")

  # Create the params
  params = list (
    api_key = "invalidkey"
  )
  
  # Call the server
  target_url <- paste0(server$server_url, "/analysis_spatial_oneshot")
  body_as_json <- rjson::toJSON(params)
  response <- httr::POST(
    url = target_url,
    body = body_as_json,
    encode = "json",
  )

  call_results <- httr::content(response, "parsed")
  result = call_results[['error']]
  exp = "Stored api_key does not match api_key passed in"
  # Should get the error message back
  expect_equal(result, exp)
})
