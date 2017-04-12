*** Attach earnings to the transitions ***;

%include "config.sas";


data temp0(keep=pik year all_real_earn);
   set outputs.worker_eligible;

   /* State Sampling Regimes */;
   regime=9;
   if state in ("MD","AK","CO","ID","IL","IN","KS","LA","MO","WA","WI") and year>=1990 then regime=1;
   else if state in ("NC","OR","PA","CA","AZ","WY","FL","MT","GA","SD","MN","NY","RI","TX") and year>=1995 then regime=2;
   else if state in ("NM","HI","CT","ME","NJ","KY","WV","MI","NV","ND","SC","TN","VA") and year>=1998 then regime=3;
   else if state in ("DE","IA","NE","UT","OH","OK","VT","AL","MA","DC","AR","NH","MS") and year>=2004 then regime=4;

   if regime~=9 and year>=2004 then output;
run;

data temp1;
   merge outputs.pik_year_hc(in=a keep=pik year earn_total earn_firm earn_person)
       temp0(in=b);
      by pik year;

   length _merge 3;

   _merge=a+2*b;

   if all_real_earn>0 and earn_total>0 then ediff=all_real_earn-earn_total;
run;

proc contents data=temp1;
proc tabulate data=temp1;
   class _merge /missing;
   table _merge all, n*f=comma14.0 pctn;
run;

proc summary data=temp1 nway;
   class year;
   output out=temp1s sum(all_real_earn earn_total ediff)=earn_we earn_hc earn_diff;
run;

proc print data=temp1s;
   format earn_we earn_hc earn_diff comma24.0;
run;


data outputs.pik_year_hc_earn(keep=pik year year1_total--year2_person);
   set temp1;
      by pik;

   retain year_first year_last;

   array wt{2004:2013} _TEMPORARY_;
   array et{2004:2013} _TEMPORARY_;
   array ft{2004:2013} _TEMPORARY_;
   array pt{2004:2013} _TEMPORARY_;

   if first.pik then do;
      year_first=year;
   end;

   wt{year}=all_real_earn;
   et{year}=earn_total;
   ft{year}=earn_firm;
   pt{year}=earn_person;

   if last.pik then do;
      year_last=year;

      if year_first<=2005 then year_start=2005;
      else year_start=year_first;

      if year_last>=2013 then year_end=2013;
      else year_end=year_last+1;

      do y=year_start to year_end;
         year1_total=wt{y-1};
         year2_total=wt{y};
         year1_firm=ft{y-1}+(ft{y-1}/et{y-1})*(wt{y-1}-et{y-1});
         year2_firm=ft{y}+(ft{y}/et{y})*(wt{y}-et{y});
         year1_person=pt{y-1}+(pt{y-1}/et{y-1})*(wt{y-1}-et{y-1});
         year2_person=pt{y}+(pt{y}/et{y})*(wt{y}-et{y});
         year=y;
         output;
     end;
         
      do y=year_first to year_last;
         wt{y}=.;
         et{y}=.;
         ft{y}=.;
         pt{y}=.;
      end;
   end;
run;

proc contents data=outputs.pik_year_hc_earn;

proc summary data=outputs.pik_year_hc_earn nway;
   class year;
   output out=sum2
   sum(year1_total year2_total year1_firm year2_firm year1_person year2_person)=
       year1t year2t year1f year2f year1p year2p;
run;

proc print data=sum2;
   format year1t year2t year1f year2f year1p year2p COMMA22.0;
run;

proc print data=outputs.pik_year_hc_earn(obs=1000);
run;
