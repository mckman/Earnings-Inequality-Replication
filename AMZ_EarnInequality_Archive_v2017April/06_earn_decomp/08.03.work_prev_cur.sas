*** Create a file with prev and cur LFA variables ***;

%include "config.sas";

data pik_year_work_pc(keep=pik year year1_num_qtrs--year2_num_jobs);
   set outputs.pik_year_work;
      by pik;

   retain year_first year_last;

   array nq{2004:2013} _TEMPORARY_;
   array lj{2004:2013} _TEMPORARY_;
   array nj{2004:2013} _TEMPORARY_;

   if first.pik then do;
      year_first=year;
   end;

   nq{year}=num_qtrs;
   lj{year}=long_job;
   nj{year}=num_jobs;

   if last.pik then do;
      year_last=year;

      if year_first<=2005 then year_start=2005;
      else year_start=year_first;

      if year_last>=2013 then year_end=2013;
      else year_end=year_last+1;

      do y=year_start to year_end;
         year1_num_qtrs=nq{y-1};
         year2_num_qtrs=nq{y};
         year1_long_job=lj{y-1};
         year2_long_job=lj{y};
         year1_num_jobs=nj{y-1};
         year2_num_jobs=nj{y};
         year=y;
         output;
     end;

      do y=year_first to year_last;
         nq{y}=.;
         lj{y}=.;
         nj{y}=.;
      end;
   end;
run;

proc contents data=pik_year_work_pc;
proc print data=pik_year_work_pc(obs=100);
run;

data temp1;
   merge outputs.pik_year_hc_dist(in=a)
         pik_year_work_pc(in=b);
      by pik year;
run;

proc print data=temp1(obs=100);
run;

proc summary data=temp1 nway;
   class firm_type skill_type earn_type;
   output out=dot.work_ft_st_et sum(year1_num_qtrs year1_long_job year1_num_jobs year2_num_qtrs year2_long_job year2_num_jobs)=sum1_nq sum1_lj sum1_nj sum2_nq sum2_lj sum2_nj;
run;

proc print data=dot.work_ft_st_et;
   format sum1_nq sum1_lj sum1_nj sum2_nq sum2_lj sum2_nj COMMA22.0;
run;
