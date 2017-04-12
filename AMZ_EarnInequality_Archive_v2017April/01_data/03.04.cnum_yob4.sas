/* Impute the missing DOB_year values */;

%include "config.sas";

options obs=max;

/* Number of DOB values */;
proc freq data=outputs.DOB_imp_table2 noprint;
   title "Unique Non-missing DOB year values";
   tables DOB_year /missing out=temp0;
run;

%let dsid=%sysfunc(open(temp0));
%let ndob=%sysfunc(attrn(&dsid,nobs));

/* Get the records with a missing DOB_year value */;
proc sort data=outputs.cnum_strip(keep=pik DOC_year gender POB DOB_year where=(DOB_year=.))
          out=temp1(drop=DOB_year);
   by DOC_year gender POB;
run;

/* Impute Year of Birth */;

data temp1(keep=pik DOC_year gender POB DOB_year dobcc dobyy dobmm dobdd _merge found);
   merge temp1(in=a) outputs.DOB_imp_table3(in=b);
      by DOC_year gender POB;

   length _merge DOB_year 3 DOBCC DOBYY DOBMM DOBDD $2;

   _merge=a+2*b;

   array dby{1:&ndob} _TEMPORARY_;
   array  cd{1:&ndob} cdf1-cdf&ndob;

   i=0;
   if _N_=1 then do until (last=1);
         i=i+1;
         set temp0(keep=DOB_year) end=last;
         dby{i}=DOB_year;
   end;

   uni=rand('UNIFORM');

   found=uni<=cd{1};
   do i=2 to &ndob while(found=0);
      if uni>cd{i-1} and uni<=cd{i} then found=i;
   end;
   DOB_year=dby{found};
   dobcc=substr(put(DOB_year,4.),1,2);
   dobyy=substr(put(DOB_year,4.),3,2);
   dobmm=" ";
   dobdd=" ";
run;

proc contents data=temp1;
proc means data=temp1 n mean min p25 median p75 max;
   class DOC_year /missing;
   var DOB_year;
run;
proc tabulate data=temp1;
   class _merge found DOB_year /missing;
   table _merge all, n*f=comma14.0 pctn;
   table found all, n*f=comma14.0 pctn;
   table DOB_year all, n*f=comma14.0 pctn;
run;
proc print data=temp1(obs=100);
run;

/* Impute Month and Day of Birth */;

data temp2;
   set temp1(keep=pik dobcc dobyy dobmm dobdd);

   %include "00.02_dob_final.txt";

   dob_flag=dob_flag+5;
run;

proc contents data=temp2;
proc tabulate data=temp2;
   class dob_year dob_flag /missing;
   table dob_year all, n*f=comma14.0 pctn;
   table dob_flag all, n*f=comma14.0 pctn;
run;
proc print data=temp2(obs=100);
run;
    
/* Update the Numident Strip */;
proc sort data=temp2(keep=pik DOB DOB_flag DOB_year DOB_month DOB_day) out=temp3;
   by pik;
run;

data outputs.cnum_strip2;
   update outputs.cnum_strip temp3;
      by pik;
run;

proc contents data=outputs.cnum_strip2;
proc means data=outputs.cnum_strip2 n mean min p25 median p75 max;
   var DOB DOB_year DOB_month DOB_day;
run;
proc tabulate data=outputs.cnum_strip2;
   class dob_year dob_flag /missing;
   table dob_year all, n*f=comma14.0 pctn;
   table dob_flag all, n*f=comma14.0 pctn;
run;
proc print data=outputs.cnum_strip2(obs=100);
run;
