#' mget_release
#' @description This function is a wrapper for the get_release function that
#' allows for pulling data from RMIS over a range of parameter values.
#' Any fields in the release table are passable with either a single value
#' or vector of values. Please review data documentation and understand data
#' documentation before using this package.
#' @param token Character string api-key provided by RMPC.
#' @param only_count Boolean. Returns record count
#' @param ... Any RMIS release table field name (e.g. reporting_agency, species,
#' brood_year, etc.). Single values or vectors may be passed.
#' @export
#' @examples
#' ## get chinook and coho releases for BY 2017 and 2018 reported by WDFW from
#' ## Minter Cr Hatchery
#' \dontrun{
#' minter_rel<-mget_release(token="your-api-key", brood_year=c(2017, 2018),
#'   species=c(1, 2), release_location_code="3F10513  150048 ~")
#'

mget_release <- function(token = api_key, only_count = FALSE, ...) {
  resp2 <- NULL
  query_lst <- list(... = ...)
  query_lst <- do.call(expand.grid, query_lst)

  for (i in 1:nrow(query_lst)) {
    query <- query_lst[i, ] |>
      dplyr::mutate(across(where(is.factor), as.character))

    resp <- get_release(
      token = token,
      only_count = only_count,
      mquery = query
    )

    if (!is.null(resp2) & !is.null(resp)) {
      resp2 <- rbind(resp2, resp)
    } else {
      resp2 <- resp
    }
  }
  mget_release <- resp2
}
