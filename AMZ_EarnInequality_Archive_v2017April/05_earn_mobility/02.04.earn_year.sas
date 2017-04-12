*** Print the Outflows and Inflows to each group by year ****;

%include "config.sas";

options obs=max;

proc print data=dot.hc_dist1;
run;

data temp0 temp1 temp2 temp3 temp4;
   set dot.hc_dist1;

   if substr(earn_type,1,1)="0" or substr(earn_type,3,1)="0" then output temp0;
   if substr(earn_type,1,1)="1" or substr(earn_type,3,1)="1" then output temp1;
   if substr(earn_type,1,1)="2" or substr(earn_type,3,1)="2" then output temp2;
   if substr(earn_type,1,1)="3" or substr(earn_type,3,1)="3" then output temp3;
   if substr(earn_type,1,1)="4" or substr(earn_type,3,1)="4" then output temp4;
run;

proc print data=temp0;
run;

proc transpose data=temp0 out=temp0t(drop=_NAME_ _LABEL_) prefix=et_;
   by year;
   id earn_type;
   var count;
run;

proc print data=temp1;
run;

proc transpose data=temp1 out=temp1t(drop=_NAME_ _LABEL_) prefix=et_;
   by year;
   id earn_type;
   var count;
run;

proc print data=temp2;
run;

proc transpose data=temp2 out=temp2t(drop=_NAME_ _LABEL_) prefix=et_;
   by year;
   id earn_type;
   var count;
run;

proc print data=temp3;
run;

proc transpose data=temp3 out=temp3t(drop=_NAME_ _LABEL_) prefix=et_;
   by year;
   id earn_type;
   var count;
run;

proc print data=temp4;
run;

proc transpose data=temp4 out=temp4t(drop=_NAME_ _LABEL_) prefix=et_;
   by year;
   id earn_type;
   var count;
run;

proc print data=temp0t;
   var year et_0_1 et_0_2 et_0_3 et_0_4 et_1_0 et_2_0 et_3_0 et_4_0;
run;

proc print data=temp1t;
   var year et_1_1 et_1_0 et_1_2 et_1_3 et_1_4 et_0_1 et_2_1 et_3_1 et_4_1;
run;

proc print data=temp2t;
   var year et_2_2 et_2_0 et_2_1 et_2_3 et_2_4 et_0_2 et_1_2 et_3_2 et_4_2;
run;

proc print data=temp3t;
   var year et_3_3 et_3_0 et_3_1 et_3_2 et_3_4 et_0_3 et_1_3 et_2_3 et_4_3;
run;

proc print data=temp4t;
   var year et_4_4 et_4_0 et_4_1 et_4_2 et_4_3 et_0_4 et_1_4 et_2_4 et_3_4;
run;
