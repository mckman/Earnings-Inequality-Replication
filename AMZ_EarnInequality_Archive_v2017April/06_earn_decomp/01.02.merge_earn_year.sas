*** Attach earnings to the transitions ***;

%include "config.sas";


data temp1;
   merge outputs.pik_year_hc_dist(in=a)
         outputs.pik_year_hc_earn(in=b);
      by pik year;
run;

proc summary data=temp1 nway;
   class year earn_type;
   output out=dot.hc_earn_type sum(year1_total year2_total)=sum1_et sum2_et;
run;

proc print data=dot.hc_earn_type;
   format sum1_et sum2_et COMMA22.0;
run;

proc summary data=temp1 nway;
   class year firm_type;
   output out=dot.hc_firm_type sum(year1_firm year2_firm)=sum1_ft sum2_ft;
run;

proc print data=dot.hc_firm_type;
   format sum1_ft sum2_ft COMMA22.0;
run;

proc summary data=temp1 nway;
   class year person_type;
   output out=dot.hc_person_type sum(year1_person year2_person)=sum1_pt sum2_pt;
run;

proc print data=dot.hc_person_type;
   format sum1_pt sum2_pt COMMA22.0;
run;
