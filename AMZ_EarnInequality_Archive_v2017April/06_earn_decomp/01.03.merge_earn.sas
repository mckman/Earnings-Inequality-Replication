*** Attach earnings to the transitions ***;

%include "config.sas";


data temp1;
   merge outputs.pik_year_hc_dist(in=a)
         outputs.pik_year_hc_earn(in=b);
      by pik year;
run;

proc summary data=temp1 nway;
   class earn_type;
   output out=dot.hc_et sum(year1_total year1_firm year1_person year2_total year2_firm year2_person)=sum1_et sum1_ft sum1_pt sum2_et sum2_ft sum2_pt;
run;

proc print data=dot.hc_et;
   format sum1_et sum1_ft sum1_pt sum2_et sum2_ft sum2_pt COMMA22.0;
run;

proc summary data=temp1 nway;
   class firm_type;
   output out=dot.hc_ft sum(year1_total year1_firm year1_person year2_total year2_firm year2_person)=sum1_et sum1_ft sum1_pt sum2_et sum2_ft sum2_pt;
run;

proc print data=dot.hc_ft;
   format sum1_et sum1_ft sum1_pt sum2_et sum2_ft sum2_pt COMMA22.0;
run;

proc summary data=temp1 nway;
   class firm_type earn_type;
   output out=dot.hc_ft_et sum(year1_total year1_firm year1_person year2_total year2_firm year2_person)=sum1_et sum1_ft sum1_pt sum2_et sum2_ft sum2_pt;
run;

proc print data=dot.hc_ft_et;
   format sum1_et sum1_ft sum1_pt sum2_et sum2_ft sum2_pt COMMA22.0;
run;

proc summary data=temp1 nway;
   class firm_type person_type;
   output out=dot.hc_ft_pt sum(year1_total year1_firm year1_person year2_total year2_firm year2_person)=sum1_et sum1_ft sum1_pt sum2_et sum2_ft sum2_pt;
run;

proc print data=dot.hc_ft_pt;
   format sum1_et sum1_ft sum1_pt sum2_et sum2_ft sum2_pt COMMA22.0;
run;

proc summary data=temp1 nway;
   class firm_type person_type earn_type;
   output out=dot.hc_ft_pt_et sum(year1_total year1_firm year1_person year2_total year2_firm year2_person)=sum1_et sum1_ft sum1_pt sum2_et sum2_ft sum2_pt;
run;

proc print data=dot.hc_ft_pt_et;
   format sum1_et sum1_ft sum1_pt sum2_et sum2_ft sum2_pt COMMA22.0;
run;
