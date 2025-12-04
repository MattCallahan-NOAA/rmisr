#' Get Multiple Tag Recovery Records
#'
#' @description
#' This function is a wrapper for `get_recovery()` that allows for pulling
#' tag recovery data from RMIS over a range of parameter values. Any fields
#' in the RMIS recovery table can be passed with either a single value or a
#' vector of values. Please review the RMIS API documentation for available
#' fields.
#'
#' @param token A character string representing the API key provided by RMPC.
#'   This is a required argument.
#' @param only_count A boolean value. If `TRUE`, the function returns the total
#'   count of records matching the query without downloading the data.
#'   Defaults to `FALSE`.
#' @param ... Any RMIS recovery table field name (e.g., `reporting_agency`,
#'   `species`, `run_year`, etc.). Single values or vectors of values can
#'   be passed to query multiple combinations.
#'
#' @return
#' If `only_count` is `FALSE` (the default), a data frame containing the
#' combined tag recovery records from all the API queries. If no records are
#' found, an empty data frame is returned.
#' If `only_count` is `TRUE`, a numeric value representing the total count of
#' records that match the query parameters.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Example 1: Get all recoveries for specific agencies in a single run year.
#' recovery_data <- mget_recovery(
#'   token = "your_api_key",
#'   run_year = 2010,
#'   reporting_agency = c("ADFG", "ODFW")
#' )
#'
#' # Example 2: Get the total count of chinook and coho recoveries for
#' # multiple run years without downloading the data.
#' recovery_count <- mget_recovery(
#'   token = "your_api_key",
#'   run_year = c(2015, 2016),
#'   species = c(1, 2), # 1 for Chinook, 2 for Coho
#'   only_count = TRUE
#' )
#' }
mget_recovery <- function(token, only_count = FALSE, ...) {
  # Capture the arguments passed via '...' into a list
  query_list <- list(... = ...)

  # If no query parameters are passed, call get_recovery directly
  if (length(query_list) == 0) {
    return(get_recovery(token = token, only_count = only_count))
  }

  # Create a data frame with all possible combinations of the provided arguments.
  # This creates the set of individual queries to run.
  # stringsAsFactors is set to FALSE to prevent character vectors from becoming factors.
  queries_df <- do.call(expand.grid, c(query_list, stringsAsFactors = FALSE))

  # Use apply to iterate over each row (each distinct query) of the data frame.
  # This returns a list of results (either data frames or counts).
  results_list <- apply(queries_df, 1, function(row) {
    # Convert the row of parameters to a list
    params <- as.list(row)

    # Combine the function's static arguments with the current set of parameters
    all_args <- c(list(token = token, only_count = only_count), params)

    # Call get_recovery with the combined list of arguments
    do.call(get_recovery, all_args)
  })

  # Process the list of results based on the 'only_count' flag
  if (only_count) {
    # If we only requested counts, sum the list of numeric results
    sum(unlist(results_list))
  } else {
    # If we requested data, combine the list of data frames into one
    # using dplyr::bind_rows for efficient and flexible binding.
    dplyr::bind_rows(results_list)
  }
}

