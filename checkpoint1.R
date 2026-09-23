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

#----------------------------------------------------------------------

check_set_a <- function() {
  # data/set-a/ and data/Outcomes-a.txt must already be in place
  stopifnot("data/Outcomes-a.txt is missing" =
              file.exists(file.path(data_dir, "Outcomes-a.txt")))
  n <- length(list.files(file.path(data_dir, "set-a"), pattern = "\\.txt$"))
  stopifnot("data/set-a does not have 4000 records" = n == expected_n)
}


#---------------------------------------------------------------------------

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

#------------------------------------------------------------------

check_set_a()
d <- load_set_a()


#---------------------------------------------------------

outcomes <- fread(file.path(data_dir, "Outcomes-a.txt"))
for (col in c("SAPS-I", "SOFA", "Length_of_stay"))
  set(outcomes, which(outcomes[[col]] == -1), col, NA)
stopifnot(nrow(outcomes) == expected_n)

#------------------------------------------------------

# Combining multiple set-a “skinny” tables into giant skinny table

fwrite(d$ts, file.path(out_dir, "set-a_long.csv"))

#--------------------------------------------------------------

long <- fread(file.path(out_dir, "set-a_long.csv"))
str(long)

#time, parameter, value, recordid

#looking at variable measures/how many rows belong to each

long[, .N, by = Parameter][order(-N)]

#-------------------------------------------------------
#looking for implausible values

long[, .(min_val = min(Value, na.rm = TRUE),
         max_val = max(Value, na.rm = TRUE)),
     by = Parameter]

#pH: max = 735, temp min = -17.80, these values aren't possible
#extreme values that could be possible: HR: min = 0, NIDiasABP ,in = 0,
#NIMAP min = 0, NISysABP min = 0, ALP/ALT/AST max in thousands, 
#urine max = 11000

#i'd set implausible values to NA and fix the ranges of those i know are
#out of range

#-----------------------------------------------------------

#missing vales

#long[Value == -1, Value := NA] #i'd recode for missing variables

long[, .(pct_missing = mean(is.na(Value))), 
     by = Parameter][order(-pct_missing)]


#looking at what percent of patients had what measured

patients_measured <- long[!is.na(Value), .(n_patients = uniqueN(RecordID)), by = Parameter]
patients_measured[, pct_of_cohort := 100 * n_patients / 4000]
patients_measured[order(pct_of_cohort)]

#looking at hoe often "extreme" values show to determine to fix them
#leave HR=0/BP=0 as "extreme but plausible

long[Parameter == "HR", .N, by = .(Value == 0)]
long[Parameter %in% c("NIDiasABP","NIMAP","NISysABP","SysABP","DiasABP","MAP"), .N, by = .(Value == 0)]
long[Parameter == "Urine", .(n_over_5000 = sum(Value > 5000, na.rm = TRUE))]

#--------------------------------------------------------------------
#The missingness-over-time graph

long[, hour := as.integer(substr(Time, 1, 2))]

temporal_missing <- long[, .(n_measured = uniqueN(RecordID)), by = .(Parameter, hour)]
temporal_missing[, pct_measured := 100 * n_measured / length(unique(long$RecordID))]

heat_long <- ggplot(temporal_missing, aes(x = hour, y = Parameter, fill = pct_measured)) +
  geom_tile() +
  scale_fill_viridis_c(name = "% of\npatients\nmeasured") +
  labs(title = "Temporal missingness map — long table",
       x = "Hour since ICU admission", y = NULL)


ggsave(file.path(out_dir, "missingness_maplongHeat.png"), heat_long, width = 7, height = 5)

d$ts[, hour := as.integer(substr(Time, 1, 2))]

missing_by_hour <- d$ts[!is.na(Value), .(n_patients = uniqueN(RecordID)), by = hour]

p1 <- ggplot(missing_by_hour, aes(x = hour, y = n_patients)) +
  geom_line() +
  labs(title = "Number of patients with at least one reading, by hour",
       x = "Hour since admission", y = "Number of patients")


ggsave(file.path(out_dir, "missingness_map_longGraph.png"), p1, width = 7, height = 5)



#----------------------------------------------------------

#CLEAN long set a

l_clean <- copy(d$ts)
l_clean[Value == -1, Value := NA]
l_clean[Parameter == "pH" & (Value < 6.5 | Value > 8.0), Value := NA]
l_clean[Parameter == "Temp" & (Value < 25 | Value > 43), Value := NA]

fwrite(l_clean, file.path(out_dir, "set-a_long_clean.csv"))

#-------------------------------------------------------

# Build a wide table 

long <- fread(file.path(out_dir, "set-a_long.csv"))


summary_long <- long[, .(
  count = .N,
  first = first(Value[!is.na(Value)]),
  last  = last(Value[!is.na(Value)]),
  min   = min(Value, na.rm = TRUE),
  max   = max(Value, na.rm = TRUE),
  mean  = mean(Value, na.rm = TRUE)
), by = .(RecordID, Parameter)]

summary_long_melt <- melt(summary_long, id.vars = c("RecordID", "Parameter"),
                          variable.name = "stat", value.name = "value")
summary_long_melt[, colname := paste(Parameter, stat, sep = "_")]

wide <- dcast(summary_long_melt, RecordID ~ colname, value.var = "value")

#to keep 4000 participants

wide <- merge(outcomes, wide, by = "RecordID", all.x = TRUE)
for (col in grep("_count$", names(wide), value = TRUE))
  set(wide, which(is.na(wide[[col]])), col, 0)
stopifnot(nrow(wide) == expected_n)

dim(wide)

fwrite(wide, file.path(out_dir, "set-a_wide.csv"))




#-----------------------------------------------------------

#graph missing data wide

count_cols <- grep("_count$", names(wide), value = TRUE)

wide_missing <- data.table(
  Parameter = sub("_count$", "", count_cols),
  pct_never_measured = sapply(count_cols, function(col) 100 * mean(wide[[col]] == 0 | is.na(wide[[col]])))
)

p2 <- ggplot(wide_missing, aes(x = reorder(Parameter, pct_never_measured), y = pct_never_measured)) +
  geom_col(fill = "darkorange") +
  coord_flip() +
  labs(title = "Missingness map — wide table",
       x = NULL, y = "% of patients never measured")


ggsave(file.path(out_dir, "missingness_map_wide.png"), p2, width = 7, height = 5)


#-----------------------------------------------------------
# Patient x variable missingness map (wide table)

mean_cols <- grep("_mean$", names(wide), value = TRUE)
vars <- sub("_mean$", "", mean_cols)

map_data <- merge(wide[, c("RecordID", "In-hospital_death", mean_cols), with = FALSE],
                  d$static[, .(RecordID, ICUType)], by = "RecordID")
setnames(map_data, mean_cols, vars)
map_data[, ICUType := factor(ICUType, levels = 1:4,
                             labels = c("CCU", "CSRU", "MICU", "SICU"))]
setorder(map_data, ICUType, `In-hospital_death`)

p_map <- naniar::vis_miss(map_data[, ..vars], sort_miss = TRUE) +
  labs(title = "Missingness map: patients x variables (48-hour window)",
       y = "Patients (sorted by ICU type, then outcome)")
ggsave(file.path(out_dir, "missingness_map.png"), p_map,
       width = 11, height = 7, dpi = 150)

p_fct <- naniar::gg_miss_fct(map_data[, c(vars, "ICUType"), with = FALSE],
                             fct = ICUType) +
  labs(title = "% of patients never measured, by ICU type", x = "ICU type")
ggsave(file.path(out_dir, "missingness_by_icutype.png"), p_fct,
       width = 7, height = 8, dpi = 150)

dim(wide)

# checked and saw 3 people missing - 3 patients with zero time-series data



#-----------------------------------------------------

names(d$static)
names(outcomes)



#------------------------------------------


# 1.) Table 1

table1_data <- merge(d$static, outcomes, by = "RecordID")

table1_data[, Gender := factor(Gender, levels = c(0, 1), labels = c("Female", "Male"))]
table1_data[, ICUType := factor(ICUType, levels = 1:4,
                                labels = c("Coronary Care Unit", "Cardiac Surgery Recovery",
                                           "Medical ICU", "Surgical ICU"))]
table1_data[, `In-hospital_death` := factor(`In-hospital_death`, levels = c(0, 1),
                                            labels = c("Survivor", "Died in-hospital"))]
table1 <- table1_data[, .(Age, Gender, ICUType, Height, Weight,
                          `SAPS-I`, SOFA, Length_of_stay, `In-hospital_death`)] |>
  gtsummary::tbl_summary(by = `In-hospital_death`, missing = "ifany")



fwrite(gtsummary::as_tibble(table1), file.path(out_dir, "table1.csv"))

#--------------------------------------------------------------------
# 2.) Outcome summary  

outcome_summary <- outcomes[, .(
  n = .N,
  n_died = sum(`In-hospital_death` == 1),
  pct_died = 100 * mean(`In-hospital_death` == 1),
  median_LOS = median(Length_of_stay, na.rm = TRUE),
  median_SAPS = median(`SAPS-I`, na.rm = TRUE),
  median_SOFA = median(SOFA, na.rm = TRUE)
)]

fwrite(outcome_summary, file.path(out_dir, "outcomes.csv"))
outcome_summary

#--------------------------------------------------------

#4.) Missingness as signal

wide[, died := `In-hospital_death` == 1]

count_cols <- grep("_count$", names(wide), value = TRUE)

missingness_vs_death <- rbindlist(lapply(count_cols, function(col) {
  measured <- wide[[col]] > 0 & !is.na(wide[[col]])
  data.table(
    Parameter = sub("_count$", "", col),
    pct_measured_among_died = 100 * mean(measured[wide$died]),
    pct_measured_among_survived = 100 * mean(measured[!wide$died])
  )
}))
missingness_vs_death


missingness_vs_death[, diff_died_minus_survived := pct_measured_among_died - pct_measured_among_survived]
setorder(missingness_vs_death, -diff_died_minus_survived)

fwrite(missingness_vs_death, file.path(out_dir, "missingness_vs_death.csv"))

fwrite(missingness_vs_death, file.path(out_dir, "missingness_vs_death.csv"))
missingness_vs_death[order(-(pct_measured_among_died - pct_measured_among_survived))]

#--------------------------------------------------------


# 1. Table 1                 -> output/table1.csv  (or .html from gtsummary)
# 2. Outcome summary         -> output/outcomes.csv
# 3. Missingness map         -> output/missingness_map.png
# 4. Missingness as signal   -> output/missingness_vs_death.csv
# ...

message("Checkpoint 1 complete. See output/.")
