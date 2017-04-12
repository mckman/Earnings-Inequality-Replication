/* Create the CDF */

%include "config.sas";

options obs=max;

/* Number of DOB values */;
proc freq data=outputs.DOB_imp_table2 noprint;
   title "Unique Non-missing DOB year values";
   tables DOB_year /missing out=temp0;
run;

%let dsid=%sysfunc(open(temp0));
%let ndob=%sysfunc(attrn(&dsid,nobs));

/* Get the size of each cell */;
data temp1(keep=DOC_year gender POB size);
   set outputs.DOB_imp_table2;
      by DOC_year gender POB;

   retain size;

   if first.POB then size=0;

   size=size+count;

   if last.POB then output;
run;

proc means data=temp1 n mean min p25 median p75 max;
   var size;
run;
   
data outputs.DOB_imp_table3(drop=DOB_year i cdf count size);
   merge outputs.DOB_imp_table2 temp1;
      by DOC_year gender POB;

   retain i cdf cdf1-cdf&ndob;

   array  cd{1:&ndob} cdf1-cdf&ndob;

   if first.pob then do;
      i=0;
      cdf=0;
   end;

   i=i+1;
   cdf=cdf+(count/size);
   cd{i}=cdf;

   if last.POB then output;
run;

proc contents data=outputs.DOB_imp_table3;
proc means data=outputs.DOB_imp_table3 n mean min p25 median p75 max;
   var cdf1 cdf&ndob;
run;
proc print data=outputs.DOB_imp_table3(obs=100);
run;
