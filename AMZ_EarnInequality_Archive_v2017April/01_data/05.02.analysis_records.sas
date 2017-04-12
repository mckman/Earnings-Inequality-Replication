/* Break the data into two analysis datasets */;
/* One dataset contains all eligible workers aged 18-70 */;
/* The other file contains immigrant candidates */;

%include "config.sas";

%let maxjob=12;

options obs=max;

/* Subset the Numident records ignoring SSNs that never appear on the UI */;
data temp0 /view=temp0;
   set outputs.cnum_strip3(where=(not(source=1))
                           keep=pik source eligible DOB gender pcf_race POB ssn3st pcf_st year_first year_last);
run;

data temp1(drop=_merge real_ann_earn) check(keep=source _merge);
   merge temp0(in=a) outputs.uipikyear(in=b);
      by pik;

   length _merge 3 dom_real_earn all_real_earn avg_real_earn 6 contribution 4;

   if real_ann_earn~=. then do;
      dom_real_earn=round(real_ann_earn);
      all_real_earn=round(real_ann_earn/contribution);
      avg_real_earn=round(all_real_earn/num_jobs);
   end;

   _merge=a+2*b;
run;

proc contents data=temp1;
proc tabulate data=check;
   class source _merge /missing;
   table source all, n*f=comma14.0 pctn;
   table _merge all, n*f=comma14.0 pctn;
   table source*(_merge all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<_merge all> pctn;
run;
proc print data=temp1(obs=100);
run;

/* Select records for the two analysis files */;
data worker_eligible immig_cand;
   set temp1;
      by pik;

   if source=2 then output immig_cand;
   else if source=3 and eligible=0 then output immig_cand;
   else if source=3 and eligible=1 then do;
      if  num_jobs~=. and num_jobs>&maxjob then output immig_cand;
      else output worker_eligible;
   end;
run;

proc tabulate data=worker_eligible;
   class source eligible num_jobs /missing;
   table source all, n*f=comma14.0 pctn;
   table eligible all, n*f=comma14.0 pctn;
   table source*(eligible all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<eligible all> pctn;
   table num_jobs all, n*f=comma14.0 pctn;
run;
proc tabulate data=immig_cand;
   class source eligible num_jobs /missing;
   table source all, n*f=comma14.0 pctn;
   table eligible all, n*f=comma14.0 pctn;
   table source*(eligible all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<eligible all> pctn;
   table num_jobs all, n*f=comma14.0 pctn;
run;
proc contents data=worker_eligible;
proc print data=worker_eligible(obs=100);
proc contents data=immig_cand;
proc print data=immig_cand(obs=100);
run;

/* Add the records for workers that are eligible but never appear on the UI */;
data temp0(drop=i) /view=temp0;
   set outputs.cnum_strip3(where=(source=1 and eligible=1)
                           keep=pik source eligible DOB gender pcf_race POB ssn3st pcf_st year_first year_last);
   length year 3;

   do i=year_first to year_last;
      year=i;
      output;
   end;
run;

/* Add records for years a worker is eligible but not working */
/* Move records to immig candidate file when the worker is out of the age range */;    
data temp1(drop=i) inactive(drop=i) out_of_range(drop=i);
   set worker_eligible temp0; 
      by pik year;

   array yra{1990:2013} _TEMPORARY_;

   if first.pik then do;
      do i=1990 to 2013;
         yra{i}=0;
      end;
   end;

   if year>=year_first and year<=year_last then do;
      yra{year}=1;
      output temp1;
   end;
   else do;
      output out_of_range;
   end;

   if last.pik then do;
      do i=year_first to year_last;
         if yra{i}=0 then do;
            year=i;
            num_jobs=.;
            contribution=.;
            state=" ";
            dom_real_earn=.;
            all_real_earn=.;
            avg_real_earn=.;
            output inactive;
         end;
      end;
   end;
run;

proc contents data=temp1;
proc print data=temp1(obs=200);
proc contents data=inactive;
proc print data=inactive(obs=100);
proc contents data=out_of_range;
proc print data=out_of_range(obs=100);
run;

/* Create the worker_eligible file */;

data outputs.worker_eligible;
   set temp1 inactive;
      by pik year;
run;

proc contents data=outputs.worker_eligible;
proc tabulate data=outputs.worker_eligible;
   class source eligible num_jobs /missing;
   table source all, n*f=comma14.0 pctn;
   table eligible all, n*f=comma14.0 pctn;
   table source*(eligible all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<eligible all> pctn;
run;
proc print data=outputs.worker_eligible(obs=200);
run;

/* Create the immigrant candidate file */;

data outputs.immig_cand;
   set immig_cand out_of_range;
      by pik;
run;

proc contents data=outputs.immig_cand;
proc tabulate data=outputs.immig_cand;
   class source eligible num_jobs /missing;
   table source all, n*f=comma14.0 pctn;
   table eligible all, n*f=comma14.0 pctn;
   table source*(eligible all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<eligible all> pctn;
run;
proc print data=outputs.immig_cand(obs=100);
run;
