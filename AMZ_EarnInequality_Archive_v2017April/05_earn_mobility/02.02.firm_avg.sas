*** Print the Average Firm Earnings Distribution Change Flows ****;

%include "config.sas";

options obs=max;

proc print data=dot.hc_dist2;
run;

proc summary data=dot.hc_dist2 nway;
   class firm_type;
   output out=temp1 mean(count)=flow_avg;
run;

proc print data=temp1;
run;

data temp2(drop=flow_avg);
   set temp1(drop=_TYPE_ _FREQ_);

   count=round(flow_avg);
run;

proc summary data=temp2;
   output out=temp2max max(count)=max;
run;

proc print data=temp2max;

data temp3(drop=max count);
   set temp2;

   length vertex1 vertex2 $2;

   retain max;

   if _N_=1 then set temp2max(keep=max);

   vertex1="a" || put(substr(firm_type,1,1),1.);
   vertex2="b" || put(substr(firm_type,3,1),1.);

   width=1+9*(count/max);

   label=count;
   
run;

proc print data=temp3;
   format width 3.1 label 14.0;
run;
