*** Print the distribution category counts by year ****;

%include "config.sas";

options obs=max;

proc print data=dot.hc_year3;
run;

proc summary data=dot.hc_year3 nway;
   class year;
   output out=temp1y sum(COUNT)=count_year;
run;

proc means data=temp1y;
run;

data temp1;
   merge dot.hc_year3(drop=PERCENT) temp1y(drop=_TYPE_ _FREQ_);
      by year;

   retain pt_1 pt_2 pt_3 pt_4;

   if first.year then do;
      pt_1=0;
      pt_2=0;
      pt_3=0;
      pt_4=0;
   end;

   if lp_r=. then pt_1=pt_1+COUNT;
   else if lp_r>=0 and lp_r<=1 then pt_2=pt_2+COUNT;
   else if lp_r>=2 and lp_r<=7 then pt_3=pt_3+COUNT;
   else if lp_r>=8 and lp_r<=9 then pt_4=pt_4+COUNT;

   if last.year then do;
      pt_1_p=pt_1/count_year;
      pt_2_p=pt_2/count_year;
      pt_3_p=pt_3/count_year;
      pt_4_p=pt_4/count_year;
      output;
   end;
run;

proc print data=temp1;
   var year pt_1 pt_2 pt_3 pt_4 pt_1_p pt_2_p pt_3_p pt_4_p;
run;
