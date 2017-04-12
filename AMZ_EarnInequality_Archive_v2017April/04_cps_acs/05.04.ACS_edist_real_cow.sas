*** Earnings Distributions for the ACS ***;

/*
GQ
0 Not General Quarters
1 General Quarters

ESR
1 Employed at work
2 Employed with a job but not at work
3 Unemployed
4 Armed Forces, at work
5 Armder Forces, with a job but not at work
6 Not in labor force

COW
1 Private for profit
2 Private not for profit
3 Local Gov
4 State Gov
5 Federal Gov
6 SE Incorportated
7 SE Not Incorporated
8 Work without pay - family
9 Unemployed
*/;

%include "config.sas";

/* Output Dataset */;
%let ofile=dot.acs_edist_real_cow;

/* Variable to Use */;
%let vname=pern_real;

/* fvarb=Name of first variable in the bottom of the bin percentile list */
/* evarb=Name of the last variable in the bottom of the bin percentile list */
/* fvart=Name of first variable in the top of the bin percentile list */
/* evart=Name of the last variable in the top of the bin percentile list */;
%let fvarb=pe_4_8;
%let evarb=pe_94_8;
%let fvart=pe_5_2;
%let evart=pe_95_2;

data indat /view=indat;
   set inputs.acs_person_02(keep=CMID PNUM year_tab pwgt age &vname GQ esr cow rename=(year_tab=year)
                            where=(GQ="0" and
                                   esr in("1", "2") and
                                   cow in("1", "2", "3", "4", "5", "7") and
                                   &vname>0 and age>17 and age<71));

   call streaminit(511966);

   vname=round((1+(rand('TRIANGLE',0.5)-0.5)/25)*&vname);
   *vname=&vname;
run;

/* Calculate the Percentiles */;

proc univariate data=indat(rename=(year=yr_tmp)) pctldef=2 noprint;
   weight pwgt;
   class yr_tmp;
   var vname;
   *output out=dist1b n=count pctlpre=pe_ pctlpts=0.5 to 98.5 by 1;
   *output out=dist1t n=count pctlpre=pe_ pctlpts=1.5 to 99.5 by 1;
   *output out=dist1b n=count pctlpre=pe_ pctlpts=4 9  19 49 79 89 94;
   *output out=dist1t n=count pctlpre=pe_ pctlpts=6 11 21 51 81 91 96;
   output out=dist1b n=count pctlpre=pe_ pctlpts=4.8 9.8  19.8 49.8 79.8 89.8 94.8;
   output out=dist1t n=count pctlpre=pe_ pctlpts=5.2 10.2 20.2 50.2 80.2 90.2 95.2;
   *output out=dist1r n=count pctlpre=pe_ pctlpts=1 to 99 by 1;
   output out=dist1r n=count pctlpre=pe_ pctlpts=5 to 95 by 5;
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
   array cn{&nvars} _TEMPORARY_ (5, 10, 20, 50, 80, 90, 95);

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
            if year=yt{i} and vname=ev{i} then vexist=vname;
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
   array cn{&nvars} _TEMPORARY_ (5, 10, 20, 50, 80, 90, 95);
   
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

   lvname=log(vname);
   do i=1 to hbound(pb,2);
      if pt{year,i}>pb{year,i} then do;
         if vname>pb{year,i} and vname<=pt{year,i} then do;
            pcat=cn{i};
            leave;
         end;
      end;
      else do;
        if vname=pb{year,i} then pcat=cn{i};
      end;
   end;
run;

proc summary data=cat1 nway;
   class year pcat;
   output out=dist2 mean(lvname)=mean_ln;
run;

data &ofile;
   set dist2;
   mean=round(exp(mean_ln),10);
run;

proc means data=&ofile min mean median;
   class year;
   var _FREQ_;
run;

*** Actual Values ***;

data dist2r;
   set dist1r;
   r_95_05=pe_95/pe_5;
   r_90_10=pe_90/pe_10;
   r_80_20=pe_80/pe_20;
   d_95_05=pe_95-pe_5;
   d_90_10=pe_90-pe_10;
   d_80_20=pe_80-pe_20;
run;

proc print data=dist2r;
   var yr_tmp r_95_05 r_90_10 r_80_20 d_95_05 d_90_10 d_80_20;
run;

*** Disclosure protected values ***;
   
data dist4;
   set &ofile;
      by year;

   retain earn05 earn10 earn20 earn50 earn80 earn90 earn95;

   if first.year then do;
      earn05=.; earn10=.; earn20=.; earn50=.; earn80=.; earn90=.; earn95=.;
   end;

   if pcat=5 then earn05=mean;
   if pcat=10 then earn10=mean;
   if pcat=20 then earn20=mean;
   if pcat=50 then earn50=mean;
   if pcat=80 then earn80=mean;
   if pcat=90 then earn90=mean;
   if pcat=95 then earn95=mean;

   if last.year then do;
      r_95_05=earn95/earn05;
      r_90_10=earn90/earn10;
      r_80_20=earn80/earn20;
      d_95_05=earn95-earn05;
      d_90_10=earn90-earn10;
      d_80_20=earn80-earn20;
      output;
   end;
run;

proc print data=dist4;
   var year r_95_05 r_90_10 r_80_20 d_95_05 d_90_10 d_80_20 earn05 earn10 earn20 earn50 earn80 earn90 earn95;
run;

proc print data=&ofile;
run;
