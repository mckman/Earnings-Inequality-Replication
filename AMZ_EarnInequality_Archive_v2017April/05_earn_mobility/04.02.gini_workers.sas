**** Calculate the statistics needed for the genie ****;

%include "config.sas";


data worker_eligible(keep=pik y earn_we rename=(y=year)) /view=worker_eligible;
   set outputs.worker_eligible(keep=pik year year_first year_last all_real_earn);
      by pik;

   array ern{1990:2013} _TEMPORARY_ (24*0);

   if all_real_earn>0 then ern{year}=all_real_earn;

   if last.pik then do;
       do y=2004 to 2013;
          if (ern{y-4}+ern{y-3}+ern{y-2}+ern{y-1}+ern{y})>0
             and year_first<=y and year_last>=y then do;
                 earn_we=ern{y};
                 output;
          end;
       end;
       do y=year_first to year_last;
          ern{y}=0;
       end;
    end;
run;

data temp1;
   merge worker_eligible(in=a)
         outputs.pik_year_hc(in=b keep=pik year le_r lf_r lp_r earn_total earn_firm earn_person);
      by pik year;

   length _merge 3;

   _merge=a+2*b;

   if earn_we=0 then earn_we=.;
run;

proc tabulate data=temp1;
   class _merge year /missing;
   table _merge all, n*f=comma14.0 pctn;
   table year*(_merge all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<_merge all> pctn;
run;

proc summary data=temp1 nway;
   class year le_r /missing;
   output out=dot.gini_year0wk sum(earn_we)=sum_et;
run;
proc summary data=temp1 nway;
   class year le_r /missing;
   output out=dot.gini_year1wk sum(earn_total)=sum_et;
run;
proc summary data=temp1 nway;
   class year lf_r /missing;
   output out= dot.gini_year2wk sum(earn_firm)=sum_ft;
run;
proc summary data=temp1 nway;
   class year lp_r /missing;
   output out= dot.gini_year3wk sum(earn_person)=sum_pt;
run;

proc print data=dot.gini_year0wk;
   format sum_et COMMA22.0;
proc print data=dot.gini_year1wk;
   format sum_et COMMA22.0;
proc print data=dot.gini_year2wk;
   format sum_ft COMMA22.0;
proc print data=dot.gini_year3wk;
   format sum_pt COMMA22.0;
run;
