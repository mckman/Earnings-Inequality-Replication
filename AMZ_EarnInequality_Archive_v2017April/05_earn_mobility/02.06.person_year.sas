*** Print the Outflows and Inflows to each group by year ****;

%include "config.sas";

options obs=max;

proc print data=dot.hc_dist3;
run;

data temp0 temp1 temp2 temp3 temp4;
   set dot.hc_dist3;

   if substr(person_type,1,1)="0" or substr(person_type,3,1)="0" then output temp0;
   if substr(person_type,1,1)="1" or substr(person_type,3,1)="1" then output temp1;
   if substr(person_type,1,1)="2" or substr(person_type,3,1)="2" then output temp2;
   if substr(person_type,1,1)="3" or substr(person_type,3,1)="3" then output temp3;
   if substr(person_type,1,1)="4" or substr(person_type,3,1)="4" then output temp4;
run;

proc print data=temp0;
run;

proc transpose data=temp0 out=temp0t(drop=_NAME_ _LABEL_) prefix=pt_;
   by year;
   id person_type;
   var count;
run;

proc print data=temp1;
run;

proc transpose data=temp1 out=temp1t(drop=_NAME_ _LABEL_) prefix=pt_;
   by year;
   id person_type;
   var count;
run;

proc print data=temp2;
run;

proc transpose data=temp2 out=temp2t(drop=_NAME_ _LABEL_) prefix=pt_;
   by year;
   id person_type;
   var count;
run;

proc print data=temp3;
run;

proc transpose data=temp3 out=temp3t(drop=_NAME_ _LABEL_) prefix=pt_;
   by year;
   id person_type;
   var count;
run;

proc print data=temp4;
run;

proc transpose data=temp4 out=temp4t(drop=_NAME_ _LABEL_) prefix=pt_;
   by year;
   id person_type;
   var count;
run;

proc print data=temp0t;
   var year pt_0_1 pt_0_2 pt_0_3 pt_0_4 pt_1_0 pt_2_0 pt_3_0 pt_4_0;
run;

proc print data=temp1t;
   var year pt_1_1 pt_1_0 pt_1_2 pt_1_3 pt_1_4 pt_0_1 pt_2_1 pt_3_1 pt_4_1;
run;

proc print data=temp2t;
   var year pt_2_2 pt_2_0 pt_2_1 pt_2_3 pt_2_4 pt_0_2 pt_1_2 pt_3_2 pt_4_2;
run;

proc print data=temp3t;
   var year pt_3_3 pt_3_0 pt_3_1 pt_3_2 pt_3_4 pt_0_3 pt_1_3 pt_2_3 pt_4_3;
run;

proc print data=temp4t;
   var year pt_4_4 pt_4_0 pt_4_1 pt_4_2 pt_4_3 pt_0_4 pt_1_4 pt_2_4 pt_3_4;
run;
