*** Simple two way anova ***;

%include "config.sas";


proc glm data=outputs.pik_year_hc;
   class lf_r lp_r;
   model earn_total=lf_r lp_r lf_r*lp_r;
run;

proc glm data=outputs.pik_year_hc;
   class lf_r lp_r;
   model ln_earn_alljobs=lf_r lp_r lf_r*lp_r;
run;
