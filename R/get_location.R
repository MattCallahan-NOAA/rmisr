#' get_location
#' @description This function pulls location data from the RMIS database.
#' Any fields in the location table are passible through this function.
#' Please review data documentation and understand data documentation before using this package.
#' @param token Character string api-key provided by RMPC.
#' @param ... Any RMIS location table field name (e.g. reporting_agency, psc_basin, location_type, etc.)
#' @examples
#' ## get type 2  locations reported by ADFG
#' adfg2<-get_locaton(token="your-api-key", reporting_agency="ADFG", location_type=2)

get_location<-function(token=NA, ...) {

  start_time<-Sys.time()
  url<-"https://phish.rmis.org/location"
  # function to determine the number of pages needed
  get_totalCount<-function(token, ...) {
    url<-"https://phish.rmis.org/location"
    query<-list(...=...)
    content(
      GET(url, query=query, add_headers(xapikey=token)) %>%
        stop_for_status())$totalCount
  }

  #function to pull by page 1000 records at time
  get_by_page <- function(token=NA, page=1, ...) {
    url<-"https://phish.rmis.org/location"
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
