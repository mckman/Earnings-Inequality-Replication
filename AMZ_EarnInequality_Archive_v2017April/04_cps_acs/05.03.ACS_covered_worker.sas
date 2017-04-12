*05.03.ACS_covered_worker.sas;
*N. Zhao 20160303;
/* Different definitions of covered workers ***;

*** DATASETS ***;
/*
INPUTS:  CPSACS.acs_person_03
OUTPUTS: none
*/

%include "config.sas";
options ls=250;


data work.covered01;
	set CPSACS.acs_person_03;
	
	wag_adiff = abs(wag_diff);
	avg_adiff = abs(WAG-earn_yr_avg);
	if WAG>0 then wag_pdiff = (WAG-earn_yr)/WAG;
	if WAG>0 then wag_padiff = wag_adiff/WAG;
	if WAG>0 then avg_padiff = avg_adiff/WAG;
	
	if (year>=2005 and year<=2013) and (WAG>0) and (GQ="0") and (esr in("1", "2")) and (cow in("1", "2", "3", "4", "5", "7")) and (age>17 and age<71) then output;
run;

title2 "#### 2005-2013: COVERED WORKERS ####";
proc freq data=work.covered01;
	tables work_same / missing;
run;
proc freq data=work.covered01 noprint;
	tables earn_pos_acs*earn_pos_ui / missing out=work.temp01;
run;
proc print data=work.temp01;
run;

proc means data=work.covered01 nolabels n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 p99 max;
	class year;
	var WAG earn_yr earn_yr_avg wag_diff wag_pdiff wag_adiff wag_padiff avg_adiff avg_padiff;
run;






data work.covered02;
	set CPSACS.acs_person_03;
	
	wag_adiff = abs(wag_diff);
	avg_adiff = abs(WAG-earn_yr_avg);
	if WAG>0 then wag_pdiff = (WAG-earn_yr)/WAG;
	if WAG>0 then wag_padiff = wag_adiff/WAG;
	if WAG>0 then avg_padiff = avg_adiff/WAG;
	
	if (year>=2005 and year<=2013) and (WAG>0) and (GQ="0") and (esr in("1", "2")) and (cow in("1", "2", "3", "4", "5", "7")) and (age>17 and age<71) and (dup_pik=0) and (work_us=1) then output;
run;

title2 "#### 2005-2013: COVERED WORKERS (POW RESTRICTION) ####";
proc freq data=work.covered02;
	tables work_same r_wag / missing;
run;
proc freq data=work.covered02 noprint;
	tables earn_pos_acs*earn_pos_ui / missing out=work.temp02;
run;
proc print data=work.temp02;
run;

proc means data=work.covered02 nolabels n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 p99 max;
	class year;
	var WAG earn_yr earn_yr_avg wag_diff wag_pdiff wag_adiff wag_padiff avg_adiff avg_padiff;
run;










data work.covered03;
	set CPSACS.acs_person_03;
	
	wag_adiff = abs(wag_diff);
	avg_adiff = abs(WAG-earn_yr_avg);
	if WAG>0 then wag_pdiff = (WAG-earn_yr)/WAG;
	if WAG>0 then wag_padiff = wag_adiff/WAG;
	if WAG>0 then avg_padiff = avg_adiff/WAG;
	
	if (year>=2005 and year<=2013) and (WAG>0) and (GQ="0") and (esr in("1", "2")) and (cow in("1", "2", "3", "4", "5", "7")) and (age>17 and age<71) and (dup_pik=0) and (work_us=1) and (r_wag=1) then output;
run;

title2 "#### 2005-2013: COVERED WORKERS (POW AND REPORTED EARNINGS RESTRICTION) ####";
proc freq data=work.covered03;
	tables work_same r_wag / missing;
run;
proc freq data=work.covered03 noprint;
	tables earn_pos_acs*earn_pos_ui / missing out=work.temp03;
run;
proc print data=work.temp03;
run;

proc means data=work.covered03 nolabels n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 p99 max;
	class year;
	var WAG earn_yr earn_yr_avg wag_diff wag_pdiff wag_adiff wag_padiff avg_adiff avg_padiff;
run;