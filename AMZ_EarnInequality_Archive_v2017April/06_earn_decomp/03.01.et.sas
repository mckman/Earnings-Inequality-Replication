*** Firm to Firm Flows ***;

%include "config.sas";

data temp1;
   set dot.hc_et;

   et1=input(substr(earn_type,1,1),1.);
   et2=input(substr(earn_type,3,1),1.);

   if sum1_et>. then earn_avg_1=sum1_et/_FREQ_;
   if sum1_ft>. then firm_avg_1=sum1_ft/_FREQ_;
   if sum1_pt>. then person_avg_1=sum1_pt/_FREQ_;

   if sum2_et>. then earn_avg_2=sum2_et/_FREQ_;
   if sum2_ft>. then firm_avg_2=sum2_ft/_FREQ_;
   if sum2_pt>. then person_avg_2=sum2_pt/_FREQ_;

   avg_flow=_FREQ_/9;

   *if et1>1 and et2>1 then output;
run;

proc print data=temp1;
   format avg_flow COMMA14.0 earn_avg_1--person_avg_2 COMMA12.0;
   var earn_type avg_flow earn_avg_1--person_avg_2;
run;
