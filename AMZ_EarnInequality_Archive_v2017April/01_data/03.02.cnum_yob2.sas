/* Check to make sure that all missing data patterns are in the reported data */;

%include "config.sas";

options obs=max;

/* Match the Numident missing data patterns with the Impute Table */;
proc sort data=outputs.cnum_strip(keep=DOC_year gender POB DOB_year where=(DOB_year=.))
          out=temp1(drop=DOB_year) nodupkey;
   by DOC_year gender POB;
run;

proc sort data=outputs.DOB_imp_table(keep=DOC_year gender POB) out=temp2 nodupkey;
   by DOC_year gender POB;
run;

data temp3;
   merge temp1(in=a) temp2(in=b);
      by DOC_year gender POB;

   length _merge 3;

   _merge=a+2*b;
run;

proc contents data=temp3;
proc tabulate data=temp3;
   class _merge;
   table _merge all, n*f=comma14.0 pctn;
run;

proc print data=temp3(where=(_merge=1));
proc print data=temp3(where=(_merge=2));
run;

/* Only keep the patterns we need */;

data outputs.DOB_imp_table2(drop=_merge);;
   merge outputs.DOB_imp_table(in=a) temp3(in=b);
      by DOC_year gender POB;
   
   if _merge=3 then output;
run;

proc contents data=outputs.DOB_imp_table2;
proc print data=outputs.DOB_imp_table2(obs=100);
run;
