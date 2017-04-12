*03.01.CPS_earn.sas;
*K. McKinney 20150902;
/* Get all earnings from the UI data for the CPS records */

*** DATASETS ***;
/*
INPUTS:  CPSACS.pik_year_01
         CPSACS.ehf_01
OUTPUTS: CPSACS.earn_cps_01
*/

%include "config.sas";
*options obs=1000;

*** All PIKs ever in CPS ***;
data work.pik_cps(keep=pik) /view=work.pik_cps;
   set CPSACS.pik_year_01(keep=pik year npik_cps);
      by pik;

   if first.pik and npik_cps>0 then output;
run;

*** Collect all quarterly UI records for CPS PIKs ***;
data work.earn(drop=_merge) work.check(keep=_merge);
   merge work.pik_cps(in=a) CPSACS.ehf_01(in=b);
      by pik;

   length _merge 3;
   _merge=a+2*b;

   if first.pik then output work.check;
   if _merge=3 then output work.earn;
run;
   
proc contents data=work.earn;
run;
proc tabulate data=work.check;
   class _merge /missing;
   table _merge all='Total', n*f=comma14.0 pctn;
run;
proc tabulate data=work.earn;
   class source /missing;
   table source all='Total', n*f=comma14.0 pctn;
run;
proc means data=work.earn;
run;

*** Aggregate out SEINUNIT ***;
proc sort data=work.earn;
   by pik year quarter sein seinunit;
run;

data work.earn(drop=earn_temp);
	set work.earn(rename=(earn=earn_temp));
	by pik year quarter sein;

	length earn 8;
	label earn = "Quarterly Earnings";
	retain earn;

	if first.sein then earn = 0;
	earn = earn + earn_temp;

	if last.sein then output;
run;

proc sort data=work.earn out=CPSACS.earn_cps_01;
   by pik year sein quarter;
run;

proc contents data=CPSACS.earn_cps_01;
run;
proc print data=CPSACS.earn_cps_01(obs=100);
run;
