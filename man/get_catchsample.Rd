% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_catchsample.R
\name{get_catchsample}
\alias{get_catchsample}
\title{get_catchsample}
\usage{
get_catchsample(token = NA, only_count = FALSE, ...)
}
\arguments{
\item{token}{Character string api-key provided by RMPC.}

\item{only_count}{Boolean. Returns record count}

\item{...}{Any RMIS catchsample table field name (e.g. reporting_agency, species, run_year, etc.)}
}
\description{
This function pulls catch sample data from the RMIS database.
Any fields in the catchsample table are passible through this function.
Please review data documentation and understand data documentation before using this package.
The full table is nearly half a million rows (2024) so please limit your query to only needed data.
}
\examples{
## get chinook catch samples for 1990 reported by ADFG of species 1
\dontrun{
adfg1990<-get_catchsample(token="your-api-key",
                          reporting_agency="ADFG",
                          catch_year=1990,
                          species = 1)
}
}
