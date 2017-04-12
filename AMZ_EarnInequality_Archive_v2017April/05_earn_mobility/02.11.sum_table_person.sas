*** Earnings Mobility For Workers by Firm Type ****;

%include "config.sas";

options obs=max;

proc print data=dot.hc_dist5;
run;

data temp1;
   set dot.hc_dist5;

   length ft $1;

   ft=substr(firm_type,1,1);
run;

proc print data=temp1;
run;

proc summary data=temp1 nway;
   class ft person_type;
   output out=temp2 sum(count)=flow_sum;
run;

proc print data=temp2;
run;

data temp3(drop=flow_sum);
   set temp2(drop=_TYPE_ _FREQ_);

   count=round(flow_sum/9);

   if ft in ("2","3","4") then output;
run;

proc print data=temp3;
   var ft person_type count;
run;
