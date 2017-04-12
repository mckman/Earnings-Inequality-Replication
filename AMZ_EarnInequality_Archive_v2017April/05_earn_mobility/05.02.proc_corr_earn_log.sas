*** Calculate the proportion of total earnings variance due to the firm effect ***;

%include "config.sas";

options obs=10000;

proc corr data=outputs.pik_year_hc outp=temp1;
   var ln_earn_alljobs ln_firm_alljobs ln_person_alljobs;
run;

proc print data=temp1;
run;

data temp2;
   set temp1;

   retain N et_var ef_var ep_var ef_ep_var;

   if _N_=2 then do;
      et_var=ln_earn_alljobs*ln_earn_alljobs;
      ef_var=ln_firm_alljobs*ln_firm_alljobs;
      ep_var=ln_person_alljobs*ln_person_alljobs;
   end;

   if _N_=3 then do;
      N=ln_earn_alljobs;
   end;

   if _N_=5 then do;
      ef_ep_var=(ln_person_alljobs*sqrt((N-1)*ef_var)*sqrt((N-1)*ep_var))/(N-1);
   end;

   if _N_=6 then do;
      check_var=ef_var + ep_var + 2*ef_ep_var;
      pct_firm=ef_var/et_var;
      pct_person=ep_var/et_var;
      pct_covar=ef_ep_var/et_var;
   end;
run;

proc print data=temp2;
  *format  N et_var ef_var ep_var ef_ep_var check_var comma12.0;
run;
