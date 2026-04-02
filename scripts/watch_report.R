args <- commandArgs(trailingOnly = TRUE)
interval <- if (length(args)) as.numeric(args[[1]]) else 1

if (is.na(interval) || interval <= 0) {
  stop("Polling interval must be a positive number of seconds.")
}

suppressPackageStartupMessages(library(rmarkdown))

target <- normalizePath("report.Rmd", mustWork = TRUE)
output_file <- "index.html"

render_report <- function() {
  tryCatch(
    {
      rmarkdown::render(target, output_file = output_file, quiet = FALSE)
      message(sprintf("[%s] Render complete.", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
    },
    error = function(e) {
      message(sprintf("[%s] Render failed: %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), conditionMessage(e)))
    }
  )
}

last_mtime <- file.info(target)$mtime
if (is.na(last_mtime)) {
  stop("Could not read modification time for report.Rmd")
}

message(sprintf("Watching %s every %s second(s)...", target, interval))
message("Press Ctrl+C to stop.")

repeat {
  Sys.sleep(interval)
  current_mtime <- file.info(target)$mtime

  if (is.na(current_mtime)) {
    next
  }

  if (current_mtime > last_mtime) {
    last_mtime <- current_mtime
    message(sprintf("[%s] Change detected. Rendering...", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
    render_report()
  }
}
