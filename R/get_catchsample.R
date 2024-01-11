#' get_catchsample
#' @description This function pulls catch sample data from the RMIS database.
#' Any fields in the catchsample table are passible through this function.
#' Please review data documentation and understand data documentation before using this package.
#' The full table is nearly half a million rows (2024) so please limit your query to only needed data.
#' @param token Character string api-key provided by RMPC.
#' @param ... Any RMIS catchsample table field name (e.g. reporting_agency, species, run_year, etc.)
#' @examples
#' ## get chinook catch samples for 1990 reported by ADFG of species 1
#' adfg1990<-get_release(token="your-api-key", reporting_agency="ADFG", catch_year=1990, species = 1)

get_catchsample<-function(token=NA, ...) {

  start_time<-Sys.time()
  url<-"https://phish.rmis.org/catchsample"
  # function to determine the number of pages needed
  get_totalCount<-function(token, ...) {
    query<-list(...=...)
    content(
      GET(url, query=query, add_headers(xapikey=token)) %>%
        stop_for_status())$totalCount
  }

  #function to pull by page 1000 records at time
  get_by_page <- function(token=NA, page=1, ...) {
    query<-list(page=page,
                perpage=1000,
                ...=...)
    fromJSON(content(
      GET(url, query=query, add_headers(xapikey=token)) %>%
        stop_for_status(), type= "text"))$records %>%
      bind_rows()
  }

  # determine record count and number of pages needed
  tc<-suppressMessages(get_totalCount(token=token, ...))

  npage<-ceiling(tc/1000)

  # write message for the potentially slow function
  message(paste0("Downloading ", tc, " records"))

  # apply the api pull function across the number of pages
  data<-suppressMessages(lapply(1:npage, FUN=function(x) {get_by_page(token=token,
                                                                      page=x,
                                                                      ...)})%>%bind_rows())
  # time
  end_time<-Sys.time()
  message(paste("Time Elapsed:", round(end_time - start_time, 2),
                units(end_time - start_time)))

  # the data are the function output
  data
}
