library(plumber)

#* @apiTitle CRAN non-API usage checks
#* @apiDescription Check whether an R package on CRAN uses non-API calls to R internals.

#* Check for non-API calls in an R package
#* @param pkg The package name to check
#* @tag checks
#* @serializer unboxedJSON
#* @get /check
function(pkg, res) {
  url <- sprintf(
    "https://cloud.r-project.org/web/checks/check_results_%s.html",
    pkg
  )

  all_html <- tryCatch(readLines(url), error = function(e) NULL)

  if (is.null(all_html)) {
    res$status <- 404L
    return(list(error = sprintf("Package '%s' not found on CRAN.", pkg)))
  }

  non_api_lines <- trimws(
    unique(
      all_html[grepl("non-API calls? to R: ", all_html)]
    )
  )

  symbols <- unique(unlist(regmatches(
    non_api_lines,
    gregexpr("(?<=')\\w+(?=')", non_api_lines, perl = TRUE)
  )))

  last_updated <- gsub("Last updated on ", "", all_html[13]) |>
    gsub(" CEST.", " CEST", x = _)

  list(
    last_updated = last_updated,
    has_non_api_calls = length(symbols) > 0L,
    symbols = I(symbols)
  )
}
