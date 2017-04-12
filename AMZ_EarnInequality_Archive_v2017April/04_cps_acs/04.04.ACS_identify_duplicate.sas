*04.04.ACS_identify_duplicates.sas;
*N. Zhao 20160303;
/* Identify the ACS records that share a PIK (duplicates) */
/* NOTE: This is not a problem for CPS */

*** DATASETS ***;
/*
INPUTS:  CPSACS.acs_person_02
OUTPUTS: CPSACS.acs_person_02_dup
*/

%include "config.sas";
*options obs=1000000;

*** Sort by year PIK ***;
proc sort data=CPSACS.acs_person_02 out=work.acs_person_02;
	by year pik;
run;

*** Identify duplicates ***;
data CPSACS.acs_person_02_dup;
	merge work.acs_person_02(in=_a_)
	      CPSACS.acs_duplicates(in=_b_);
	by year pik;

	length dup_pik 3;
	label dup_pik = "PIK that matches to multiple ACS records";

	_merge_ = _a_+2*_b_;

	dup_pik = 0;
	if _b_ then dup_pik = 1;
run;

proc print data=CPSACS.acs_person_02_dup(where=(dup_pik=1 and year=2001));
	var year CMID PNUM pik dup_pik WAG earn_yr;
run;

proc tabulate data=CPSACS.acs_person_02_dup;
   class _merge_ / missing;
   table _merge_ all='Total', n*f=comma14.0 pctn;
run;

proc sort data=CPSACS.acs_person_02_dup(drop=_merge_);
	by year CMID PNUM pik;
run;

proc contents data=CPSACS.acs_person_02_dup;
run;

options nolabel;
proc tabulate data=CPSACS.acs_person_02_dup;
   class year dup_pik /missing;
   table dup_pik all='Total', n*f=comma14.0 pctn;
   table year*(dup_pik all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<dup_pik all> pctn;
run;
