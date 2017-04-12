*01.01.CPS_vars.sas;
*K. McKinney 20150914;
/* Create stacked PIK-ed CPS person file */

*** DATASETS ***;
/*
INPUTS:  CPS.personYYYY
         CPS.familyYYYY
         CPS.hhldYYYY
OUTPUTS: CPSACS.cps_person_01
*/

%include "config.sas";

*** Person file variables ***;
%let pvars=a_famrel workyn wtemp nwlook wkswork hrswk wexp ptotval pearnval pothval wsal_val semp_val frse_val marsupwt
                  i_workyn i_wtemp i_wkswk i_hrswk              i_ernval          i_wsval i_seval i_frmval
           a_age a_sex axage axsex a_lfsr a_clswkr;

*** Family file variables ***;
%let fvars=fpersons fearns ftotval fearnval fothval fwsval fseval ffrval fsup_wgt;

*** Household file variables ***;
%let hvars=h_type h_numper hnumfam hg_fips htotval hearnval hothval hwsval hwsval hseval hfrval hsup_wgt;

*** Combine household, family, and person files ***;
%macro loop;
   %do yr=&CPSstart %to &CPSend;

      *** Calculate the number of persons in a family and household ***;
      data work.hnum(keep=ph_seq nper_h) work.fnum(keep=ph_seq phf_seq nper_f);
         set CPS.person&yr.(keep=ph_seq phf_seq);
            by ph_seq phf_seq;
      
         length nper_h nper_f 3;
      
         retain nper_h nper_f;
         if first.ph_seq then nper_h=0;
         if first.phf_seq then nper_f=0;
      
         nper_h=nper_h+1;
         nper_f=nper_f+1;
      
         if last.ph_seq then output work.hnum;
         if last.phf_seq then output work.fnum;
      run;
      
      proc contents data=work.hnum; 
      proc means data=work.hnum n mean min p25 median p75 max; 
         var nper_h;
      run;
      proc contents data=work.fnum; 
      proc means data=work.fnum n mean min p25 median p75 max; 
         var nper_f;
      run;
      
      
      *** Attach the calculated household and family counts to the person data ***;
      data work.p1(drop=_merge) work.check(keep=_merge);
         merge CPS.person&yr.(keep=ph_seq phf_seq ppposold &pvars in=a)
               work.hnum(in=b);
            by ph_seq;
             
         length _merge 3;
         _merge=a+2*b;
      run;
      
      proc contents data=work.p1;
      run;
      proc freq data=work.check;
         tables _merge;
      run;
      
      data work.person(drop=_merge) work.check(keep=_merge);
         merge work.p1(in=a)
               work.fnum(in=b);
            by ph_seq phf_seq;
             
         length _merge onefam 3;
         _merge=a+2*b;
      
         onefam=(nper_h=nper_f);
      
         label nper_h="Calc Num Persons HHLD"
               nper_f="Calc Num Persons Family"
               onefam="One family in HHLD";
      run;
      
      proc contents data=work.person;
      proc freq data=work.check;
         tables _merge;
      run;
      proc print data=work.person(obs=100);
      run;
      
      
      *** Merge the Family data ***;
      data work.family(drop=_merge) work.check(keep=_merge);
         merge work.person(in=a) CPS.family&yr.(in=b keep=fh_seq ffpos &fvars rename=(fh_seq=ph_seq ffpos=phf_seq));
            by ph_seq phf_seq;
      
         length _merge 3;
         _merge=a+2*b;

         if _merge=3 then output work.family;
         output check;
      run;
      
      proc contents data=work.family;
      run;
      proc freq data=work.check;
         tables _merge;
      run;
      proc print data=work.family(obs=100);
      run;
      
      
      *** Merge the Household data ***;
      data work.person&yr.(drop=_merge year_interview h_type) work.check(keep=_merge);
      
         length year 3;
      
         merge work.family(in=a) CPS.hhld&yr.(in=b keep=h_seq &hvars rename=(h_seq=ph_seq));
            by ph_seq;
      
         length _merge nper_h_equal nper_f_equal 3 h_type2 $2;
      
         _merge=a+2*b;

         year_interview=&yr.;
         year=year_interview-1;
      
         if length(trim(left(h_type)))=1 then h_type2="0" || h_type;
         else h_type2=h_type;

         nper_h_equal=nper_h=input(h_numper,2.);
         nper_f_equal=nper_f=input(fpersons,2.);
      
         label year ="Recall year; one year before the CPS interview"
               h_type2="2 digit h_type"
               nper_h_equal="Num Person Rec equal Household Count"
               nper_f_equal="Num Person Rec equal Family Count";
      
         if _merge=3 then output work.person&yr.;
         output check;
      run;
      
      proc contents data=work.person&yr.;
      run;
      proc freq data=work.check;
         tables _merge;
      run;
      proc freq data=work.person&yr.;
         tables h_type2 nper_h_equal nper_f_equal;
      run;
      options nolabel;
      proc means data=work.person&yr. n mean min p25 median p75 max;
      run;
      options label;
      proc print data=work.person&yr.(obs=100);
      run;

      proc append base=work.personall data=work.person&yr.;
      run;
   %end;
%mend;
%loop;

*** Attach PIK to the CPS data ***;
data work.xwalk(drop=year_temp) / view=work.xwalk;
   set CPSPIK.master_cpsxwalk_internal_py(keep=pik year ph_seq ppposold rename=(year=year_temp));
   length year 3;
   year=year_temp-1;
run;

proc sort data=work.xwalk out=work.CPS_xwalk;
        by year ph_seq ppposold;
run;

data CPSACS.cps_person_01(drop=_merge) work.check(keep=year _merge);
   merge work.personall(in=a) work.CPS_xwalk(in=b);
      by year ph_seq ppposold;

   length _merge pik_found 3;
   _merge=a+2*b;

   pik_found=_merge=3;

   label pik_found="PIK found on crosswalk";

   if a=1 then output CPSACS.cps_person_01;
   output check;
run;

proc contents data=CPSACS.cps_person_01;
run;
options nolabel;
proc freq data=check;
   tables year*_merge;
run;
proc freq data=CPSACS.cps_person_01;
   tables year year*pik_found;
run;
proc means data=CPSACS.cps_person_01 n mean min p25 median p75 max;
run;
proc print data=CPSACS.cps_person_01(obs=100);
run;
