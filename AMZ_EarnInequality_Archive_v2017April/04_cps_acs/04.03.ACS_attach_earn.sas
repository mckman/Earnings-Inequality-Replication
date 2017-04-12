*04.03.ACS_attach_earn.sas;
*K. McKinney 20150911;
/* Attached UI earnings information to the ACS */

*** DATASETS ***;
/*
INPUTS:  CPSACS.pik_year_01
OUTPUTS: CPSACS.acs_person_02
*/

%include "config.sas";
%include "macro_cpi.sas";
%include "macro_cpi_quarterly.sas";

*options obs=500000;

*** ACS identifiers ***;
data work.pik_acs(keep=pik year cmid pnum acs_rdate_qtr rename=(year=year_acs acs_rdate_qtr=quarter_acs)) /view=pik_acs;
   set CPSACS.pik_year_01(keep=pik year npik_acs_yr cmid pnum acs_rdate_qtr);

   if npik_acs_yr>0 then output;
run;

proc contents data=work.pik_acs;
run;

*** Personal history file ***;
data work.phf(keep=pik e1-e&qmax st1-st&qmax) /view=work.phf;
   set CPSACS.earn_acs_01;
      by pik;

   length st1-st&qmax $2;
   retain e1-e&qmax st1-st&qmax es1-es&qmax;

   array eq{1:&qmax} e1-e&qmax;
   array ss{1:&qmax} st1-st&qmax;
   array es{1:&qmax} es1-es&qmax;

   qt=(year-&UIstart)*4+quarter;

   if first.pik then do;
      do i=1 to &qmax;
         eq{i}=0;
         ss{i}=" ";
         es{i}=0;
      end;
   end;

   eq{qt}=eq{qt}+earn;

   if earn>es{qt} then do;
      es{qt}=earn;
      ss{qt}=source;
   end;

   if last.pik then output;   
run;

proc contents data=work.phf;
run;
proc print data=CPSACS.earn_acs_01(obs=50);
run;
proc print data=work.phf(obs=10);
	id pik;
run;

*** Create annual earnings measure that best matches ACS earnings ***;
data work.earn(drop=e1-e&qmax st1-st&qmax quarter_acs qt qtr1 qtr2 qtr3 yr1 yr2 yr3 _merge rename=(year_acs=year)) 
     work.check(keep=_merge);
   merge work.pik_acs(in=a) work.phf(in=b);
      by pik;

   array eq{1:&qmax} e1-e&qmax;
   array ss{1:&qmax} st1-st&qmax;

   length _merge 3 max_st_fips $2 earn_yr earn_yr_real 8;
   label
      max_st_fips = "State from which worker made most of his earnings"
      earn_yr = "Annual earnings"
      earn_yr_real = "Real annual earnings (&refyr. dollars)"
   ;
   _merge=a+2*b;

   /* Quarterly CPI array */
   %xcpiq;

   if _merge=3 then do;
      qt=(year_acs-&UIstart)*4+quarter_acs;
      earn_yr=eq{qt}+eq{qt-1}+eq{qt-2}+eq{qt-3};
      yr1=floor((qt-2)/4)+&UIstart; qtr1=qt-1-((yr1-&UIstart)*4);
      yr2=floor((qt-3)/4)+&UIstart; qtr2=qt-2-((yr2-&UIstart)*4);
      yr3=floor((qt-4)/4)+&UIstart; qtr3=qt-3-((yr3-&UIstart)*4);
      earn_yr_real=round(eq{qt}*(xcpiq(&refyr.,&refqtr.)/xcpiq{year_acs,quarter_acs})
                        +eq{qt-1}*(xcpiq(&refyr.,&refqtr.)/xcpiq{yr1,qtr1})
                        +eq{qt-2}*(xcpiq(&refyr.,&refqtr.)/xcpiq{yr2,qtr2})
                        +eq{qt-3}*(xcpiq(&refyr.,&refqtr.)/xcpiq{yr3,qtr3}));

      if ss{qt}~=" " then max_st_fips=ss{qt};
      else if max_st_fips=" " and ss{qt-1}~=" " then max_st_fips=ss{qt-1};
      else if max_st_fips=" " and ss{qt-2}~=" " then max_st_fips=ss{qt-2};
      else if max_st_fips=" " and ss{qt-3}~=" " then max_st_fips=ss{qt-3};

      output work.earn;
   end;
   if first.pik then output work.check;
run;

proc contents data=work.earn;
run;
proc tabulate data=work.check;
   class _merge /missing;
   table _merge all='Total', n*f=comma14.0 pctn;
run;

*** Merge annual earnings with UI earnings statistics ***;
data work.earn2(drop=_merge) work.check(keep=_merge);
   merge work.earn(in=a) CPSACS.earn_acs_02_pik(in=b);
      by pik;

   length _merge 3;
   _merge=a+2*b;

   output work.earn2;
   if first.pik then output work.check;
run;
proc contents data=work.earn2;
run;
proc tabulate data=work.check;
   class _merge /missing;
   table _merge all='Total', n*f=comma14.0 pctn;
run;
proc print data=work.earn2(obs=100);
run;

*** Merge UI earnings back to ACS microdata ***;
proc sort data=work.earn2 out=work.earn3;
   by year cmid pnum pik;
run;

data CPSACS.acs_person_02(drop=_merge) work.check(keep=year _merge);
   merge CPSACS.acs_person_01(in=a) work.earn3(in=b);
      by year cmid pnum pik;

   length _merge earn_found year_tab quarter earn_pos_acs earn_pos_ui 3 wag_diff wag_real pern_real 8;
   _merge=a+2*b;

   earn_found=(earn_yr>0);

   if WAG>0 and earn_yr>0 then wag_diff=WAG-earn_yr;

   quarter=qtr(rdate);
   
   if quarter<3 then year_tab=year-1;
   else year_tab=year;

   /* Real earnings macro */
   %xcpi; *reference year is (refyr);

   if WAG>0 then wag_real=round(WAG*(xcpi{&refyr.}/xcpi{year_tab}));
   if PERN>0 then pern_real=round(PERN*(xcpi{&refyr.}/xcpi{year_tab}));
   earn_pos_acs=WAG>0;
   earn_pos_ui=earn_yr>0;

   label earn_found="Earnings found on UI"
         year = "Year of ACS interview"
         year_tab="Year with most recall months"
         quarter="Quarter of ACS interview"
         wag_real="ACS Annual Real 2000 Earnings"
         wag_diff="ACS earnings - UI earnings"
         pern_real="ACS Annual Real 2000 Earnings"
         earn_yr_real="UI Annual Real 2000 Earnings"
         earn_pos_acs="ACS Positive Earnings"
         earn_pos_ui="UI Positive Earnings";

   if a=1 then output CPSACS.acs_person_02;
   output work.check;
run;

proc contents data=CPSACS.acs_person_02;
run;
options nolabel;
proc tabulate data=work.check;
   class year _merge /missing;
   table _merge all='Total', n*f=comma14.0 pctn;
   table year*(_merge all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<_merge all> pctn;
run;
proc tabulate data=CPSACS.acs_person_02;
   class year earn_found pik_found earn_pos_acs earn_pos_ui /missing;
   table year all='Total', n*f=comma14.0 pctn;
   table year*(earn_found all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<earn_found all> pctn;
   table pik_found*(earn_found all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<earn_found all> pctn;
   table earn_pos_acs*(earn_pos_ui all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<earn_pos_ui all> pctn;
run;
proc means data=CPSACS.acs_person_02 n p5 p10 p25 median p75 p90 p95;
   class year;
   var earn_pos_acs earn_pos_ui WAG SEM RET INT OI PA TI PERN PINC wag_real pern_real earn_yr_real earn_yr earn_yr_avg earn_yr_med wag_diff;
run;
proc means data=CPSACS.acs_person_02(where=(earn_found=1)) n p5 p10 p25 median p75 p90 p95;
   class year;
   var earn_pos_acs earn_pos_ui WAG SEM RET INT OI PA TI PERN PINC wag_real pern_real earn_yr_real earn_yr earn_yr_avg earn_yr_med wag_diff;
run;
options obs=1000;
proc print data=CPSACS.acs_person_02;
run;
proc print data=CPSACS.acs_person_02(where=(year=2013 and earn_found=1));
   var year cmid pnum pik ST POWS max_st_fips WAG earn_yr earn_yr_med;
run;
