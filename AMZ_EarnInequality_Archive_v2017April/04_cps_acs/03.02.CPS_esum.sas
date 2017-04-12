*03.02.CPS_esum.sas;
*K. McKinney 20150902;
/* Create yearly earnings records and earnings history summary measures */

*** DATASETS ***;
/*
INPUTS:  CPSACS.earn_cps_01
OUTPUTS: CPSACS.earn_cps_02
*/

%include "config.sas";
*options obs=1000;

*** Yearly earnings records ***;
data work.pik_year_earn(keep=pik year max_st_fips earn_yr njobs pct_earn_st_max);
   set CPSACS.earn_cps_01;
      by pik year sein;

   array searn {0:56} _TEMPORARY_;
   array fc {0:56} $2 _TEMPORARY_;

   length max_st_fips $2 earn_yr njobs pct_earn_st_max 8;
   retain earn_yr njobs;

   if first.year then do;
      earn_yr=0;
      njobs=0;
      do i=0 to 56;
         searn{i}=0;
      end;
   end;

   earn_yr=earn_yr+earn;

   if first.sein then njobs=njobs+1;

   fip_num=input(source,2.);

   fc{fip_num}=source;

   searn{fip_num}=searn{fip_num}+earn;

   if last.year then do;
      state_max=max(of searn{*});
      do i=0 to 56;
         if searn{i}=state_max then do;
            fc_max=i;
            leave;
         end;
      end;
      max_st_fips=fc{fc_max};
      pct_earn_st_max=state_max/earn_yr;
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
      max(year)=earn_yr_last
   ;
run;

data CPSACS.earn_cps_02(drop=_merge) work.check(keep=_merge);
   merge work.pik_year_earn(in=a) work.piksum(drop=_TYPE_ _FREQ_ in=b);
      by pik;

   length _merge 3;
   _merge=a+2*b;
   
   earn_yr_avg=round(earn_yr_avg);
   earn_yr_med=round(earn_yr_med);

   if first.pik then output work.check;

   label earn_yr="UI Annual Earnings"
         earn_yr_avg="UI Avg Ann Earnings"
         earn_yr_first="UI first year earnings observed"
         earn_yr_last="UI last year earnings observed"
         earn_yr_max="UI Max Ann Earnings"
         earn_yr_med="UI Median Ann Earnings"
         earn_yr_min="UI Min Ann Earnings"
         earn_yr_num="UI Number of Years Earnings"
         max_st_fips="UI State Max Earn in a Year"
         njobs="UI Number of Employers in a Year"
         pct_earn_st_max="UI Pct Ann Earn in Max State";
    
   output CPSACS.earn_cps_02;
run;

proc contents data=CPSACS.earn_cps_02;
run;
options nolabel;
proc tabulate data=work.check;
   class _merge /missing;
   table _merge all='Total', n*f=comma14.0 pctn;
run;
proc means data=CPSACS.earn_cps_02 n mean min p25 median p75 max;
   class year;
run;
proc print data=CPSACS.earn_cps_01(obs=20);
run;
proc print data=CPSACS.earn_cps_02(obs=100);
run;
