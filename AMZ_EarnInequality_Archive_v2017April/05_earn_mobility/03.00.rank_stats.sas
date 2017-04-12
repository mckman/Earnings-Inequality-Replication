*** Get the min and max values for each rank bin ***;

%include "config.sas";

options obs=max;


proc means data=outputs.pik_year_hc n mean min median max;
   class le_r;
   var earn_total ln_earn_alljobs;
run;

proc means data=outputs.pik_year_hc n mean min median max;
   class lf_r;
   var earn_firm ln_firm_alljobs;
run;

proc means data=outputs.pik_year_hc n mean min median max;
   class lp_r;
   var earn_person ln_person_alljobs;
run;
