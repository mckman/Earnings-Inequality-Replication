*** Get the UI data and variables needed ***;

%include "config.sas";
%include "pik2full.sas";

%let obsv=max;

%let uivars=pik year real_ann_earn dominant num_jobs contribution state;

data temp0(drop=dominant);
   %sline(lib=ui,data=analysis_dataset,keepvars=&uivars,type=0);

   if dominant=1 then output;
run;

proc sort data=temp0 out=outputs.uipikyear;
   by pik year;
run;

proc contents data=outputs.uipikyear;
proc freq data=outputs.uipikyear;
   tables num_jobs;
run;
proc means data=outputs.uipikyear n mean min p1 p5 p10 p25 median max;
   class num_jobs;
   var contribution;
run;
proc means data=outputs.uipikyear n mean min p50 p75 p90 p95 p99 max;
   class year;
   var num_jobs;
run;
proc print data=outputs.uipikyear(obs=100);
run;
