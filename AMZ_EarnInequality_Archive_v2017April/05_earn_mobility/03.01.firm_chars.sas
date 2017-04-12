*** Get Firm Characteristics ***;

%include "config.sas";
%include "pik2short.sas";

**options obs=10000;
**%let obsv=10000;

options nolabel;

%let ecfvars=pik sein year mode_es_naics_fnl2007_emp firmage firmsize;

data merge_both(keep=pik year sein wgt) mergeit(keep=_merge);
   merge outputs.pik_year_hc_all(in=a keep=pik year sein ln_real_ann_earn)
         outputs.pik_year_hc(in=b keep=pik year ln_earn_alljobs);
      by pik year;

   length _merge 3;

   _merge=a+2*b;

   wgt=exp(ln_real_ann_earn)/exp(ln_earn_alljobs);

   if a=1 and b=1 then output merge_both;
   output mergeit;
run;

proc contents data=merge_both;
proc tabulate data=mergeit;
   class _merge /missing;
   table _merge all, n*f=comma14.0 pctn;
run;
proc means data=merge_both;
   var wgt;
run;

data ecf_stack;
   %sline(lib=out_ecf,data=ecf_final_pik,keepvars=&ecfvars,type=1);
run;

proc sort data=ecf_stack nodupkey;
   by pik year sein;
run;

data merge_firm(drop=_merge) mergeit(keep=_merge);
   merge merge_both(in=a) ecf_stack(in=b);
      by pik year sein;

   length _merge 3;

   _merge=a+2*b;

   if a=1 then output;
run;

proc contents data=merge_firm;
proc tabulate data=mergeit;
   class _merge /missing;
   table _merge all, n*f=comma14.0 pctn;
run;
proc tabulate data=merge_firm;
   class mode_es_naics_fnl2007_emp /missing;
   table mode_es_naics_fnl2007_emp all, n*f=comma14.0 pctn;
run;
proc means data=merge_firm;
   var wgt firmage firmsize;
run;

data outputs.pik_year_firm(drop=_merge) mergeit(keep=_merge);
   merge merge_firm(in=a) outputs.pik_year_hc(in=b keep=pik year le_r lp_r lf_r);
      by pik year;

   length _merge 3;

   _merge=a+2*b;
run;

proc contents data=outputs.pik_year_firm;
proc tabulate data=mergeit;
   class _merge /missing;
   table _merge all, n*f=comma14.0 pctn;
run;
proc tabulate data=outputs.pik_year_firm;
   class mode_es_naics_fnl2007_emp /missing;
   table mode_es_naics_fnl2007_emp all, n*f=comma14.0 pctn;
run;
proc means data=outputs.pik_year_firm;
   var wgt firmage firmsize;
run;
proc print data=outputs.pik_year_firm(obs=1000);
run;
