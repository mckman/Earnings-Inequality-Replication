*** Print the Outflows and Inflows to each group by year ****;

%include "config.sas";

options obs=max;

%let eg=2;

data temp2 temp3 temp4;
   set dot.hc_earn_type;

   if substr(earn_type,1,1)="2" or substr(earn_type,3,1)="2" then output temp2;
   if substr(earn_type,1,1)="3" or substr(earn_type,3,1)="3" then output temp3;
   if substr(earn_type,1,1)="4" or substr(earn_type,3,1)="4" then output temp4;
run;

data temp&eg.net;
   set temp&eg;

   length et1 et2 3;

   et1=input(substr(earn_type,1,1),1.);
   et2=input(substr(earn_type,3,1),1.);

   if et1=&eg. and et2~=&eg. then sum_earn=-sum1_et;
   else if et1~=&eg. and et2=&eg. then sum_earn=sum2_et;
   else if et1=&eg. and et2=&eg. then sum_earn=sum2_et-sum1_et;

   if sum1_et=. then earn_change=sum2_et;
   else if sum2_et=. then earn_change=-sum1_et;
   else if sum1_et>. and sum2_et>. then earn_change=sum2_et-sum1_et;

   avg_earn=sum_earn/_FREQ_;
   if et1=&eg. and et2=&eg. then avg_earn=(sum1_et+sum2_et)/(2*_FREQ_);
   avg_change=earn_change/_FREQ_;
run;

proc print data=temp&eg.net;
   format sum1_et sum2_et sum_earn earn_change avg_change avg_earn COMMA22.0;
run;

proc summary data=temp&eg.net nway;
   class year;
   output out=temp&eg.y sum(sum_earn earn_change)=sum_y sum_ec;
run;

proc print data=temp&eg.y;
   format sum_y sum_ec COMMA22.0;
run;

proc transpose data=temp&eg.net out=temp&eg.t(drop=_NAME_) prefix=et_;
   by year;
   id earn_type;
   var sum_earn;
run;

proc print data=temp&eg.t;
   var year et_&eg._&eg. et_&eg._0 et_&eg._1 et_&eg._3 et_&eg._4 et_0_&eg. et_1_&eg. et_3_&eg. et_4_&eg.;
run;

proc transpose data=temp&eg.net out=temp&eg.t(drop=_NAME_) prefix=et_;
   by year;
   id earn_type;
   var earn_change;
run;

proc print data=temp&eg.t;
   var year et_&eg._&eg. et_&eg._0 et_&eg._1 et_&eg._3 et_&eg._4 et_0_&eg. et_1_&eg. et_3_&eg. et_4_&eg.;
run;

proc transpose data=temp&eg.net out=temp&eg.t(drop=_NAME_) prefix=et_;
   by year;
   id earn_type;
   var avg_change;
run;

proc print data=temp&eg.t;
   var year et_&eg._&eg. et_&eg._0 et_&eg._1 et_&eg._3 et_&eg._4 et_0_&eg. et_1_&eg. et_3_&eg. et_4_&eg.;
run;

proc transpose data=temp&eg.net out=temp&eg.t(drop=_NAME_) prefix=et_;
   by year;
   id earn_type;
   var avg_earn;
run;

proc print data=temp&eg.t;
   var year et_&eg._&eg. et_&eg._0 et_&eg._1 et_&eg._3 et_&eg._4 et_0_&eg. et_1_&eg. et_3_&eg. et_4_&eg.;
run;
