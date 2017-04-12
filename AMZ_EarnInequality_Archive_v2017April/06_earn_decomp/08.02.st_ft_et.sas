*** Firm to Firm Flows ***;

%include "config.sas";

data temp1;
   set dot.hc_ft_st_et;

   ft1=input(substr(firm_type,1,1),1.);
   ft2=input(substr(firm_type,3,1),1.);

   st1=input(substr(skill_type,1,1),1.);
   st2=input(substr(skill_type,3,1),1.);

   if ft1>1 and st1>1 then output;
run;

proc summary data=temp1 nway;
   class st1 ft1 earn_type;
   output out=temp2 sum(sum1_et sum1_ft sum1_pt sum2_et sum2_ft sum2_pt _FREQ_)=
                         s1_et s1_ft s1_pt s2_et s2_ft s2_pt count;
run;

data temp3;
   set temp2;

   if s1_et>. then earn_avg_1=s1_et/count;
   if s1_ft>. then firm_avg_1=s1_ft/count;
   if s1_pt>. then person_avg_1=s1_pt/count;

   if s2_et>. then earn_avg_2=s2_et/count;
   if s2_ft>. then firm_avg_2=s2_ft/count;
   if s2_pt>. then person_avg_2=s2_pt/count;

   avg_flow=count/9;
run;

proc print data=temp3;
   format avg_flow COMMA14.0 earn_avg_1--person_avg_2 COMMA12.0;
   var st1 ft1 earn_type avg_flow earn_avg_1--person_avg_2;
run;
