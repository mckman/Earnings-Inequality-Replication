*02.01.merge_ui.sas;
*N. Zhao 20150902;
/* EHF strip of PIKs found on the CPS and ACS */

*** DATASETS ***;
/*
INPUTS:  CPSACS.cps_person_01
         CPSACS.acs_person_01
         UI.ehf_us
         UI_OPM.ehf_us_opm
OUTPUTS: CPSACS.ehf_01
*/

%include "config.sas";
*options obs=1000;

*** Get the list of PIKs from the survey data ***;
data work.plist(keep=PIK) / view=work.plist;
   set CPSACS.cps_person_01
       CPSACS.acs_person_01;

   if pik~=" " then output;
run;

proc sort data=work.plist out=work.piklist nodupkey;
   by pik;
run;

*** Create an EHF View ***;
data work.uistack / view=work.uistack;
   set ui.ehf_us(in=a)
       ui_opm.ehf_us_opm(in=b);
      by pik sein seinunit year quarter;

   length opm 3;
   if a=1 then opm=0;
   if b=1 then opm=1;

   label opm="OPM EHF record";
run;

*** Put it all together ***;
data CPSACS.ehf_01(drop=_merge) work.check(keep=_merge);
   merge work.piklist(in=a) work.uistack(in=b);
      by pik;

   length _merge 3;
   _merge=a+2*b;

   if _merge=3 then output CPSACS.ehf_01;
   if first.pik then output work.check;
run;

proc contents data=CPSACS.ehf_01;
run;
proc tabulate data=work.check;
   class _merge /missing;
   table _merge all='Total', n*f=comma14.0 pctn;
run;
proc means data=CPSACS.ehf_01;
   class yr_qtr;
run;

proc means data=CPSACS.ehf_01 n mean min p25 median p75 max;
run;
proc print data=CPSACS.ehf_01(obs=100);
run;
