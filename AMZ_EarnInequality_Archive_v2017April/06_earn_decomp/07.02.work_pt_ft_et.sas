*** Firm to Firm Flows ***;

%include "config.sas";

data temp1;
   set dot.work_ft_pt_et;

   ft1=input(substr(firm_type,1,1),1.);
   ft2=input(substr(firm_type,3,1),1.);

   pt1=input(substr(person_type,1,1),1.);
   pt2=input(substr(person_type,3,1),1.);

   if ft1>1 and pt1>1 then output;
run;

proc summary data=temp1 nway;
   class pt1 ft1 earn_type;
   output out=temp2 sum(sum1_nq sum1_lj sum1_nj sum2_nq sum2_lj sum2_nj _FREQ_)=
                         s1_nq s1_lj s1_nj s2_nq s2_lj s2_nj count;
run;

data temp3;
   set temp2;

   if s1_nq>. then num_qtr_1=s1_nq/count;
   if s1_lj>. then long_job_1=s1_lj/count;
   if s1_nj>. then num_job_1=s1_nj/count;

   if s2_nq>. then num_qtr_2=s2_nq/count;
   if s2_lj>. then long_job_2=s2_lj/count;
   if s2_nj>. then num_job_2=s2_nj/count;

   avg_flow=count/9;
run;

proc print data=temp3;
   format avg_flow COMMA14.0 num_qtr_1--num_job_2 COMMA9.4;
   var pt1 ft1 earn_type avg_flow num_qtr_1--num_job_2;
run;
