README_cps_acs.txt
N. Zhao 20160302
Notes for the programs in this sequence

*** 00.01_CPS_ACS_contents.sas ***
INPUTS:  CPS and ACS microdata and crosswalks
OUTPUTS: none
	1. proc contents of both CPS and ACS data and xwalk files

*** 01.01_CPS_vars.sas ***
INPUTS:  CPS microdata and crosswalks
OUTPUTS: CPSACS.cps_person_01
	1. get person counts for each hhld and family
	2. incorporate hhld and family characteristics to person file
	3. stack the enhanced yearly person files
	4. merge PIKs to stacked person file

*** 01.02_ACS_vars.sas ***
INPUTS:  ACS microdata and crosswalks
OUTPUTS: CPSACS.acs_person_01
	1. stack yearly data and xwalk files (note reformat in 2008)
	2. merge PIKs to stacked person file

*** 02.01.merge_ui.sas ***
INPUTS:  CPSACS.cps_person_01
         CPSACS.acs_person_01
         UI earnings from all states and opm
OUTPUTS: CPSACS.ehf_01
	1. create EHF strip of all PIKs found in CPS/ACS
	NOTE: keep all year-quarter observations for these PIKs

*** 02.02.pik_check.sas ***
INPUTS:  CPSACS.cps_person_01
         CPSACS.acs_person_01
OUTPUTS: CPSACS.pik_year_01
	1. Counts of the number of times a PIK shows up in a survey year of CPS/ACS
	2. Counts of the number of times a PIK shows up in any survey year of CPS/ACS 
	NOTES:
	   CPS: PIK matches to one CPS person in any survey year of CPS
	   ACS: most PIK matches to one ACS person, some PIKs match to more than one ACS person in a survey year 

*** 03.01.CPS_earn.sas ***
UI earnings history (quarterly) for all the PIKs in CPS

*** 03.02.CPS_esum.sas ***
Creates annual earnings for PIKs that match to CPS records
Calculate what state had max earnings for that year and the percentage of annual earnings

*** 03.03.CPS_attach_earn.sas ***
UI earnings for CPS records

*** 04.01.ACS_earn.sas ***
UI earnings history (quarterly) for all the PIKs in ACS

*** 04.02.ACS_esum.sas ***
Create annual earnings for PIKs that match to ACS record

*** 04.03.ACS_attach_earn.sas ***
UI earnings for ACS records


*** 01.01.cps_acs_pik.sas ***;
Tabulations of PIK counts after merging them to CPS/ACS records through the crosswalk
	1. Number of times PIK-year matches to CPS/ACS-year record
	2. Number of times PIK matches to CPS/ACS record

*** 02.01.cps_acs_ehf.sas ***;
See program for exact file I used from Kevin's sequence as the input file
Extract EHF records for the PIKs in CPS/ACS 
Turn the quarterly file into a yearly file with quarterly earnings saved wide 
Aggregate to yearly level - keep total and dominant earnings each quarter

*** 02.02.cps_acs_ui_lag0_lag1.sas ***;
Merge last year's earnings to file

*** 02.03.cps_acs_ui_avg.sas ***;
NOTHING FOR NOW

*** 02.04.cps_acs_duplicates.sas ***;
The number of unique PIKs per year 
List of duplicate PIKs
	NOTE: PIK-year uniquely matches to CPS record, but not to ACS records

*** 03.01.merge_to_microdata.sas ***;
Merge EHF extract to CPS/ACS microdata

*** 03.02.person_characteristics.sas ***;
Tabulates of age, employment status, hhld type, and class of worker

*** 04.01.CPS_UI_compare.sas ***;
Compare when CPS earnings and UI earnings are positive

*** 04.02.CPS_eligible_workers.sas ***;
NOTHING FOR NOW

*** 05.01.ACS_UI_compare.sas ***;
Compare when ACS earnings and UI earnings are positive

*** 05.02a.ACS_UI_2005_2013.sas ***;
Keep only observations from 2005 to 2013
Tabulate comparison of when ACS earnings and when UI earnings are positive
WAG looks better than PERN
SEE TABULATION BELOW

*** 05.02b.ACS_UI_2005_2013_cow.sas ***;
Same as 05.02a but for covered workers (see program for definition)
SEE TABULATION BELOW

*** 05.03.ACS_UI_WAG.sas ***;
Tabulation of 05.02a by year to see if the pattern is consistent over time

*** 05.04.ACS_UI_earnings.sas ***;
Construct annual earnings that best mimics what individual would have reported in ACS 
	nellie: last four quarters that covers most of the calendar year from report month
	kevin: current quarter of report month and last three quarters
Compare ACS earnings and nellie/kevin earnings - both all workers and covered workers

*** 05.05.ACS_UI_kevin_check.sas ***;
*** 05.06.ACS_UI_earn_diff.sas ***;


/*
GQ (group quarters)
0 Not General Quarters
1 General Quarters

ESR
1 Employed at work
2 Employed with a job but not at work
3 Unemployed
4 Armed Forces, at work
5 Armder Forces, with a job but not at work
6 Not in labor force

COW
1 Private for profit
2 Private not for profit
3 Local Gov
4 State Gov
5 Federal Gov
6 SE Incorportated
7 SE Not Incorporated
8 Work without pay - family
9 Unemployed
*/
