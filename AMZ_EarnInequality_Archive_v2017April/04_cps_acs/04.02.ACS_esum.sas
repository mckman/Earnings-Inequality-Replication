*04.02.ACS_esum.sas;
*K. McKinney 20150906;
/* Create yearly earnings records and earnings history summary measures */

*** DATASETS ***;
/*
INPUTS:  CPSACS.earn_acs_01
OUTPUTS: CPSACS.earn_acs_02_pik
*/

%include "config.sas";
*options obs=1000;

*** Yearly earnings records ***;
data work.pik_year_earn(keep=pik year earn_yr njobs);
   set CPSACS.earn_acs_01;
      by pik year sein;

   retain earn_yr njobs;

   if first.year then do;
      earn_yr=0;
      njobs=0;
   end;

   earn_yr=earn_yr+earn;

   if first.sein then njobs=njobs+1;

   if last.year then do;
      output;
   end;
run;

proc contents data=work.pik_year_earn;
run;
proc print data=work.pik_year_earn(obs=100);
run;

*** Summary statistics of UI earnings ***;
proc summary data=work.pik_year_earn nway;
   class pik;
   output out=work.piksum
      n(earn_yr)=earn_yr_num
      mean(earn_yr)=earn_yr_avg
      median(earn_yr)=earn_yr_med
      min(earn_yr)=earn_yr_min
      max(earn_yr)=earn_yr_max
      min(year)=earn_yr_first
      max(year)=earn_yr_last;
run;

data CPSACS.earn_acs_02_pik;
   set work.piksum(drop=_TYPE_ _FREQ_ in=b);
      by pik;

   earn_yr_avg=round(earn_yr_avg);
   earn_yr_med=round(earn_yr_med);

   label earn_yr_avg="UI Avg Ann Earnings"
         earn_yr_first="UI first year earnings observed"
         earn_yr_last="UI last year earnings observed"
         earn_yr_max="UI Max Ann Earnings"
         earn_yr_med="UI Median Ann Earnings"
         earn_yr_min="UI Min Ann Earnings"
         earn_yr_num="UI Number of Years Earnings";
    
run;

proc contents data=CPSACS.earn_acs_02_pik;
options nolabel;
proc means data=CPSACS.earn_acs_02_pik n mean min p25 median p75 max;
run;
proc print data=CPSACS.earn_acs_02_pik(obs=1000);
run;
