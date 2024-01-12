#' get_recovery
#' @description This function pulls recovery data from the RMIS database.
#' Any fields in the recovery table are passible through this function.
#' Please review data documentation and understand data documentation before using this package.
#' Queries > 500,000 records are not allowed.
#' Querying 500k records would take a long time so ideally queries will be substantially smaller than that.
#' If you reeeeaaaally want all 10 million + records you can loop this function by run year.
#' @param token Character string api-key provided by RMPC.
#' @param ... Any RMIS recovery table field name (e.g. reporting_agency, species, run_year, etc.)
#' @examples
#' ## get chinook recovery for 1990 reported by ADFG of species 1
#' adfg1990<-get_recovery(token="your-api-key", reporting_agency="ADFG", run_year=1990, species = 1)

get_recovery<-function(token=NA, ...) {

  start_time<-Sys.time()
  url<-"https://phish.rmis.org/recovery"
  # function to determine the number of pages needed
  get_totalCount<-function(token, ...) {
    query<-list(...=...)
    httr::content(
      httr::GET(url, query=query,  httr::add_headers(xapikey=token)) %>%
        httr::stop_for_status())$totalCount
  }

  #function to pull by page 1000 records at time
  get_by_page <- function(token=NA, page=1, ...) {
    query<-list(page=page,
                perpage=1000,
                ...=...)
    jsonlite::fromJSON(content(
      httr::GET(url, query=query,  httr::add_headers(xapikey=token)) %>%
        httr::stop_for_status(), type= "text"))$records %>%
      dplyr::bind_rows()
  }

  # determine record count and number of pages needed
  tc<-suppressMessages(get_totalCount(token=token, ...))

  npage<-ceiling(tc/1000)

  if(tc>500000) {
    message(paste0("Download of ", tc, " records is too large. Please submit a smaller query"))
  }else{

    # write message for the potentially slow function
    message(paste0("Downloading ", tc, " records"))

    # apply the api pull function across the number of pages
    data<-suppressMessages(lapply(1:npage, FUN=function(x) {get_by_page(token=token,
                                                                        page=x,
                                                                        ...)})%>%dplyr::bind_rows())
    # time
    end_time<-Sys.time()
    message(paste("Time Elapsed:", round(end_time - start_time, 2),
                  units(end_time - start_time)))

    # the data are the function output
    data}
}
