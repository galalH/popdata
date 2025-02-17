#' @noRd
assert_cache <- function(x)
  if (!inherits(x, "HoardClient"))
    stop("Not a `hoardr` cache object", call. = FALSE)

#' @noRd
assert_memoise_cache <- function(x)
  if (!inherits(x, "cache_mem"))
    stop("Not a `cachem` cache object", call. = FALSE)

#' @noRd
#' @importFrom crul HttpClient auth
pd_GET <- function(path, cookie = Sys.getenv("POPDATA_COOKIE", ""), quiet = FALSE) {
  cli <- HttpClient$new(url = "https://popdata.unhcr.org",
                        opts = list(cookie = cookie))
  res <- cli$get(path)
  res$raise_for_status()
  res <- tryCatch({res$raise_for_ct(type = "text/csv"); res},
                  error = function(e) {
                    if (!quiet)
                      message("No valid popdata session available, generating a session cookie...")
                    pd_session()
                    cookie <- Sys.getenv("POPDATA_COOKIE", "")
                    cli <- HttpClient$new(url = "https://popdata.unhcr.org",
                                          opts = list(cookie = cookie))
                    res <- cli$get(path)
                    res$raise_for_status()
                    res
                  })
  res
}

#' @noRd
#' @importFrom readr read_delim locale
read_pd_csv <- function(x)
  suppressMessages(read_delim(x,
                              na = c("", "NA", "N/A"),
                              guess_max = 1e+05,
                              delim = ";",
                              locale = locale(decimal_mark = ".")))
