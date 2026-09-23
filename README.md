# BIOSTAT-707

Repo for programming projects for BIOSTAT 707

Checpoint 1:

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
