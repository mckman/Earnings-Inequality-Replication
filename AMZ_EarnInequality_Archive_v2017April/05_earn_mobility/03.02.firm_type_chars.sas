*** Create a table of firm chars by firm type ***;

%include "config.sas";

options obs=max;

options nolabel;

proc format;

    value $ncsb

 "11" = "10"
 "21" = "10"
 "22" = "40"
 "23" = "20"
 "31" = "30"
 "32" = "30"
 "33" = "30"
 "42" = "40"
 "44" = "40"
 "45" = "40"
 "48" = "40"
 "49" = "40"
 "51" = "50"
 "52" = "55"
 "53" = "55"
 "54" = "60"
 "55" = "60"
 "56" = "60"
 "61" = "65"
 "62" = "65"
 "71" = "70"
 "72" = "70"
 "81" = "80"
 "92" = "90"
 other = " "
;
run;

data temp1;
   set outputs.pik_year_firm;

   length naics2 $2 naics_bls $2;

   naics2=substr(MODE_ES_NAICS_FNL2007_EMP,1,2);

   naics_bls=put(naics2,$ncsb.);

   firm_type=.;
   if lf_r>=0 and lf_r<=1 then firm_type=2;
   else if lf_r>=2 and lf_r<=7 then firm_type=3;
   else if lf_r>=8 and lf_r<=9 then firm_type=4;

   if firmsize>0 then ln_firmsize=log(firmsize);
run;

proc freq data=temp1 noprint;
   tables firm_type*naics_bls /out=dot.industry;
run;

proc print data=dot.industry;
   format count 14.0;
run;

proc freq data=temp1 noprint;
   weight wgt;
   tables firm_type*naics_bls /out=dot.industry2;
run;

proc print data=dot.industry;
   format count 14.0;
run;

proc means data=temp1 sumwgt mean stddev min p10 p25 median p75 p90 max;
   class firm_type /missing;
   var firmage firmsize ln_firmsize;
run;

proc means data=temp1 sumwgt mean stddev min p10 p25 median p75 p90 max;
   weight wgt;
   class firm_type /missing;
   var firmage firmsize ln_firmsize;
run;

proc print data=temp1(obs=1000);
run;

endsas;
