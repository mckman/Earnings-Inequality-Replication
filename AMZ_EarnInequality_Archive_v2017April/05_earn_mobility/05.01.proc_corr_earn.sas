*** Calculate the proportion of total earnings variance due to the firm effect ***;

%include "config.sas";


proc corr data=outputs.pik_year_hc outp=temp1;
   var earn_total earn_firm earn_person;
run;

proc print data=temp1;
run;

data temp2;
   set temp1;

   retain N et_var ef_var ep_var ef_ep_var;

   if _N_=2 then do;
      et_var=earn_total*earn_total;
      ef_var=earn_firm*earn_firm;
      ep_var=earn_person*earn_person;
   end;

   if _N_=3 then do;
      N=earn_total;
   end;

   if _N_=5 then do;
      ef_ep_var=(earn_person*sqrt((N-1)*ef_var)*sqrt((N-1)*ep_var))/(N-1);
   end;

   if _N_=6 then do;
      check_var=ef_var + ep_var + 2*ef_ep_var;
      pct_firm=ef_var/et_var;
      pct_person=ep_var/et_var;
      pct_covar=2*ef_ep_var/et_var;
      check_pct=pct_firm + pct_person + pct_covar;
      adj_firm=(pct_firm+0.5*pct_covar);
      adj_person=(pct_person+0.5*pct_covar);
   end;
run;

proc print data=temp2;
  *format  N et_var ef_var ep_var ef_ep_var check_var comma12.0;
run;
