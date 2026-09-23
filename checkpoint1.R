# BIOSTAT 707 Checkpoint 1: cohort characterization and EDA, set-a.
# Run with:  pixi run --locked checkpoint1
# No arguments. Writes everything to output/.

suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
  library(ggplot2)
})

root <- here::here()
data_dir <- file.path(root, "data")
out_dir  <- file.path(root, "output")
dir.create(out_dir, showWarnings = FALSE)
expected_n <- 4000

check_set_a <- function() {
  # data/set-a/ and data/Outcomes-a.txt must already be in place
  stopifnot("data/Outcomes-a.txt is missing" =
              file.exists(file.path(data_dir, "Outcomes-a.txt")))
  n <- length(list.files(file.path(data_dir, "set-a"), pattern = "\\.txt$"))
  stopifnot("data/set-a does not have 4000 records" = n == expected_n)
}

load_set_a <- function() {
  files <- list.files(file.path(data_dir, "set-a"), full.names = TRUE)
  raw <- rbindlist(lapply(files, function(f) {
    d <- fread(f)
    d[, RecordID := as.integer(tools::file_path_sans_ext(basename(f)))]
    d
  }))
  static_vars <- c("Age", "Gender", "Height", "ICUType", "Weight")
  static <- raw[Time == "00:00" & Parameter %in% static_vars] |>
    dcast(RecordID ~ Parameter, value.var = "Value", fun.aggregate = first)
  static[static == -1] <- NA            # -1 codes missing descriptors
  ts <- raw[!Parameter %in% c(static_vars, "RecordID")]
  list(ts = ts, static = static)
}

check_set_a()
d <- load_set_a()
outcomes <- fread(file.path(data_dir, "Outcomes-a.txt"))
stopifnot(nrow(outcomes) == expected_n)

# 1. Table 1                 -> output/table1.csv  (or .html from gtsummary)
# 2. Outcome summary         -> output/outcomes.csv
# 3. Missingness map         -> output/missingness_map.png
# 4. Missingness as signal   -> output/missingness_vs_death.csv
# ...

message("Checkpoint 1 complete. See output/.")