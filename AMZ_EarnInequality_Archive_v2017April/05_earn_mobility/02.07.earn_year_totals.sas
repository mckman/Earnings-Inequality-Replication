*** Print the distribution category counts by year ****;

%include "config.sas";

options obs=max;

proc print data=dot.hc_year1;
run;

proc summary data=dot.hc_year1 nway;
   class year;
   output out=temp1y sum(COUNT)=count_year;
run;

proc means data=temp1y;
run;

data temp1;
   merge dot.hc_year1(drop=PERCENT) temp1y(drop=_TYPE_ _FREQ_);
      by year;

   retain et_1 et_2 et_3 et_4;

   if first.year then do;
      et_1=0;
      et_2=0;
      et_3=0;
      et_4=0;
   end;

   if le_r=. then et_1=et_1+COUNT;
   else if le_r>=0 and le_r<=1 then et_2=et_2+COUNT;
   else if le_r>=2 and le_r<=7 then et_3=et_3+COUNT;
   else if le_r>=8 and le_r<=9 then et_4=et_4+COUNT;

   if last.year then do;
      et_1_p=et_1/count_year;
      et_2_p=et_2/count_year;
      et_3_p=et_3/count_year;
      et_4_p=et_4/count_year;
      output;
   end;
run;

proc print data=temp1;
   var year et_1 et_2 et_3 et_4 et_1_p et_2_p et_3_p et_4_p;
run;
