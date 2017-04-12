*** Print the Outflows and Inflows to each group by year ****;

%include "config.sas";

options obs=max;

%let eg=4;

data temp2 temp3 temp4;
   set dot.hc_person_type;

   if substr(person_type,1,1)="2" or substr(person_type,3,1)="2" then output temp2;
   if substr(person_type,1,1)="3" or substr(person_type,3,1)="3" then output temp3;
   if substr(person_type,1,1)="4" or substr(person_type,3,1)="4" then output temp4;
run;

data temp&eg.net;
   set temp&eg;

   length pt1 pt2 3;

   pt1=input(substr(person_type,1,1),1.);
   pt2=input(substr(person_type,3,1),1.);

   if pt1=&eg. and pt2~=&eg. then sum_person=-sum1_pt;
   else if pt1~=&eg. and pt2=&eg. then sum_person=sum2_pt;
   else if pt1=&eg. and pt2=&eg. then sum_person=sum2_pt-sum1_pt;

   if sum1_pt=. then person_change=sum2_pt;
   else if sum2_pt=. then person_change=-sum1_pt;
   else if sum1_pt>. and sum2_pt>. then person_change=sum2_pt-sum1_pt;

   avg_person=sum_person/_FREQ_;
   if pt1=&eg. and pt2=&eg. then avg_person=(sum1_pt+sum2_pt)/(2*_FREQ_);
   avg_change=person_change/_FREQ_;
run;

proc print data=temp&eg.net;
   format sum1_pt sum2_pt sum_person person_change avg_change avg_person COMMA22.0;
run;

proc summary data=temp&eg.net nway;
   class year;
   output out=temp&eg.y sum(sum_person person_change)=sum_y sum_ec;
run;

proc print data=temp&eg.y;
   format sum_y sum_ec COMMA22.0;
run;

proc transpose data=temp&eg.net out=temp&eg.t(drop=_NAME_) prefix=pt_;
   by year;
   id person_type;
   var sum_person;
run;

proc print data=temp&eg.t;
   format pt_3_2 pt_3_4 pt_4_3 18.0;
   var year pt_&eg._&eg. pt_&eg._0 pt_&eg._1 pt_&eg._2 pt_&eg._3 pt_0_&eg. pt_1_&eg. pt_2_&eg. pt_3_&eg.;
run;

proc transpose data=temp&eg.net out=temp&eg.t(drop=_NAME_) prefix=pt_;
   by year;
   id person_type;
   var person_change;
run;

proc print data=temp&eg.t;
   var year pt_&eg._&eg. pt_&eg._0 pt_&eg._1 pt_&eg._2 pt_&eg._3 pt_0_&eg. pt_1_&eg. pt_2_&eg. pt_3_&eg.;
run;

proc transpose data=temp&eg.net out=temp&eg.t(drop=_NAME_) prefix=pt_;
   by year;
   id person_type;
   var avg_change;
run;

proc print data=temp&eg.t;
   var year pt_&eg._&eg. pt_&eg._0 pt_&eg._1 pt_&eg._2 pt_&eg._3 pt_0_&eg. pt_1_&eg. pt_2_&eg. pt_3_&eg.;
run;

proc transpose data=temp&eg.net out=temp&eg.t(drop=_NAME_) prefix=pt_;
   by year;
   id person_type;
   var avg_person;
run;

proc print data=temp&eg.t;
   var year pt_&eg._&eg. pt_&eg._0 pt_&eg._1 pt_&eg._2 pt_&eg._3 pt_0_&eg. pt_1_&eg. pt_2_&eg. pt_3_&eg.;
run;
