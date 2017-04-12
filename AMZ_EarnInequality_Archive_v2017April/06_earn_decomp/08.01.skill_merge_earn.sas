*** Attach earnings to the transitions ***;

%include "config.sas";

data temp1;
   merge outputs.pik_year_hc_dist(in=a)
         outputs.pik_year_hc_earn(in=b);
      by pik year;
run;

proc summary data=temp1 nway;
   class firm_type skill_type earn_type;
   output out=dot.hc_ft_st_et sum(year1_total year1_firm year1_person year2_total year2_firm year2_person)=sum1_et sum1_ft sum1_pt sum2_et sum2_ft sum2_pt;
run;

proc print data=dot.hc_ft_st_et;
   format sum1_et sum1_ft sum1_pt sum2_et sum2_ft sum2_pt COMMA22.0;
run;

