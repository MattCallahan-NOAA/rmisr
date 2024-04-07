#' get_release
#' @description This function pulls release data from the RMIS database.
#' Any fields in the release table are passible through this function.
#' Please review data documentation and understand data documentation before using this package.
#' @param token Character string api-key provided by RMPC.
#' @param ... Any RMIS release table field name (e.g. reporting_agency, species, brood_year, etc.)
#' @examples
#' ## get chinook releases for 1990 reported by ADFG
#' adfg1990<-get_release(token="your-api-key", reporting_agency="ADFG", brood_year=1990)

get_release<-function(token=NA, only_count = FALSE, ...) {
  start_time <- Sys.time()
  url <- "https://phish.rmis.org/release"

  get_totalCount <- function(token, ...) {
    query <- list(... = ...)
    response <- GET(url, query = query, add_headers(xapikey = token))

    # Check if the response has an error
    if (http_error(response)) {
      # Extract and parse content from the response
      content <- content(response, "text", encoding = "UTF-8")
      error_info <- fromJSON(content)
      # Extract only the main error message
      main_error_message <- error_info$message
      # Suppress fxn info printing when stop
      stop(main_error_message, call. = FALSE)
    } else {
      # Extract totalCount if no error
      return(content(response)$totalCount)
    }
  }


  #function to pull by page 1000 records at time
  get_by_page <- function(token = NA, page = 1, ...) {
    query <- list(page = page, perpage = 1000, ... = ...)
    response <- GET(url, query = query, add_headers(xapikey = token))

    # Check if the response has an error
    if (http_error(response)) {
      # Extract and parse content from the response
      content <- content(response, "text", encoding = "UTF-8")
      error_info <- fromJSON(content)

      # Extract only the main error message
      main_error_message <- error_info$message
      # Suppress fxn info printing when stop
      stop(main_error_message, call. = FALSE)
    } else {
      # Process the successful response
      fromJSON(content(response, type = "text"))$records %>%
        bind_rows()
    }
  }

  # determine record count and number of pages needed
  totalcount <- suppressMessages(get_totalCount(token = token, ...))

  if (totalcount == 0) {
    message("No records found.")
    return(data.frame()) # Returning an empty data frame if no records are found
  }

  if (only_count) {
    # If only the count is requested, return here
    return(totalcount)
  }

  numberpages <- ceiling(totalcount / 1000)

  # write message for the potentially slow function
  message(paste0("Downloading ", totalcount, " records"))

  # apply the api pull function across the number of pages
  data <- suppressMessages(lapply(1:numberpages, FUN=function(x) {get_by_page(token=token,
                                                                              page=x,
                                                                              ...)})%>%dplyr::bind_rows())
  # time
  end_time <- Sys.time()
  message(paste("Time Elapsed:", round(end_time - start_time, 2),
                units(end_time - start_time)))

  # the data are the function output
  data
}
