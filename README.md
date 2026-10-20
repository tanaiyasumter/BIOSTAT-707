# BIOSTAT-707

Repo for programming projects for BIOSTAT 707

Checkpoint 1:

This is a cohort characterization and EDA on PhysioNet 
Challenge 2012 set-a. Install pixi, cloned this repo and 
run pixi install to set up R environment.
Download set-a.zip and Outcomes-a.txt from 
https://physionet.org, unzip and place them in data/ folder. 
set-a contains the 4000 record files.
Entire script can be ran as is ( select all and run in R),
must run pixi run --locked checkpoint1
and 
output folder contains: set-a_long.csv, set-a_long_clean.csv,
set-a_wide.csv, outcome summary: outcomes.csv, 
Table 1: table1.csv, missingness-versus-death table: 
missingness_vs_death.csv., missingness_by_icutype.png, 
missingness figures: missingness_map_longGraph.png,
missingness_map_wide.png, missingness_map.png,
missingness_maplongHeat.png.
Interpretation, data-cleaning reasoning/thinking, 
what information exists at prediction time 
(the 48-hour window), missingness, and the required disclosure of AI tool use will be in the checkpoint1_writeup.md.



# BIOSTAT 707: Checkpoint 2 

Checkpoint 1 interpretation is in checkpoint1_writeup.md. Checkpoint 2's
report is output/checkpoint2.html.
Recall, Checkpoint 1 characterizes the 4,000 ICU stays in set-a.
Checkpoint 2 builds predictors from the first 0- 48 hours. It compares a LASSO logistic regression, a GAM and a random forest with 5-fold cross-validation, against the SAPS-I and SOFA severity scores.

## Setup
1. Install pixi
2. Clone this repo and cd into it.
3. Download set-a.zip and Outcomes-a.txt from the
   PhysioNet Challenge 2012 page (https://physionet.org/content/challenge-2012 /1.0.0/)
   and place them so the repo contains `data/set-a/<RecordID>.txt` (4000 files)
   and data/Outcomes-a.txt. data/ is gitignored and read-only.

Run each checkpoint from the repo root:

pixi run --locked checkpoint1
pixi run --locked checkpoint2

Checkpoint 1: runs checkpoint1.R and takes about 16 seconds. In Powershell
Checkpoint 2: renders checkpoint2.qmd. It runs checkpoint1.R first (through
 source()) and then builds the modeling table and fits the three models with
  5-fold cross-validation. It takes about 10 minutes on my laptop, measured with the Render button
  ( Windows 11)

## Output
Checkpoint 1: set-a_long.csv, set-a_long_clean.csv, set-a_wide.csv,
  table1.csv, outcomes.csv, missingness_vs_death.csv, and the figures
  missingness_map.png, missingness_map_wide.png, missingness_map_longGraph.png,
  missingness_maplongHeat.png, missingness_by_icutype.png.
Checkpoint 2: the report checkpoint2.html, the final fitted model
 cp2_final_model.rds, and the out-of-fold predictions cp2_oof_predictions.csv.

**Checkpoint 2:** the report checkpoint2.html, the final fitted model cp2_final_model.rds, and the out-of-fold predictions cp2_oof_predictions.csv.

Only output/checkpoint2.html is committed. Other files are regenerated on every run.

##Known Issue
On my Windows laptop, pixi run --locked checkpoint2 fails when R loads library(tidymodels) with a "Mingw-w64 runtime failure: 32 bit pseudo relocation ... out of range" error. I reported this to Dr. Rozen and sent the repo so it can be reproduced. I did not change pixi.toml or pixi.lock. The committed output/checkpoint2.html was rendered in RStudio instead.



