

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
  target_url <- paste0(server$server_url, "/valid_cluster_linkage_functions")
  body_as_json <- rjson::toJSON(params)
  req <- httr2::request(target_url)
  req <- httr2::req_body_raw(req, body_as_json)
  req <- httr2::req_method(req, "GET")
  response <- httr2::req_perform(req)
  call_results <- httr2::resp_body_json(response)

  result = call_results[['error']]
  #exp = "Stored api_key does not match api_key passed in"

  #  should get nothing back if api_key is wrong
  expect_equal(call_results, NULL, info = 'Null result when API key is wrong')

  # Checks if exp exists in results
  #expect_equal(grepl(exp, result), TRUE)
})
