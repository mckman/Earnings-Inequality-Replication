*** Print the Outflows and Inflows to each group by year ****;

%include "config.sas";

options obs=max;

proc print data=dot.hc_dist2;
run;

data temp0 temp1 temp2 temp3 temp4;
   set dot.hc_dist2;

   if substr(firm_type,1,1)="0" or substr(firm_type,3,1)="0" then output temp0;
   if substr(firm_type,1,1)="1" or substr(firm_type,3,1)="1" then output temp1;
   if substr(firm_type,1,1)="2" or substr(firm_type,3,1)="2" then output temp2;
   if substr(firm_type,1,1)="3" or substr(firm_type,3,1)="3" then output temp3;
   if substr(firm_type,1,1)="4" or substr(firm_type,3,1)="4" then output temp4;
run;

proc print data=temp0;
run;

proc transpose data=temp0 out=temp0t(drop=_NAME_ _LABEL_) prefix=ft_;
   by year;
   id firm_type;
   var count;
run;

proc print data=temp1;
run;

proc transpose data=temp1 out=temp1t(drop=_NAME_ _LABEL_) prefix=ft_;
   by year;
   id firm_type;
   var count;
run;

proc print data=temp2;
run;

proc transpose data=temp2 out=temp2t(drop=_NAME_ _LABEL_) prefix=ft_;
   by year;
   id firm_type;
   var count;
run;

proc print data=temp3;
run;

proc transpose data=temp3 out=temp3t(drop=_NAME_ _LABEL_) prefix=ft_;
   by year;
   id firm_type;
   var count;
run;

proc print data=temp4;
run;

proc transpose data=temp4 out=temp4t(drop=_NAME_ _LABEL_) prefix=ft_;
   by year;
   id firm_type;
   var count;
run;

proc print data=temp0t;
   var year ft_0_1 ft_0_2 ft_0_3 ft_0_4 ft_1_0 ft_2_0 ft_3_0 ft_4_0;
run;

proc print data=temp1t;
   var year ft_1_1 ft_1_0 ft_1_2 ft_1_3 ft_1_4 ft_0_1 ft_2_1 ft_3_1 ft_4_1;
run;

proc print data=temp2t;
   var year ft_2_2 ft_2_0 ft_2_1 ft_2_3 ft_2_4 ft_0_2 ft_1_2 ft_3_2 ft_4_2;
run;

proc print data=temp3t;
   var year ft_3_3 ft_3_0 ft_3_1 ft_3_2 ft_3_4 ft_0_3 ft_1_3 ft_2_3 ft_4_3;
run;

proc print data=temp4t;
   var year ft_4_4 ft_4_0 ft_4_1 ft_4_2 ft_4_3 ft_0_4 ft_1_4 ft_2_4 ft_3_4;
run;
