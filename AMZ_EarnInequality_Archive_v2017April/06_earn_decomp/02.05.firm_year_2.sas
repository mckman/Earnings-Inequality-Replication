*** Print the Outflows and Inflows to each group by year ****;

%include "config.sas";

options obs=max;

%let eg=2;

data temp2 temp3 temp4;
   set dot.hc_firm_type;

   if substr(firm_type,1,1)="2" or substr(firm_type,3,1)="2" then output temp2;
   if substr(firm_type,1,1)="3" or substr(firm_type,3,1)="3" then output temp3;
   if substr(firm_type,1,1)="4" or substr(firm_type,3,1)="4" then output temp4;
run;

data temp&eg.net;
   set temp&eg;

   length ft1 ft2 3;

   ft1=input(substr(firm_type,1,1),1.);
   ft2=input(substr(firm_type,3,1),1.);

   if ft1=&eg. and ft2~=&eg. then sum_firm=-sum1_ft;
   else if ft1~=&eg. and ft2=&eg. then sum_firm=sum2_ft;
   else if ft1=&eg. and ft2=&eg. then sum_firm=sum2_ft-sum1_ft;

   if sum1_ft=. then firm_change=sum2_ft;
   else if sum2_ft=. then firm_change=-sum1_ft;
   else if sum1_ft>. and sum2_ft>. then firm_change=sum2_ft-sum1_ft;

   avg_firm=sum_firm/_FREQ_;
   if ft1=&eg. and ft2=&eg. then avg_firm=(sum1_ft+sum2_ft)/(2*_FREQ_);
   avg_change=firm_change/_FREQ_;
run;

proc print data=temp&eg.net;
   format sum1_ft sum2_ft sum_firm firm_change avg_change avg_firm COMMA22.0;
run;

proc summary data=temp&eg.net nway;
   class year;
   output out=temp&eg.y sum(sum_firm firm_change)=sum_y sum_ec;
run;

proc print data=temp&eg.y;
   format sum_y sum_ec COMMA22.0;
run;

proc transpose data=temp&eg.net out=temp&eg.t(drop=_NAME_) prefix=ft_;
   by year;
   id firm_type;
   var sum_firm;
run;

proc print data=temp&eg.t;
   var year ft_&eg._&eg. ft_&eg._0 ft_&eg._1 ft_&eg._3 ft_&eg._4 ft_0_&eg. ft_1_&eg. ft_3_&eg. ft_4_&eg.;
run;

proc transpose data=temp&eg.net out=temp&eg.t(drop=_NAME_) prefix=ft_;
   by year;
   id firm_type;
   var firm_change;
run;

proc print data=temp&eg.t;
   var year ft_&eg._&eg. ft_&eg._0 ft_&eg._1 ft_&eg._3 ft_&eg._4 ft_0_&eg. ft_1_&eg. ft_3_&eg. ft_4_&eg.;
run;

proc transpose data=temp&eg.net out=temp&eg.t(drop=_NAME_) prefix=ft_;
   by year;
   id firm_type;
   var avg_change;
run;

proc print data=temp&eg.t;
   var year ft_&eg._&eg. ft_&eg._0 ft_&eg._1 ft_&eg._3 ft_&eg._4 ft_0_&eg. ft_1_&eg. ft_3_&eg. ft_4_&eg.;
run;

proc transpose data=temp&eg.net out=temp&eg.t(drop=_NAME_) prefix=ft_;
   by year;
   id firm_type;
   var avg_firm;
run;

proc print data=temp&eg.t;
   var year ft_&eg._&eg. ft_&eg._0 ft_&eg._1 ft_&eg._3 ft_&eg._4 ft_0_&eg. ft_1_&eg. ft_3_&eg. ft_4_&eg.;
run;
