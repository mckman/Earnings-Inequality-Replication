*03.03.CPS_attach_earn.sas;
*K. McKinney 20150909;
/* Attached UI earnings information to the CPS */

*** DATASETS ***;
/*
INPUTS:  CPSACS.pik_year_01
OUTPUTS: CPSACS.cps_person_02
*/

%include "config.sas";
%include "/rdcprojects/co/co00538/programs/projects/auxiliary/macro_cpi.sas";
*options obs=1000;

*** CPS identifiers with PIK ***;
data work.pik_cps(keep=pik year ph_seq ppposold) /view=work.pik_cps;
   set CPSACS.pik_year_01(keep=pik year npik_cps_yr ph_seq ppposold);

   if npik_cps_yr>0 then output;
run;

data work.earn(drop=_merge) work.check(keep=_merge);
   merge work.pik_cps(in=a) CPSACS.earn_cps_02(in=b);
      by pik year;

   length _merge 3;
   _merge=a+2*b;

   if first.year then output check;
   if _merge=3 then output earn;
run;

proc contents data=work.earn;
run;
proc tabulate data=work.check;
   class _merge /missing;
   table _merge all='Total', n*f=comma14.0 pctn;
run;

proc sort data=work.earn out=work.earn2;
   by year ph_seq ppposold pik;
run;

proc print data=work.earn2(obs=100);
run;

data CPSACS.cps_person_02(drop=_merge) work.check(keep=year _merge);
   merge CPSACS.cps_person_01(in=a) work.earn2(in=b);
      by year ph_seq ppposold pik;

   length _merge earn_found earn_pos_cps earn_pos_ui 3 wsal_diff 8;
   _merge=a+2*b;

   earn_found=(_merge=3);
   label earn_found="Earnings found on UI";

   if wsal_val>0 and earn_yr>0 then wsal_diff=wsal_val-earn_yr;

   /* Real earnings macro */
   %xcpi; *reference year is (refyr);

   if wsal_val>0 then wsal_real=round(wsal_val*(xcpi{&refyr.}/xcpi{year}));
   if pearnval>0 then pearn_real=round(pearnval*(xcpi{&refyr.}/xcpi{year}));
   if ptotval>0 then ptot_real=round(ptotval*(xcpi{&refyr.}/xcpi{year}));
   if earn_yr>0 then earn_yr_real=round(earn_yr*(xcpi{&refyr.}/xcpi{year}));
   earn_pos_cps=wsal_val>0;
   earn_pos_ui=earn_yr>0;

   label wsal_real="CPS Annual Real 2000 Earnings"
         wsal_diff="CPS earnings - UI earnings"
         pearn_real="CPS Annual Real 2000 Earnings"
         ptot_real="CPS Annual Real 2000 Income"
         earn_yr_real="UI Annual Real 2000 Earnings"
         earn_pos_cps="CPS Positive Earnings"
         earn_pos_ui="UI Positive Earnings";

   if a=1 then output CPSACS.cps_person_02;
   output work.check;
run;

proc contents data=CPSACS.cps_person_02;
run;
options nolabel;
proc tabulate data=work.check;
   class year _merge /missing;
   table _merge all='Total', n*f=comma14.0 pctn;
   table year*(_merge all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<_merge all> pctn;
run;
proc tabulate data=CPSACS.cps_person_02;
   class year earn_found pik_found earn_pos_cps earn_pos_ui /missing;
   table year all='Total', n*f=comma14.0 pctn;
   table year*(earn_found all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<earn_found all> pctn;
   table pik_found*(earn_found all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<earn_found all> pctn;
   table earn_pos_cps*(earn_pos_ui all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<earn_pos_ui all> pctn;
run;
proc means data=CPSACS.cps_person_02 n p5 p10 p25 median p75 p90 p95;
   class year;
   var earn_pos_cps earn_pos_ui wsal_val semp_val frse_val ptotval pearnval pothval wsal_real earn_yr_real earn_yr earn_yr_avg earn_yr_med wsal_diff;
run;
proc means data=CPSACS.cps_person_02(where=(earn_found=1)) n p5 p10 p25 median p75 p90 p95;
   class year;
   var earn_pos_cps earn_pos_ui wsal_val semp_val frse_val ptotval pearnval pothval wsal_real earn_yr_real earn_yr earn_yr_avg earn_yr_med wsal_diff;
run;
options obs=100;
proc print data=CPSACS.cps_person_02;
   var year ph_seq ppposold wsal_val wsal_real pearnval pearn_real ptotval ptot_real earn_yr earn_yr_real;
run;
proc print data=CPSACS.cps_person_02(where=(year=2003 and earn_found=1));
   var year ph_seq ppposold pik hg_fips max_st_fips wsal_val earn_yr earn_yr_med;
run;
