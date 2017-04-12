*** Employment to Population Ratios for the UI ***;

%include "config.sas";

/* Output Dataset */;
%let ofile=dot.regimes_ep_&vshort._we;

data indat(keep=pik year regime);
   set outputs.worker_eligible;

   length regime active 3;

   /* State Sampling Regimes */;
   regime=9;
   if state in ("MD","AK","CO","ID","IL","IN","KS","LA","MO","WA","WI") and year>=1990 then regime=1;
   else if state in ("NC","OR","PA","CA","AZ","WY","FL","MT","GA","SD","MN","NY","RI","TX") and year>=1995 then regime=2;
   else if state in ("NM","HI","CT","ME","NJ","KY","WV","MI","NV","ND","SC","TN","VA") and year>=1998 then regime=3;
   else if state in ("DE","IA","NE","UT","OH","OK","VT","AL","MA","DC","AR","NH","MS") and year>=2004 then regime=4;

   if dom_real_earn>0 then l_dom=log(dom_real_earn);
   if all_real_earn>0 then l_all=log(all_real_earn);

   active=num_jobs>0;
run;

/* Calculate the EP Ratio */;

title "Employment Population Ratio Worker Eligible All Regimes";
proc freq data=indat;
   tables year*regime /noprint out=temp1;
run;

proc transpose data=temp1(keep=year regime COUNT) out=temp_reg prefix=reg;
   by year;
   id regime;
   var COUNT;
run;

data &ofile;
   set temp_reg(drop=_NAME_ _LABEL_);

   we_total=sum(reg1,reg2,reg3,reg4,reg9);
   we_active=sum(reg1,reg2,reg3,reg4);

   we_ratio=we_active/we_total;

   if reg1>0 then we_ep_ratio_1=reg1/we_total;
   if reg2>0 then we_ep_ratio_2=reg2/we_total;
   if reg3>0 then we_ep_ratio_3=reg3/we_total;
   if reg4>0 then we_ep_ratio_4=reg4/we_total;
run;

proc print data=&ofile;
run;
