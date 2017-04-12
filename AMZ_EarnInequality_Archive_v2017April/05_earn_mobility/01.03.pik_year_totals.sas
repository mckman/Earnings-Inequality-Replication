*** Merge with WE to get the periods where a worker is eligible but not working ***;

%include "config.sas";

data worker_eligible /view=worker_eligible;
   set outputs.worker_eligible(in=a keep=pik year);

   if year>=2004 then output;
run;

data temp1;
   merge worker_eligible(in=a)
         outputs.pik_year_hc(in=b keep=pik year le_r lf_r lp_r ls_r);
      by pik year;

   length _merge 3;

   _merge=a+2*b;
run;

proc tabulate data=temp1;
   class _merge year le_r lf_r lp_r ls_r /missing;
   table _merge all, n*f=comma14.0 pctn;
   table year*(le_r all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<le_r all> pctn;
   table year*(lf_r all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<lf_r all> pctn;
   table year*(lp_r all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<lp_r all> pctn;
   table year*(ls_r all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<ls_r all> pctn;
run;

proc freq data=temp1;
   tables year*le_r /out=dot.hc_year1;
   tables year*lf_r /out=dot.hc_year2;
   tables year*lp_r /out=dot.hc_year3;
   tables year*ls_r /out=dot.hc_year4;
run;
