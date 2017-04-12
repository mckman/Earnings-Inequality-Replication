*** Get the UI data and variables needed ***;

%include "config.sas";
%include "pik2short.sas";

%let obsv=max;

%let uivars=pik year sixq;

data temp0 /view=temp0;
   %sline(lib=ui,data=analysis_dataset,keepvars=&uivars,type=0);
run;

proc sort data=temp0 out=temp1;
   by pik year;
run;

data temp2(keep=pik year num_qtrs long_job);
   set temp1;
      by pik year;

   length  num_qtrs q1 q2 q3 q4 3;
   retain long_job q1 q2 q3 q4;

   if first.year then do;
      long_job=0;
      q1=0; q2=0; q3=0; q4=0;
   end;

   if substr(sixq,2,1)="1" then q1=1;
   if substr(sixq,3,1)="1" then q2=1;
   if substr(sixq,4,1)="1" then q3=1;
   if substr(sixq,5,1)="1" then q4=1;

   start=0;
   lj_tmp=0;
   do i=2 to 5;
      if start=0 and substr(sixq,i,1)="1" then do;
         start=i;
         do j=start to 5;
            if substr(sixq,j,1)="1" then lj_tmp=lj_tmp+1;
            else leave;
         end;
      end;
   end;

   if lj_tmp=4 then do;
      if substr(sixq,1,1)="1" then lj_tmp=lj_tmp+1;
      if substr(sixq,6,1)="1" then lj_tmp=lj_tmp+1;
   end;

   if lj_tmp>long_job then long_job=lj_tmp;

   if last.year then do;
      num_qtrs=q1+q2+q3+q4;
      output;
   end;
run;

data outputs.pik_year_work(drop=_merge le_r lf_r lp_r) checkit(keep=_merge);
   merge temp2(in=a) outputs.pik_year_hc(in=b keep=pik year num_jobs le_r lf_r lp_r earn_total earn_firm earn_person);
      by pik year;

   length _merge et ft pt 3;
   _merge=a+2*b;

   if _merge=3 then do;
      et=.;
      if le_r>=0 and le_r<=1 then et=2;
      if le_r>=2 and le_r<=7 then et=3;
      if le_r>=8 and le_r<=9 then et=4;

      ft=.;
      if lf_r>=0 and lf_r<=1 then ft=2;
      if lf_r>=2 and lf_r<=7 then ft=3;
      if lf_r>=8 and lf_r<=9 then ft=4;

      pt=.;
      if lp_r>=0 and lp_r<=1 then pt=2;
      if lp_r>=2 and lp_r<=7 then pt=3;
      if lp_r>=8 and lp_r<=9 then pt=4;

       output outputs.pik_year_work;
   end;
   output checkit;
run;

proc contents data=outputs.pik_year_work;
proc tabulate data=checkit;
   class _merge;
   table _merge all, n*f=comma14.0 pctn;
run;
proc means data=outputs.pik_year_work n mean median;
   class et;
   var num_jobs;
run;
proc tabulate data=outputs.pik_year_work;
   class year et ft pt num_qtrs long_job;
   table year all, n*f=comma14.0 pctn;
   table num_qtrs all, n*f=comma14.0 pctn;
   table num_qtrs*(long_job all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<long_job all> pctn;
   table et*num_qtrs*(long_job all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<long_job all> pctn;
   table ft*num_qtrs*(long_job all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<long_job all> pctn;
   table pt*num_qtrs*(long_job all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<long_job all> pctn;
run;
proc print data=outputs.pik_year_work(obs=1000);
run;
