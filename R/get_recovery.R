#' get_recovery
#' @description This function pulls recovery data from the RMIS database.
#' Any fields in the recovery table are passible through this function.
#' Please review data documentation and understand data documentation before using this package.
#' Queries > 500,000 records are not allowed.
#' Querying 500k records would take a long time so ideally queries will be substantially smaller than that.
#' If you reeeeaaaally want all 10 million + records you can loop this function by run year.
#' @param token Character string api-key provided by RMPC.
#' @param only_count Boolean. Returns record count
#' @param ... Any RMIS recovery table field name (e.g. reporting_agency, species, run_year, etc.)
#' @examples
#' ## get chinook recovery for 1990 reported by ADFG of species 1
#' \dontrun{
#' adfg1990<-get_recovery(token="your-api-key", reporting_agency="ADFG", run_year=1990, species = 1)
#' }


get_recovery<-function(token=NA, only_count = FALSE, ...) {

  start_time<-Sys.time()
  url<-"https://phish.rmis.org/recovery"
  # function to determine the number of pages needed
  get_totalCount <- function(token, ...) {
    query <- list(... = ...)
    response <- httr::GET(url, query = query, httr::add_headers(xapikey = token))

    # Check if the response has an error
    if (httr::http_error(response)) {
      # Extract and parse content from the response
      content <- httr::content(response, "text", encoding = "UTF-8")
      error_info <- jsonlite::fromJSON(content)
      # Extract only the main error message
      main_error_message <- error_info$message
      # Suppress fxn info printing when stop
      stop(main_error_message, call. = FALSE)
    } else {
      # Extract totalCount if no error
      return(httr::content(response)$totalCount)
    }
  }


  #function to pull by page 1000 records at time
  get_by_page <- function(token = NA, page = 1, ...) {
    query <- list(page = page, perpage = 1000, ... = ...)
    response <- httr::GET(url, query = query, httr::add_headers(xapikey = token))

    # Check if the response has an error
    if (httr::http_error(response)) {
      # Extract and parse content from the response
      content <- httr::content(response, "text", encoding = "UTF-8")
      error_info <- jsonlite::fromJSON(content)

      # Extract only the main error message
      main_error_message <- error_info$message
      # Suppress fxn info printing when stop
      stop(main_error_message, call. = FALSE)
    } else {
      # Process the successful response
      jsonlite::fromJSON(httr::content(response, type = "text"))$records %>%
        dplyr::bind_rows()
    }
  }

  # determine record count and number of pages needed
  totalcount<-suppressMessages(get_totalCount(token=token, ...))

  if (totalcount == 0) {
    message("No records found.")
    return(data.frame()) # Returning an empty data frame if no records are found
  }

  if (only_count) {
    # If only the count is requested, return here
    return(totalcount)
  }

  numberpages<-ceiling(totalcount/1000)

  if(totalcount>500000) {
    message(paste0("Download of ", totalcount, " records is too large. Please submit a smaller query"))
  }else{

    # write message for the potentially slow function
    message(paste0("Downloading ", totalcount, " records"))

    # apply the api pull function across the number of pages
    data<-suppressMessages(lapply(1:numberpages, FUN=function(x) {get_by_page(token=token,
                                                                        page=x,
                                                                        ...)})%>%dplyr::bind_rows())
    # time
    end_time<-Sys.time()
    message(paste("Time Elapsed:", round(end_time - start_time, 2),
                  units(end_time - start_time)))

    # the data are the function output
    data}
}
