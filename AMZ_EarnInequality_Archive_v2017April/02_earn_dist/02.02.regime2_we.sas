*** Earnings Distributions for the UI (WORKER ELIGIBLE) ***;

%include "config.sas";

/* Regime to Use */;
%let regime=2;

/* Variable to Use (see config.sas) */;

/* Output Dataset */;
%let ofile=dot.regime&regime._&vshort._we;

/* fvarb=Name of first variable in the bottom of the bin percentile list */
/* evarb=Name of the last variable in the bottom of the bin percentile list */
/* fvart=Name of first variable in the top of the bin percentile list */
/* evart=Name of the last variable in the top of the bin percentile list */;
%let fvarb=pe_0_9;
%let evarb=pe_98_9;
%let fvart=pe_1_1;
%let evart=pe_99_1;

data indat(keep=pik year &vlong  l_&vshort);
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

   if regime=&regime then output;
run;

/* Calculate the Variance */;

proc summary data=indat nway;
   class year;
   output out=vardat std(&vlong l_&vshort)=v_&vlong v_l_&vshort;
run;

proc print data=vardat;
run;

/* Calculate the Percentiles */;

proc univariate data=indat(rename=(year=yr_tmp)) pctldef=2 noprint;
   class yr_tmp;
   var &vlong;
   *output out=dist1b n=count pctlpre=pe_ pctlpts=0.5 to 98.5 by 1;
   *output out=dist1t n=count pctlpre=pe_ pctlpts=1.5 to 99.5 by 1;
   output out=dist1b n=count pctlpre=pe_ pctlpts=0.9 4.9 09.9 19.9 49.9 79.9 89.9 94.9 98.9;
   output out=dist1t n=count pctlpre=pe_ pctlpts=1.1 5.1 10.1 20.1 50.1 80.1 90.1 95.1 99.1;
   output out=dist1r n=count pctlpre=pe_ pctlpts=1 to 99 by 1;
   *output out=dist1r n=count pctlpre=pe_ pctlpts=5 to 95 by 5;
run;
proc contents data=dist1b order=varnum;
proc contents data=dist1t order=varnum;
proc print data=dist1b;
proc print data=dist1t;
proc print data=dist1r;
run;


%let dsid=%sysfunc(open(dist1b));
%let nobs=%sysfunc(attrn(&dsid,NOBS));
%let nvars=%eval(%sysfunc(attrn(&dsid,NVARS))-2);

data _NULL_;
   set dist1b end=last;
   if _N_=1 then call symput("yrbeg",put(yr_tmp,4.));
   if last then call symput("yrend",put(yr_tmp,4.));
run;

*options obs=1000;

*** Check for zero bin width ***;

data bincheck(keep=yr_tmp pcat value);
   merge dist1b dist1t(drop=count);
      by yr_tmp;

   array dvb{*} &fvarb--&evarb;
   array dvt{*} &fvart--&evart;
   array cn{&nvars} _TEMPORARY_ (1, 5, 10, 20, 50, 80, 90, 95, 99);

   do i=1 to &nvars;
      if dvb{i}=dvt{i} then do;
         pcat=cn{i};
         value=dvb{i};
         output;
      end;
   end;
run;

proc print data=bincheck;
run;
  
%let dsid=%sysfunc(open(bincheck));
%let nobs2=%sysfunc(attrn(&dsid,NOBS));

%macro checkit;
   %if &nobs2>0 %then %do;
      data checkit;
         set indat; 
         if _N_=1 then do;
            do i=1 to &nobs2;
               set bincheck;
               array yt{&nobs2} _TEMPORARY_;
               array ev{&nobs2} _TEMPORARY_;
               yt{i}=yr_tmp;
               ev{i}=value;
            end;
         end;
      
         vexist=0;
         do i=1 to &nobs2;
            if year=yt{i} and &vlong=ev{i} then vexist=&vlong;
         end;
      run;
      
      proc tabulate data=checkit;
         class year vexist /missing;
         table year*(vexist all='Subtotal') all='Total'
               , n*f=comma14.0 pctn<vexist all> pctn;
      run;
   %end;
%mend;
%checkit;

*** Bin the Data and Calculate the Geometric Mean of Each Bin  ***;

data cat1(drop=yr_tmp &fvarb--&evarb &fvart--&evart);
   set indat;

   array pb{&yrbeg:&yrend,&nvars} _TEMPORARY_;
   array pt{&yrbeg:&yrend,&nvars} _TEMPORARY_;
   array cn{&nvars} _TEMPORARY_ (1, 5, 10, 20, 50, 80, 90, 95, 99);
   
   length pcat 3;

   if _N_=1 then do;
      do i=1 to &nobs;
         set dist1b(keep=yr_tmp &fvarb--&evarb);
         array dvb{*} &fvarb--&evarb;
         do j=1 to &nvars;
            pb{yr_tmp,j}=dvb{j};
         end;
      end;
      do i=1 to &nobs;
         set dist1t(keep=yr_tmp &fvart--&evart);
         array dvt{*} &fvart--&evart;
         do j=1 to &nvars;
            pt{yr_tmp,j}=dvt{j};
         end;
      end;
   end;

   l&vlong=log(&vlong);
   do i=1 to hbound(pb,2);
      if pt{year,i}>pb{year,i} then do;
         if &vlong>pb{year,i} and &vlong<=pt{year,i} then do;
            pcat=cn{i};
            leave;
         end;
      end;
      else do;
        if &vlong=pb{year,i} then pcat=cn{i};
      end;
   end;
run;

proc summary data=cat1 nway;
   class year pcat;
   output out=dist2 mean(l&vlong)=mean_ln;
run;

data &ofile;
   set dist2;
   mean=exp(mean_ln);
run;

proc means data=&ofile min mean median;
   class year;
   var _FREQ_;
run;

*** Actual Values ***;

data dist2r;
   set dist1r;
   r_99_01=pe_99/pe_1;
   r_95_05=pe_95/pe_5;
   r_90_10=pe_90/pe_10;
   r_80_20=pe_80/pe_20;
   d_99_01=pe_99-pe_1;
   d_95_05=pe_95-pe_5;
   d_90_10=pe_90-pe_10;
   d_80_20=pe_80-pe_20;
run;

proc print data=dist2r;
   var yr_tmp r_99_01 r_95_05 r_90_10 r_80_20 d_99_01 d_95_05 d_90_10 d_80_20;
run;

*** Disclosure protected values ***;
   
data dist4;
   set &ofile;
      by year;

   retain earn01 earn05 earn10 earn20 earn50 earn80 earn90 earn95 earn99;

   if first.year then do;
      earn01=.; earn05=.; earn10=.; earn20=.; earn50=.; earn80=.; earn90=.; earn95=.; earn99=.;
   end;

   if pcat=1 then earn01=mean;
   if pcat=5 then earn05=mean;
   if pcat=10 then earn10=mean;
   if pcat=20 then earn20=mean;
   if pcat=50 then earn50=mean;
   if pcat=80 then earn80=mean;
   if pcat=90 then earn90=mean;
   if pcat=95 then earn95=mean;
   if pcat=99 then earn99=mean;

   if last.year then do;
      r_99_01=earn99/earn01;
      r_95_05=earn95/earn05;
      r_90_10=earn90/earn10;
      r_80_20=earn80/earn20;
      d_99_01=round(earn99-earn01);
      d_95_05=round(earn95-earn05);
      d_90_10=round(earn90-earn10);
      d_80_20=round(earn80-earn20);
      output;
   end;
run;

proc print data=dist4;
   var year r_99_01 r_95_05 r_90_10 r_80_20 d_99_01 d_95_05 d_90_10 d_80_20 earn01 earn05 earn10 earn20 earn50 earn80 earn90 earn95 earn99;
run;

proc print data=&ofile;
run;
