*** Create counts for each category ***;

%include "config.sas";

options obs=max;

proc summary data=outputs.pik_year_work nway;
   class year num_qtrs long_job et ft pt;
   output out=dot.work_year_detail(drop=_TYPE_ rename=(_FREQ_=count)) sum(num_jobs earn_total earn_firm earn_person)=count_jobs sum_et sum_ft sum_pt;
run;

proc print data=dot.work_year_detail;
run; 
