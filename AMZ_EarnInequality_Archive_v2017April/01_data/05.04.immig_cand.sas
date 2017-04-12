*** Produce some basic summary stats for the immigrant candidate file by year ***;

%include "config.sas";

proc contents data=outputs.immig_cand;
run;

options nospool nolabel obs=max;

data temp0;
   set outputs.immig_cand;

   length regime age1 age2 active ic_type 3;

   /* State Sampling Regimes */;
   regime=9;
   if state in ("MD","AK","CO","ID","IL","IN","KS","LA","MO","WA","WI") and year>=1990 then regime=1;
   else if state in ("NC","OR","PA","CA","AZ","WY","FL","MT","GA","SD","MN","NY","RI","TX") and year>=1995 then regime=2;
   else if state in ("NM","HI","CT","ME","NJ","KY","WV","MI","NV","ND","SC","TN","VA") and year>=1998 then regime=3;
   else if state in ("DE","IA","NE","UT","OH","OK","VT","AL","MA","DC","AR","NH","MS") and year>=2004 then regime=4;

   if dom_real_earn>0 then l_dom=log(dom_real_earn);
   if all_real_earn>0 then l_all=log(all_real_earn);

   if DOB~=. then age1=floor((mdy(1,1,year)-DOB)/365.2425);
   if DOB~=. then age2=floor((mdy(12,31,year)-DOB)/365.2425);

   active=num_jobs>0;

   ic_type=9;
   if source=2 then ic_type=1;
   else if source=3 then do;
      if age2<18 then ic_type=2;
      else if age1>70 then ic_type=3;
      else if num_jobs>12 then ic_type=4;
      else ic_type=5;
   end;
run;

proc tabulate data=temp0;
   class active year state active ic_type regime /missing;
   table active all, n*f=comma14.0 pctn;
   table year all, n*f=comma14.0 pctn;
   table state all, n*f=comma14.0 pctn;
   table ic_type all, n*f=comma14.0 pctn;
   table regime all, n*f=comma14.0 pctn;
   table year*(regime all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<regime all> pctn;
   table year*(ic_type all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<ic_type all> pctn;
run;

proc means data=temp0(where=(regime~=9)) n mean min p25 median p75 max;
   class ic_type;
   var age1 age2 num_jobs contribution dom_real_earn all_real_earn l_dom l_all;
run;

proc print data=temp0(obs=10000);
run;
