*** Estimate the firm component of earnings in dollars for each job ***;
*** and create two components of earnings: firm and everything else ***;

%include "config.sas";

data temp1(drop=ln_real_ann_earn psi);
   set outputs.pik_year_hc_all(rename=(h=ln_skill_alljobs));
      by pik year;

   label ln_skill_alljobs=;

   retain num_jobs earn_total earn_firm;
   length num_jobs 3;

   if first.year then do;
      num_jobs=0;
      earn_total=0;
      earn_firm=0;
   end;

   num_jobs=num_jobs+1;

   earn_total=earn_total+exp(ln_real_ann_earn);
   earn_firm=earn_firm+exp(ln_real_ann_earn)-exp(ln_real_ann_earn-psi);

   if last.year then do;
      earn_person=earn_total-earn_firm;
      ln_earn_alljobs=log(earn_total);
      ln_firm_alljobs=log(earn_total)-log(earn_total-earn_firm);
      ln_person_alljobs=ln_earn_alljobs-ln_firm_alljobs;
      output;
   end;
run;

proc contents;
proc means data=temp1 n mean min p10 p25 median p75 p90 max;
proc means data=temp1 n mean min p10 p25 median p75 p90 max;
   class year;
run;

proc rank data=temp1 out=outputs.pik_year_hc groups=10;
  var ln_earn_alljobs ln_person_alljobs ln_firm_alljobs ln_skill_alljobs;
  ranks le_r lp_r lf_r ls_r;
run;

proc contents;
proc means data=outputs.pik_year_hc n mean min max;
   class le_r;
   var earn_total earn_person earn_firm ln_earn_alljobs ln_person_alljobs ln_firm_alljobs ln_skill_alljobs;
run;
proc means data=outputs.pik_year_hc n mean min max;
   class lp_r;
   var earn_total earn_person earn_firm ln_earn_alljobs ln_person_alljobs ln_firm_alljobs ln_skill_alljobs;
run;
proc means data=outputs.pik_year_hc n mean min max;
   class lf_r;
   var earn_total earn_person earn_firm ln_earn_alljobs ln_person_alljobs ln_firm_alljobs ln_skill_alljobs;
run;
proc means data=outputs.pik_year_hc n mean min max;
   class ls_r;
   var earn_total earn_person earn_firm ln_earn_alljobs ln_person_alljobs ln_firm_alljobs ln_skill_alljobs;
run;
proc print data=outputs.pik_year_hc(obs=1000);
run;
