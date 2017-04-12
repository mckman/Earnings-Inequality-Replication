*** Calculate the total earnings for each earn_type by year ***;

%include "config.sas";

data temp1;
   set dot.hc_earn_type;

   et1=input(substr(earn_type,1,1),1.);
   et2=input(substr(earn_type,3,1),1.);
run;

proc summary data=temp1 nway;
   class year et1;
   output out=temp1s sum(_FREQ_ sum1_et)= count1 sum1;
run;

data temp1s2;
   set temp1s;

   year=year-1;
run;

proc summary data=temp1 nway;
   class year et2;
   output out=temp2s sum(_FREQ_ sum2_et)=count2 sum2;
run;

data temp3;
   merge temp1s2(keep=year count1 et1 sum1 rename=(et1=et))
         temp2s(keep=year count2 et2 sum2 rename=(et2=et));
      by year et;

   if count1>0 then sum_count=count1;
   else if count2>0 then sum_count=count2;

   if sum1>0 then sum_earn=sum1;
   else if sum2>0 then sum_earn=sum2;

   if et>1 then output; 
run;

proc print data=temp3;
   format count1 count2 sum_count COMMA14.0 sum1 sum2 sum_earn COMMA22.0;
run;

proc summary data=temp3 nway;
   class year;
   output out=temp3y sum(sum_count sum_earn)=sum_year_count sum_year_earn;
run;

proc print data=temp3y;
   format sum_year_count sum_year_earn COMMA24.0;
run;

proc transpose data=temp3(drop=count1 count2 sum1 sum2) out=temp3tc(drop=_NAME_) prefix=count_et_;
   by year;
   id et;
   var sum_count;
run;

proc print data=temp3tc;
   format count_et_2 count_et_3 count_et_4 COMMA14.0;
run;

proc transpose data=temp3(drop=count1 count2 sum1 sum2) out=temp3te(drop=_NAME_) prefix=earn_et_;
   by year;
   id et;
   var sum_earn;
run;

proc print data=temp3te;
   format earn_et_2 earn_et_3 earn_et_4 COMMA22.0;
run;

data temp4;
   merge temp3tc temp3te;
      by year;
run;

proc print data=temp4;
   format count_et_2 count_et_3 count_et_4 COMMA14.0 earn_et_2 earn_et_3 earn_et_4 COMMA22.0;
run;
