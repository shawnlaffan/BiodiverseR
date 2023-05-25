test_that("api key generates as expected", {
    config <- start_server()
    api_1 <- config$api_key
    config <- start_server()
    api_2 <- config$api_key

    message("API KEY")
    print(api_1)
    print(api_2)
    expect_equal(api_1, api_2)
})

test_that("api key generates as expected 2", {
    config <- start_server()
    api_1 <- config$api_key
    config <- start_server()
    api_2 <- config$api_key
    message("API KEY")
    print(api_1)
    print(api_2)
    expect_equal(api_1, api_2)

})