*** Create counts for each category ***;

%include "config.sas";

options obs=max;

proc summary data=dot.work_year_detail nway;
   class et num_qtrs long_job;
   output out=temp1(drop=_TYPE_) sum(count count_jobs sum_et sum_ft sum_pt)=wkrs jobs s_et s_ft s_pt;
run;

data temp2;
   set temp1;
   avg_wkrs=round(wkrs/10);
   avg_jobs=jobs/wkrs;
   avg_et=round(s_et/wkrs);
   avg_ft=round(s_ft/wkrs);
   avg_pt=round(s_pt/wkrs);

   pct_ft=avg_ft/avg_et;
run;

proc print data=temp2(drop=jobs s_et s_ft s_pt);
   format wkrs avg_wkrs avg_et avg_ft avg_pt COMMA14.0;
run; 
