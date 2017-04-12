*** Calculate the Gini Hoover and Theil (symmetric) inequality indices ***;
*** Formulas from the Income Inequality Metrics Wiki Page              ***;

%include "config.sas";

data temp0;
   merge dot.gini_year0wk(drop=_TYPE_) dot.hc_year1(keep=year le_r COUNT);
      by year le_r;
run;

proc print data=temp0;
run;

*** All Eligible Workers ***;

title "All Eligible Workers";

data temp1(drop=a_sum e_sum) temp1m(keep=year a_sum e_sum);
   set temp0;
      by year;
 
   retain a_sum e_sum k_i_sum e_i_avg;

   if first.year then do;
      a_sum=0;
      e_sum=0;
      k_i_sum=0;
   end;

   if le_r=. then do;
      sum_et=COUNT;
      k_i_sum=sum_et;
   end;
   else do;
      k_i_sum=k_i_sum+sum_et;
   end;

   a_sum=a_sum+COUNT;
   e_sum=e_sum+sum_et;
   e_i_avg=sum_et/COUNT;

   if last.year then output temp1m;
   output temp1;
run;

proc print data=temp1;
proc print data=temp1m;
run;

data temp2;
   merge temp1 temp1m;
      by year;

   rdev_i=(sum_et/e_sum)-(COUNT/a_sum);

   gini_i=(2*k_i_sum-sum_et)*COUNT;
   hoov_i=abs(rdev_i);
   theil_i=log(e_i_avg)*rdev_i;
run;

proc print data=temp2;
run;

proc summary data=temp2 nway;
   class year;
   output out=temp3 sum(COUNT sum_et gini_i hoov_i theil_i)=a_sum e_sum gini hoov theil;
run;

data all_workers(keep=year a_sum gini hoov theil);
   set temp3;

   gini=1-(gini/a_sum/e_sum);
   hoov=hoov/2;
   theil=theil/2;
run;
   
proc print data=all_workers;
run;

*** Workers with Earnings in the past five years (including the current year) ***;

title "Workers with Earnings in the past five years (including the current year)";

data temp1(drop=a_sum e_sum) temp1m(keep=year a_sum e_sum);
   set temp0;
      by year;

   retain a_sum e_sum k_i_sum e_i_avg;

   if first.year then do;
      a_sum=0;
      e_sum=0;
      k_i_sum=0;
   end;

   if le_r=. then do;
      sum_et=_FREQ_;
      k_i_sum=sum_et;
   end;
   else do;
      k_i_sum=k_i_sum+sum_et;
   end;

   a_sum=a_sum+_FREQ_;
   e_sum=e_sum+sum_et;
   e_i_avg=sum_et/_FREQ_;

   if last.year then output temp1m;
   output temp1;
run;

proc print data=temp1;
proc print data=temp1m;
run;

data temp2;
   merge temp1 temp1m;
      by year;

   rdev_i=(sum_et/e_sum)-(_FREQ_/a_sum);

   gini_i=(2*k_i_sum-sum_et)*_FREQ_;
   hoov_i=abs(rdev_i);
   theil_i=log(e_i_avg)*rdev_i;
run;

proc print data=temp2;
run;

proc summary data=temp2 nway;
   class year;
   output out=temp3 sum(_FREQ_ sum_et gini_i hoov_i theil_i)=a_sum e_sum gini hoov theil;
run;

data most_workers(keep=year a_sum gini hoov theil);
   set temp3;

   gini=1-(gini/a_sum/e_sum);
   hoov=hoov/2;
   theil=theil/2;
run;

proc print data=most_workers;
run;


*** Only workers with positive earnings (current year) ***;

title "Only workers with positive earnings (current year)";

data tempw;
   set temp0;

   if le_r>. then output;
run;

data temp1(drop=a_sum e_sum) temp1m(keep=year a_sum e_sum);
   set tempw;
      by year;

   retain a_sum e_sum k_i_sum e_i_avg;

   if first.year then do;
      a_sum=0;
      e_sum=0;
      k_i_sum=0;
   end;

   if le_r=. then do;
      sum_et=_FREQ_;
      k_i_sum=sum_et;
   end;
   else do;
      k_i_sum=k_i_sum+sum_et;
   end;

   a_sum=a_sum+_FREQ_;
   e_sum=e_sum+sum_et;
   e_i_avg=sum_et/_FREQ_;

   if last.year then output temp1m;
   output temp1;
run;

proc print data=temp1;
proc print data=temp1m;
run;

data temp2;
   merge temp1 temp1m;
      by year;

   rdev_i=(sum_et/e_sum)-(_FREQ_/a_sum);

   gini_i=(2*k_i_sum-sum_et)*_FREQ_;
   hoov_i=abs(rdev_i);
   theil_i=log(e_i_avg)*rdev_i;
run;

proc print data=temp2;
run;

proc summary data=temp2 nway;
   class year;
   output out=temp3 sum(_FREQ_ sum_et gini_i hoov_i theil_i)=a_sum e_sum gini hoov theil;
run;

data workers(keep=year a_sum gini hoov theil);
   set temp3;

   gini=1-(gini/a_sum/e_sum);
   hoov=hoov/2;
   theil=theil/2;
run;

proc print data=workers;
run;
