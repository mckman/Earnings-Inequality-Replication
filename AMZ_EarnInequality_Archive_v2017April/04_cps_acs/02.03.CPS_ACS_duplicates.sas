*02.03.CPS_ACS_duplicates.sas;
*N. Zhao 20160303;
/* PIK-YRs that match to more than one CPS or ACS record */

*** DATASETS ***;
/*
INPUTS:  CPSACS.cps_person_01
         CPSACS.acs_person_01
OUTPUTS: CPSACS.cps_duplicates
         CPSACS.acs_duplicates
*/

%include "config.sas";
*options obs=1000;

*** CPS - DUPLICATES ***;
proc sort data=CPSACS.cps_person_01(keep=pik year where=(pik~=" ")) out=work.cps_unique dupout=work.cps_duplicates nodupkey;
	by pik year;
run;

title2 "#### CPS - PIKs PER YEAR ####";
proc freq data=work.cps_unique noprint;
	tables year / out=work.cps_pik_count;
run;
proc print data=work.cps_pik_count;
run;

title2 "#### CPS - DUPLICATES ####";
proc sort data=work.cps_duplicates out=CPSACS.cps_duplicates;
	by year pik;
run;
proc print data=CPSACS.cps_duplicates;
run;

*** ACS - DUPLICATES ***;
proc sort data=CPSACS.acs_person_01(keep=pik year where=(pik~=" ")) out=work.acs_unique dupout=work.acs_duplicates nodupkey;
	by pik year;
run;

title2 "#### ACS - PIKs PER YEAR ####";
proc freq data=work.acs_unique noprint;
	tables year / out=work.acs_pik_count;
run;
proc print data=work.acs_pik_count;
run;

title2 "#### ACS - DUPLICATES ####";
proc sort data=work.acs_duplicates out=CPSACS.acs_duplicates;
	by year pik;
run;
proc print data=CPSACS.acs_duplicates;
run;