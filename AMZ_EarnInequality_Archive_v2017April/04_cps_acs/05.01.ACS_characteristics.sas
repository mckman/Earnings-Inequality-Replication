*05.01.ACS_characteristics.sas;
*N. Zhao 20160302;
/* Create dummy variables for certain key variables */

*** DATASETS ***;
/*
INPUTS:  CPSACS.acs_person_02_dup
OUTPUTS: CPSACS.acs_person_03
*/

%include "config.sas";
*options obs=10000;

data CPSACS.acs_person_03(drop=ST_num POWS_num);
	set CPSACS.acs_person_02_dup;

	length
		ST_num POWS_num 3 
		state state_work $2
		work_us work_same d_int d_oi d_pa d_ret d_sem d_ss d_ssi r_esr r_wag r_pern 3;
	
	label
		state = "State of residence"
		state_work = "State of employment"
		work_us = "Work in the US, 1=yes"
		work_same = "Place of work same, 1=yes"
		d_int = "Interest income, 1=yes"
		d_oi = "Other income, 1=yes"
		d_pa = "Welfare income, 1=yes"
		d_ret = "Retirement income, 1=yes"
		d_sem = "Self-employment income, 1=yes"
		d_ss = "Social Security income, 1=yes"
		d_ssi = "Supplemental security income, 1=yes"
		r_esr = "Employment status reported, 1=yes"
		r_wag = "Wage/salary reported, 1=yes"
		r_pern = "Earnings reported, 1=yes"
	;
	

	/* Turn location codes into numbers */
	ST_num = input(ST,3.);
	POWS_num = input(POWS,3.);

	/* State */
	state = fipstate(ST_num);

	/* Works in US */
	work_us = 0;
	if POWS_num ~= . and POWS_num < 60 then do;
		work_us = 1;
		state_work = fipstate(POWS_num);
	end;
	
	/* Same place of work */
	work_same = 0;
	if earn_yr > 0 then do;
		if state_work = fipstate(input(max_st_fips,3.)) then work_same = 1;
	end;

	/* Income */
	d_int = 0;
	if INT > 0 then d_int = 1;

	d_oi = 0;
	if OI > 0  then d_oi = 1;

	d_pa = 0;
	if PA > 0 then d_pa = 1;

	d_ret = 0;
	if RET > 0 then d_ret = 1;

	d_sem = 0;
	if SEM > 0 then d_SEM = 1;

	d_ss = 0;
	if SS > 0 then d_SS = 1;

	d_ssi = 0;
	if SSI > 0 then d_SSI = 1;

	/* Allocation flags - REPORTED */
	r_esr = 0;
	if FESR = "00" then r_esr = 1;

	r_wag = 0;
	if FWAG = "00" then r_wag = 1;

	r_pern = 0;
	if FPERNPCT = 0 then r_pern = 1;
run;

proc contents data=CPSACS.acs_person_03;
run;

title2 "#### COMPARE WAG and earn_yr ####";
proc freq data=CPSACS.acs_person_03 noprint;
	tables earn_pos_acs*earn_pos_ui / missing out=work.temp01;
run;
proc print data=work.temp01;
run;

title2 "#### COMPARE WAG and earn_yr - some positive earnings ####";
proc freq data=CPSACS.acs_person_03(where=((earn_pos_acs = 1 or earn_pos_ui = 1))) noprint;
	tables earn_pos_acs*earn_pos_ui / missing out=work.temp02;
run;
data work.temp02;
	set work.temp02;
	retain total;
	if _n_ = 1 then total = 0;
	total = total + COUNT;
run;
proc print data=work.temp02;
run;

title2 "#### 2005-2013: COMPARE WAG and earn_yr ####";
proc freq data=CPSACS.acs_person_03(where=(year>=2005 and year<=2013)) noprint;
	tables earn_pos_acs*earn_pos_ui / missing out=work.temp03;
run;
proc print data=work.temp03;
run;

title2 "#### 2005-2013: COMPARE WAG and earn_yr - some positive earnings ####";
proc freq data=CPSACS.acs_person_03(where=((earn_pos_acs = 1 or earn_pos_ui = 1) and (year>=2005 and year<=2013))) noprint;
	tables earn_pos_acs*earn_pos_ui / missing out=work.temp04;
run;
data work.temp04;
	set work.temp04;
	retain total;
	if _n_ = 1 then total = 0;
	total = total + COUNT;
run;
proc print data=work.temp04;
run;

title2 "#### 2005-2013 (year_tab): COMPARE WAG and earn_yr ####";
proc freq data=CPSACS.acs_person_03(where=(year_tab>=2005 and year_tab<=2013)) noprint;
	tables earn_pos_acs*earn_pos_ui / missing out=work.temp05;
run;
proc print data=work.temp05;
run;

title2 "#### 2005-2013 (year_tab): COMPARE WAG and earn_yr - some positive earnings ####";
proc freq data=CPSACS.acs_person_03(where=((earn_pos_acs = 1 or earn_pos_ui = 1) and (year_tab>=2005 and year_tab<=2013))) noprint;
	tables earn_pos_acs*earn_pos_ui / missing out=work.temp06;
run;
data work.temp06;
	set work.temp06;
	retain total;
	if _n_ = 1 then total = 0;
	total = total + COUNT;
run;
proc print data=work.temp06;
run;

title2 "#### ALL WORKERS ####";
proc freq data=CPSACS.acs_person_03;
	tables work_us state_work work_same d_int d_oi d_pa d_ret d_sem d_ss d_ssi r_esr r_wag r_pern / missing;
run;
