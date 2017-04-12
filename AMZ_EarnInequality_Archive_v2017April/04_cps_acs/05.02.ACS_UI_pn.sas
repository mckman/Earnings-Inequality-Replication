*05.02.ACS_UI_pn.sas;
*N. Zhao 20160302;
/* Check for patterns for obs where ACS>0 but UI=0 */

*** DATASETS ***;
/*
INPUTS:  CPSACS.acs_person_03
OUTPUTS: none
*/

%include "config.sas";

title2 "#### 2005-2013: COMPARE WAG and earn_yr - some positive earnings ####";
proc freq data=CPSACS.acs_person_03(where=((earn_pos_acs=1 or earn_pos_ui=1) and (year>=2005 and year<=2013))) noprint;
	tables earn_pos_acs*earn_pos_ui / missing out=work.temp01;
run;
proc print data=work.temp01;
run;

*** All workers where ACS earning is positive but UI is zero ***;
data work.acs_ui_pn;
	set CPSACS.acs_person_03(where=(earn_pos_acs=1 and earn_pos_ui=0 and year>=2005 and year<=2013));
run;

title2 "~~~~ ALL WORKERS ~~~~";
proc freq data=work.acs_ui_pn;
	tables dup_pik work_us r_esr r_wag r_pern / missing;
run;

proc freq data=work.acs_ui_pn noprint;
	tables dup_pik*work_us*r_wag / missing out=work.temp02;
run;
proc sort data=work.temp02;
	by DESCENDING COUNT;
run;
data work.temp02;
	set work.temp02;
	retain total;
	if _n_ = 1 then total = 0;
	total = total + COUNT;
run;
proc print data=work.temp02;
run;
