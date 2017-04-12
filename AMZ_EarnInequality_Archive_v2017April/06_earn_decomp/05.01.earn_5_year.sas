*** Calculate 5 year and 10 year rankings ***;

%include "config.sas";


data temp0(keep=pik year all_real_earn age1 age2) /view=temp0;
   set outputs.worker_eligible;

   /* State Sampling Regimes */;
   regime=9;
   if state in ("MD","AK","CO","ID","IL","IN","KS","LA","MO","WA","WI") and year>=1990 then regime=1;
   else if state in ("NC","OR","PA","CA","AZ","WY","FL","MT","GA","SD","MN","NY","RI","TX") and year>=1995 then regime=2;
   else if state in ("NM","HI","CT","ME","NJ","KY","WV","MI","NV","ND","SC","TN","VA") and year>=1998 then regime=3;
   else if state in ("DE","IA","NE","UT","OH","OK","VT","AL","MA","DC","AR","NH","MS") and year>=2004 then regime=4;

   date1=mdy(1,1,year);
   date2=mdy(12,31,year);
   age1=floor((date1-DOB)/365.2425);
   age2=floor((date2-DOB)/365.2425);

   if year>=2004 then output;
run;

data temp1(drop=elig_yrs) temp1p(keep=pik elig_yrs);
   merge outputs.pik_year_hc(in=a keep=pik year le_r) temp0(in=b);
      by pik year;

   retain elig_yrs;

   length elig_yrs _merge 3;

   _merge=a+2*b;

   if first.pik then elig_yrs=0;

   elig_yrs=elig_yrs+1;

   if last.pik then output temp1p;
   output temp1;
run;

proc contents data=temp1;
proc tabulate data=temp1;
   class _merge /missing;
   table _merge all, n*f=comma14.0 pctn;
run;
proc contents data=temp1p;
proc tabulate data=temp1p;
   class elig_yrs /missing;
   table elig_yrs all, n*f=comma14.0 pctn;
run;
proc print data=temp1(obs=500);
proc print data=temp1(obs=500);
run;
proc print data=temp1p(obs=100);
run;

data temp3(keep=elig_yrs age1 age2) outputs.pik_year_elig_yrs;
   merge temp1(drop=_merge) temp1p;
      by pik;

   if elig_yrs=10 then output outputs.pik_year_elig_yrs;
   output temp3;
run;

proc contents data=outputs.pik_year_elig_yrs;
proc tabulate data=temp3;
   class elig_yrs /missing;
   table elig_yrs all, n*f=comma14.0 pctn;
run;
proc means data=temp3;
   class elig_yrs /missing;
   var age1 age2;
run;
proc print data=outputs.pik_year_elig_yrs(obs=500);
run;
