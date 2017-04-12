/*  Look at the Missing Data Patterns */

%include "config.sas";

options obs=max;

/* Create the full table */;
proc freq data=outputs.cnum_strip(where=(DOB_year~=.)) noprint;
   tables DOC_year*gender*POB*DOB_year / SPARSE out=DOB_imp_table;
run;

options obs=max;

proc contents data=DOB_imp_table;
run;

/* Create the margins */;
proc means data=DOB_imp_table noprint;
   class DOC_year gender POB /missing;
   output out=DOB_imp_margins sum(COUNT)=COUNT;
run;

proc contents data=DOB_imp_margins;
run;

/* Check the Margins and identify the _TYPE_ values */;
proc means data=DOB_imp_margins n sum;
   title "Margins";
   class _TYPE_ /missing;
   var COUNT;
run;

/* Cells with no mass */;
proc print data=DOB_imp_margins(where=(_TYPE_=7 and COUNT=0));
   title "Empty Margins";
run;

/* Number of DOB values */;
proc freq data=DOB_imp_table noprint;
   title "Unique Non-missing DOB year values";
   tables DOB_year /missing out=temp0;
run;

%let dsid=%sysfunc(open(temp0));
%let ndob=%sysfunc(attrn(&dsid,nobs));

/* Select the DOC_year gender POB cells that have no mass */;

data temp1(drop=_TYPE_ _FREQ_ count i);
   set DOB_imp_margins(where=(_TYPE_=7 and COUNT=0));

   array dby{1:&ndob} _TEMPORARY_;

   i=0;
   if _N_=1 then do until (last=1);
         i=i+1;
         set temp0(keep=DOB_year) end=last;
         dby{i}=DOB_year;
   end;

   do i=1 to &ndob;
      DOB_year=dby{i};
      output;
   end;
run;

/* Create the DOC_year DOB_year counts */;

proc means data=DOB_imp_table nway noprint;
   class DOC_year DOB_year;
   output out=temp2 sum(COUNT)=COUNT;
run;

proc sort data=temp1;
   by DOC_year DOB_year;
run;

data temp3;
   merge temp1(in=a) temp2(in=b keep=DOC_year DOB_year COUNT);
      by DOC_year DOB_year;
   
   if a=1 and b=1 then output;
run;

proc sort data=temp3;
   by DOC_year gender POB DOB_year;
run;

data outputs.DOB_imp_table(drop=PERCENT);
   update DOB_imp_table temp3;
      by DOC_year gender POB DOB_year;
run;

proc contents data=outputs.DOB_imp_table;
run;

/* Check the udpate worked */;
proc means data=outputs.DOB_imp_table noprint;
   class DOC_year gender POB /missing;
   output out=DOB_imp_margins sum(COUNT)=COUNT;
run;

proc means data=DOB_imp_margins n sum;
   title "Margins";
   class _TYPE_ /missing;
   var COUNT;
run;

/* Cells with no mass */;
proc print data=DOB_imp_margins(where=(_TYPE_=7 and COUNT=0));
   title "Empty Margins";
run;
