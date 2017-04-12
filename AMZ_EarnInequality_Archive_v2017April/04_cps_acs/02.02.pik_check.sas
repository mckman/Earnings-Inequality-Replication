*02.02.pik_check.sas;
*K. McKinney 20150908;
/* Create a PIK YEAR level file that contains stats for every PIK that appears on the CPS and/or the ACS */
/* REMOVE any duplicate survery IDs for PIKS within a year */

*** DATASETS ***;
/*
INPUTS:  CPSACS.cps_person_01
         CPSACS.acs_person_01
OUTPUTS: CPSACS.pik_year_01
*/

%include "config.sas";
*options obs=1000;

*** Get the list of PIKs from the CPS ***;
proc sort data=CPSACS.cps_person_01(keep=pik year ph_seq ppposold where=(pik~=" ")) out=work.cps;
   by pik year;
run;

*** Count number of times a PIK shows up each year in CPS ***;
data work.pikcpsyr;
   set work.cps;
      by pik year;

   length npik_cps_yr 8;
   label npik_cps_yr = "Number of times PIK appears in each year of CPS";
   retain npik_cps_yr;

   if first.year then npik_cps_yr=0;

   npik_cps_yr=npik_cps_yr+1;

   if last.year then output;
run;

proc contents data=work.pikcpsyr;
run;
proc tabulate data=work.pikcpsyr;
   class year npik_cps_yr /missing;
   table npik_cps_yr all='Total', n*f=comma14.0 pctn;
   table year*(npik_cps_yr all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<npik_cps_yr all> pctn;
run;
proc print data=work.pikcpsyr(obs=25);
run;

*** Count number of times a PIK ever shows up in CPS ***;
data work.pikcps(drop=year ph_seq ppposold);
   set work.cps;
      by pik;

   length npik_cps 8;
   label npik_cps = "Number of times PIK appears in all CPS years (&CPSstart.-&CPSend.)";
   retain npik_cps;

   if first.pik then npik_cps=0;

   npik_cps=npik_cps+1;

   if last.pik then output;
run;

proc contents data=work.pikcps;
run;
proc tabulate data=work.pikcps;
   class npik_cps /missing;
   table npik_cps all='Total', n*f=comma14.0 pctn;
run;
proc print data=work.pikcps(obs=25);
run;

*** Get the list of PIKs from the ACS ***;
proc sort data=CPSACS.acs_person_01(keep=pik year cmid pnum rdate where=(pik~=" ")) out=work.acs;
   by pik year;
run;
/* NOTE: MULTIPLE CMID PNUM FOR EACH PIK YEAR */

*** Count number of times a PIK shows up each year in ACS ***;
data work.pikacsyr;
   set work.acs;
      by pik year;

   length npik_acs_yr 8;
   label npik_acs_yr = "Number of times PIK appears in each year of ACS";
   retain npik_acs_yr;

   if first.year then npik_acs_yr=0;

   npik_acs_yr=npik_acs_yr+1;

   if last.year then output; /* DUPLICATE REMOVAL HAPPENS HERE */
run;

proc contents data=work.pikacsyr;
run;
proc tabulate data=work.pikacsyr;
   class year npik_acs_yr /missing;
   table npik_acs_yr all='Total', n*f=comma14.0 pctn;
   table year*(npik_acs_yr all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<npik_acs_yr all> pctn;
run;
proc print data=work.pikacsyr(obs=25);
run;

*** Count number of times a PIK ever shows up in ACS ***;
data work.pikacs(drop=year cmid pnum rdate);
   set work.acs;
      by pik;

   length npik_acs 8;
   label npik_acs = "Number of times PIK appeaks in all ACS years (&ACSstart.-&ACSend.)";
   retain npik_acs;

   if first.pik then npik_acs=0;

   npik_acs=npik_acs+1;

   if last.pik then output;
run;

proc contents data=work.pikacs;
run;
proc tabulate data=work.pikacs;
   class npik_acs /missing;
   table npik_acs all='Total', n*f=comma14.0 pctn;
run;
proc print data=work.pikacs(obs=25);
run;

*** Put everything together ***;
data work.cpsacs_yr;
   merge work.pikcpsyr(in=a) work.pikacsyr(in=b);
      by pik year;

   length _merge 3;
   _merge=a+2*b;
run;

proc contents data=work.cpsacs_yr;
run;
proc tabulate data=work.cpsacs_yr;
   class _merge /missing;
   table _merge all='Total', n*f=comma14.0 pctn;
run;


data work.cpsacs;
   merge work.pikcps(in=a) work.pikacs(in=b);
      by pik;

   length _merge 3;
   _merge=a+2*b;
run;

proc contents data=work.cpsacs;
run;
proc tabulate data=work.cpsacs;
   class _merge /missing;
   table _merge all='Total', n*f=comma14.0 pctn;
run;

data CPSACS.pik_year_01;
   merge work.cpsacs_yr(in=a drop=_merge) work.cpsacs(in=b drop=_merge);
      by pik;

   length merge_cps_acs_yr 3 acs_rdate_qtr 3 npik_cps_acs_yr npik_cps_acs 8;
   label
      merge_cps_acs_yr = "Check that each PIK gets a count"
      acs_rdate_qtr = "Quarter ACS interview was conducted"
      npik_cps_acs_yr = "Total number of times PIK shows up in each year of CPS or ACS"
      npik_cps_acs = "Total number of times PIK shows up in all years of CPS or ACS"
   ;

   merge_cps_acs_yr=a+2*b;

   if npik_cps_yr=. then npik_cps_yr=0;
   if npik_acs_yr=. then npik_acs_yr=0;
   if npik_cps=. then npik_cps=0;
   if npik_acs=. then npik_acs=0;

   npik_cps_acs_yr=npik_cps_yr+npik_acs_yr;
   npik_cps_acs=npik_cps+npik_acs;

   if rdate~=. then acs_rdate_qtr=qtr(rdate);
run;

proc contents data=CPSACS.pik_year_01;
run;
proc tabulate data=CPSACS.pik_year_01;
   class merge_cps_acs_yr year npik_cps_acs_yr npik_cps_acs acs_rdate_qtr /missing;
   table merge_cps_acs_yr all='Total', n*f=comma14.0 pctn;
   table npik_cps_acs all='Total', n*f=comma14.0 pctn;
   table npik_cps_acs_yr all='Total', n*f=comma14.0 pctn;
   table year*(npik_cps_acs_yr all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<npik_cps_acs_yr all> pctn;
   table year*(acs_rdate_qtr all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<acs_rdate_qtr all> pctn;
run;
proc print data=CPSACS.pik_year_01(obs=100);
run;

proc sort data=CPSACS.pik_year_01(keep=pik npik_cps npik_acs npik_cps_acs) out=work.tab1 nodupkey;
   by pik;
run;

proc tabulate data=work.tab1;
   class npik_cps npik_acs npik_cps_acs /missing;
   table npik_cps all='Total', n*f=comma14.0 pctn;
   table npik_acs all='Total', n*f=comma14.0 pctn;
   table npik_cps*(npik_acs all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<npik_acs all> pctn;
   table npik_cps_acs all='Total', n*f=comma14.0 pctn;
run;
proc print data=work.tab1(where=(npik_cps_acs>5));
run;
