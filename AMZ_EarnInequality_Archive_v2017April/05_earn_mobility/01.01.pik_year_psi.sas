*** Estimate the firm component of earnings in dollars for each job ***;
*** and create two components of earnings: firm and everything else ***;

%include "config.sas";

data temp1;
   set hcall.hcest2(keep=pik sein year ln_real_ann_earn psi h where=(year>=2004));
run;

proc sort data=temp1 out=outputs.pik_year_hc_all; 
   by pik year;
run;

proc tabulate data=outputs.pik_year_hc_all;
   class year /missing;
   table year all, n*f=comma14.0 pctn;
run;

proc print data=outputs.pik_year_hc_all(obs=1000);
run;
