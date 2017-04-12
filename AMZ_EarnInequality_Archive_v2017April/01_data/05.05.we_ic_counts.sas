*** Sample Counts by Year ***;

%include "config.sas";

options nospool nolabel ps=1000 obs=max;


*** Worker Eligible and Immigrant Candidates ***;

data temp0;
   set outputs.worker_eligible
       outputs.immig_cand;

   length regime age1 age2 active 3;

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
run;

title "Worker Eligible and Immigrant Candidates by Year";
proc summary data=temp0 nway;
   class year;
   output out=temp0p1(drop=_FREQ_) n(active)=we_ic_total;
run;

proc summary data=temp0(where=(regime~=9)) nway;
   class year;
   output out=temp0p2(drop=_FREQ_) sum(active)=we_ic_active sum(num_jobs)=we_ic_jobs;
run;

data temp0p3;
   merge temp0p1 temp0p2;
      by year;

   we_ic_inactive=we_ic_total-we_ic_active;
run;

proc print data=temp0p3;
   format we_ic_total we_ic_inactive we_ic_active we_ic_jobs 18.0;
   var year we_ic_total we_ic_inactive we_ic_active we_ic_jobs;
run;

*** Worker Eligible Only ***;

data temp0;
   set outputs.worker_eligible;

   length regime age1 age2 active 3;

   /* State Sampling Regimes */;
   regime=9;
   if state in ("MD","AK","CO","ID","IL","IN","KS","LA","MO","WA","WI") and year>=1990 then regime=1;
   else if state in ("NC","OR","PA","CA","AZ","WY","FL","MT","GA","SD","MN","NY","RI","TX") and year>=1995 then regime=2;
   else if state in ("NM","HI","CT","ME","NJ","KY","WV","MI","NV","ND","SC","TN","VA") and year>=1998 then regime=3;
   else if state in ("DE","IA","NE","UT","OH","OK","VT","AL","MA","DC","AR","NH","MS") and year>=2004 then regime=4;

   if dom_real_earn>0 then l_dom=log(dom_real_earn);
   if all_real_earn>0 then l_all=log(all_real_earn);

   age1=floor((mdy(1,1,year)-DOB)/365.2425);
   age2=floor((mdy(12,31,year)-DOB)/365.2425);

   active=num_jobs>0;
run;

title "Worker Eligible by Year";
proc summary data=temp0 nway;
   class year;
   output out=temp0p1(drop=_FREQ_) n(active)=we_total;
run;

proc summary data=temp0(where=(regime~=9)) nway;
   class year;
   output out=temp0p2(drop=_FREQ_) sum(active)=we_active sum(num_jobs)=we_jobs;
run;

data temp0p3;
   merge temp0p1 temp0p2;
      by year;

   we_inactive=we_total-we_active;
run;

proc print data=temp0p3;
   format we_total we_inactive we_active we_jobs 18.0;
   var year we_total we_inactive we_active we_jobs;
run;

*** Immigrant Candidates ***;

data temp1;
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
      if age2<5 then ic_type=2;
      else if age2<13 then ic_type=3;
      else if age2<18 then ic_type=4;
      else if age1>70 then ic_type=5;
      else if num_jobs>12 then ic_type=6;
      else ic_type=7;
   end;
run;

title "Immigrant Candidate by Year";
proc summary data=temp1(where=(regime~=9)) nway;
   class year;
   output out=temp1p(drop=_FREQ_) sum(active)=ic_active sum(num_jobs)=ic_jobs;
run;

proc print data=temp1p;
   format ic_active ic_jobs 18.0;
   var year ic_active ic_jobs;
run;

title "Immigrant Candidate by Type and Year";
proc summary data=temp1(where=(regime~=9)) nway;
   class year ic_type;
   output out=temp1p2(drop=_FREQ_) sum(active)=ic_active sum(num_jobs)=ic_jobs;
run;

proc transpose data=temp1p2 out=temp1p3 prefix=ic_active_;
   by year;
   id ic_type;
   var ic_active;
run;

proc print data=temp1p3;
   format ic_active_1 ic_active_2 ic_active_3 ic_active_4 ic_active_5 ic_active_6 ic_active_7 14.0;
   var year ic_active_1 ic_active_2 ic_active_3 ic_active_4 ic_active_5 ic_active_6 ic_active_7;
run;

proc transpose data=temp1p2 out=temp1p4 prefix=ic_jobs_;
   by year;
   id ic_type;
   var ic_jobs;
run;

proc print data=temp1p4;
   format ic_jobs_1 ic_jobs_2 ic_jobs_3 ic_jobs_4 ic_jobs_5 ic_jobs_6 ic_jobs_7 14.0;
   var year ic_jobs_1 ic_jobs_2 ic_jobs_3 ic_jobs_4 ic_jobs_5 ic_jobs_6 ic_jobs_7;
run;
