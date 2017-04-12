*** Calculate 5 year and 10 year rankings ***;

%include "config.sas";


data temp1p(keep=pik period earn5y earn10y age_start1 age_start2);
   set outputs.pik_year_elig_yrs(keep=pik year all_real_earn age1 age2);
      by pik;

   retain earn5y1 earn5y2 earn10y age_start1 age_start2;

   if first.pik then do;
      earn5y1=0;
      earn5y2=0;
      earn10y=0;
      age_start1=age1;
      age_start2=age2;
   end;

   if all_real_earn>0 then do;
      if year<=2008 then earn5y1=earn5y1+all_real_earn;
      else if year>2008 then earn5y2=earn5y2+all_real_earn;

      earn10y=earn10y+all_real_earn;
   end;

   if last.pik then do;
      if earn5y1=0 then earn5y1=.;
      if earn5y2=0 then earn5y2=.;
      if earn10y=0 then earn10y=.;
      period=1;
      earn5y=earn5y1;
      output;
      period=2;
      earn5y=earn5y2;
      output;
   end;
run;

proc rank data=temp1p out=temp2p groups=10;
   var earn5y earn10y;
   ranks e5y_r e10y_r;
run;

proc contents data=temp2p;
proc tabulate data=temp2p;
   class e5y_r e10y_r /missing;
   table e5y_r all, n*f=comma14.0 pctn;
   table e10y_r all, n*f=comma14.0 pctn;
run;
proc print data=temp2p(obs=100);
run;

data outputs.pik_elig_yrs_earn(drop=period earn5y er1 er2);
   set temp2p;

   length earn_type $3;

   earn5y1=lag(earn5y);
   e5y1_r=lag(e5y_r);

   if period=2 then do;
      earn5y2=earn5y;
      e5y2_r=e5y_r;
      if e5y1_r=. then er1=0;
      else if e5y1_r>=0 and e5y1_r<=1 then er1=2;
      else if e5y1_r>=2 and e5y1_r<=7 then er1=3;
      else if e5y1_r>=8 and e5y1_r<=9 then er1=4;
      if e5y2_r=. then er2=0;
      else if e5y2_r>=0 and e5y2_r<=1 then er2=2;
      else if e5y2_r>=2 and e5y2_r<=7 then er2=3;
      else if e5y2_r>=8 and e5y2_r<=9 then er2=4;
      earn_type=put(er1,1.) || "_" || put(er2,1.);
      output;
    end;
run;

proc contents data=outputs.pik_elig_yrs_earn;
proc tabulate data=outputs.pik_elig_yrs_earn;
   class e5y1_r e5y2_r e10y_r earn_type /missing;
   table e5y1_r all, n*f=comma14.0 pctn;
   table e5y2_r all, n*f=comma14.0 pctn;
   table e10y_r all, n*f=comma14.0 pctn;
   table earn_type all, n*f=comma14.0 pctn;
run;

proc freq data=outputs.pik_elig_yrs_earn noprint;
   table earn_type /out=dot.elig10_pik;
run;

proc print data=dot.elig10_pik;
   format COUNT 15.0;
run;

proc corr data=outputs.pik_elig_yrs_earn;
   var earn5y1 earn5y2 earn10y;
run;
proc corr data=outputs.pik_elig_yrs_earn;
   var e5y1_r e5y2_r e10y_r;
run;
proc print data=outputs.pik_elig_yrs_earn(obs=100);
run;

data temp2(drop=er1 er2);
   merge outputs.pik_year_elig_yrs(drop=elig_yrs)
         outputs.pik_elig_yrs_earn;
      by pik;

   length et1_5_5 $5 et1_10 $3;

   if all_real_earn>0 then do;
      if year<=2008 then earn5y1mc=earn5y1-all_real_earn;
      else earn5y1mc=earn5y1;

      if year>2008 then earn5y2mc=earn5y2-all_real_earn;
      else earn5y2mc=earn5y2;

      earn10ymc=earn10y-all_real_earn;
   end;

   if le_r=. then er1=0;
   else if le_r>=0 and le_r<=1 then er1=2;
   else if le_r>=2 and le_r<=7 then er1=3;
   else if le_r>=8 and le_r<=9 then er1=4;

   et1_5_5=put(er1,1.) || "_" || earn_type;
   
   if e10y_r=. then er2=0;
   else if e10y_r>=0 and e10y_r<=1 then er2=2;
   else if e10y_r>=2 and e10y_r<=7 then er2=3;
   else if e10y_r>=8 and e10y_r<=9 then er2=4;

   et1_10=put(er1,1.) || "_" || put(er2,1.);
   
run;

proc contents data=temp2;
proc corr data=temp2(where=(year<=2008));
   var le_r e5y1_r e5y2_r e10y_r;
run;
proc corr data=temp2(where=(year>2008));
   var le_r e5y1_r e5y2_r e10y_r;
run;
proc corr data=temp2;
   var le_r e5y1_r e5y2_r e10y_r;
run;
proc corr data=temp2(where=(year<=2008));
   var all_real_earn earn5y1 earn5y2 earn10y;
run;
proc corr data=temp2(where=(year>2008));
   var all_real_earn earn5y1 earn5y2 earn10y;
run;
proc corr data=temp2;
   var all_real_earn earn5y1 earn5y2 earn10y;
run;
proc corr data=temp2(where=(year<=2008));
   var all_real_earn earn5y1mc earn5y2mc earn10ymc;
run;
proc corr data=temp2(where=(year>2008));
   var all_real_earn earn5y1mc earn5y2mc earn10ymc;
run;
proc corr data=temp2;
   var all_real_earn earn5y1mc earn5y2mc earn10ymc;
run;

proc freq data=temp2 noprint;
   table year*et1_5_5 /out=dot.elig1_5_5_year;
   table year*et1_10 /out=dot.elig1_10_year;
run;

proc print data=dot.elig1_5_5_year;
   format COUNT 15.0;
run;
proc print data=dot.elig1_10_year;
   format COUNT 15.0;
run;

proc print data=temp2(obs=100);
run;
