1.) What information exists at prediction time 
(the 48-hour window).


The only information collected/existing at prediction time
are: Age, Gender, Height, ICUType, 
admission Weight and any time-series readings 
between 0 and 48 hours. 



2.) Table 1 and outcome summary, with two or three sentences 
each.


Table 1: This table describes our 4000 participants, the median age
of those who survived is 66 (51, 78) those who died median 74 
(60, 83). Older patients were sicker at baseline and 
medical ICU patients had about 19% mortality and made
up half of all deaths.Also, gender height and weight are similar 
between groups.




Outcome Summary: The median length of stay is 10 days and
554 out of 4000 patients  died in hospital (outcome only 
counts only deaths in hospital). There is imbalance,
more patients survived than died and moderately ill on 
admission (median SAPS-I 15, median SOFA 7).





3.) Missingness: which variables, for whom, and whether it is
plausibly informative. Reference the map and the 
missingness-versus-death table.

missingness_map.png shows 3 tiers, variables that are always 
meaured, often measured and rarely meaured.
This map shows that variables like routine labs are always
measured. It also seems that those that come from the same tests 
look missing at the same time 
missingness_by_icutype.png shows that missingness 
depends strongly on ICU type

3 Patients have no time series measurements
missingness_maplongHeat.png shows the percentage of patients 
who had at least one recorded value for each variable 
during each hour

missingness is due to clinical setting

missingness_vs_death.csv compares the percent of patients 
with at least one measurement among those who died it is 
plausibly informative. 

Followed the skeleton shell for set-a_long.csv and set-a_wide.csv.
For set-a_long.csv the skeleton general descriptors and all 
Weight rows are excluded. After admissions all repeated weight 
measurements aren't in our long tablr but can be for modeling.
We looked at the max and min of each variable, and found two
measurements that cant be physiological. pH reaches 735 and 
Temp reaches −17.8. There were also some extreme but 
possible values that we left untouched (large urine outputs,
BP=0, ALT/AST in the thousands)
We set values outside of ranges to NA 
(pH outside 6.5–8.0, Temp outside 25–43 °C), 
 with any remaining -1 codes, this is applied 
 to set-a_long_clean.csv
 
 The wide dataset was derived from set-a_long.csv as instructed,
 not the clean set.





4.) AI-use statement: tool, what for, how verified.

I used Claude-Anthropic. I used AI to refresh , myself on 
pushing my work on github. I used claude to compared my 
checkpoint script against submission instructions. Some 
part of code claude helped me write and edit. I found with 
claudes's help in my wide  dataset 3 participants were
dropped, -1 missing codes in my outcome that effected Table 1 
slightly, and i saved plots but it could create an issue if
the grader ran it. I used claude to help troubleshoot issues I
ran into also. To verify i made the edit myself and read each 
suggestion, and compared everything to my own work/interpretation
I also ignored the extra things it offered that was beyond my 
scope of understanding. With the changes i agreed with i edited 
ran the entire script with pixi run --locked 
checkpoint1 and made sure all correct output was in its 
folder. And i confirmed
the git status often.

