*** Calculate the year to year earning mobility edges ***;

%include "config.sas";

data merge_both /view=merge_both;
   merge outputs.worker_eligible(in=a keep=pik year DOB gender POB pcf_race year_first year_last)
         outputs.pik_year_hc(in=b drop=sein);
      by pik year;

   *if a=1 then output;
run;


data outputs.pik_year_hc_dist(keep=pik year DOB gender POB pcf_race year_first year_last earn_type firm_type person_type skill_type);
   set merge_both(where=(year>=2004));
      by pik year;


   length earn_type firm_type person_type skill_type $3;

   array et{2004:2013} _TEMPORARY_;
   array ft{2004:2013} _TEMPORARY_;
   array pt{2004:2013} _TEMPORARY_;
   array st{2004:2013} _TEMPORARY_;
   array rr1_{1:4} _TEMPORARY_;
   array rr2_{1:4} _TEMPORARY_;
   array er1_{1:4} _TEMPORARY_;
   array er2_{1:4} _TEMPORARY_;
   array efpt{1:4} earn_type firm_type person_type skill_type;

   if first.pik then do;
      do y=2004 to 2013;
         et{y}=.;
         ft{y}=.;
         pt{y}=.;
         st{y}=.;
      end;
   end;

   et{year}=le_r;
   ft{year}=lf_r;
   pt{year}=lp_r;
   st{year}=ls_r;

   if last.pik then do;
      if year_first<=2005 then year_start=2005;
      else year_start=year_first;
     
      if year_last>=2013 then year_end=2013;
      else year_end=year_last+1;

      do y=year_start to year_end;
         rr1_{1}=et{y-1};
         rr1_{2}=ft{y-1};
         rr1_{3}=pt{y-1};
         rr1_{4}=st{y-1};
         rr2_{1}=et{y};
         rr2_{2}=ft{y};
         rr2_{3}=pt{y};
         rr2_{4}=st{y};

         do i=1 to 4;
            er1_{i}=.;
            if rr1_{i}=. and ((y-1)<year_first or (y-1)>year_last) then er1_{i}=0;
            else if rr1_{i}=. and (y-1)>=year_first and (y-1)<=year_last then er1_{i}=1;
            else if rr1_{i}>=0 and rr1_{i}<=1 then er1_{i}=2;
            else if rr1_{i}>=2 and rr1_{i}<=7 then er1_{i}=3;
            else if rr1_{i}>=8 and rr1_{i}<=9 then er1_{i}=4;
         end;

         do i=1 to 4;
            er2_{i}=.;
            if rr2_{i}=. and ((y)<year_first or (y)>year_last) then er2_{i}=0;
            else if rr2_{i}=. and (y)>=year_first and (y)<=year_last then er2_{i}=1;
            else if rr2_{i}>=0 and rr2_{i}<=1 then er2_{i}=2;
            else if rr2_{i}>=2 and rr2_{i}<=7 then er2_{i}=3;
            else if rr2_{i}>=8 and rr2_{i}<=9 then er2_{i}=4;
         end;

         do i=1 to 4;
            efpt{i}=put(er1_{i},1.) || "_" || put(er2_{i},1.);
         end;

         year=y;

         output;
      end;
   end;
run;

proc contents;
proc means data=outputs.pik_year_hc_dist n mean min p10 p25 median p75 p90 max;
run;

proc tabulate data=outputs.pik_year_hc_dist;
   class year earn_type firm_type person_type skill_type /missing;
   table year all, n*f=comma14.0 pctn;
   table earn_type all, n*f=comma14.0 pctn;
   table firm_type all, n*f=comma14.0 pctn;
   table person_type all, n*f=comma14.0 pctn;
   table skill_type all, n*f=comma14.0 pctn;
   table year*(earn_type all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<earn_type all> pctn;
   table year*(firm_type all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<firm_type all> pctn;
   table year*(person_type all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<person_type all> pctn;
   table year*(skill_type all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<skill_type all> pctn;
   table earn_type*(firm_type all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<firm_type all> pctn;
   table earn_type*(person_type all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<person_type all> pctn;
   table earn_type*(skill_type all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<skill_type all> pctn;
run;

proc freq data=outputs.pik_year_hc_dist noprint;
   tables year*earn_type /out=dot.hc_dist1;
   tables year*firm_type /out=dot.hc_dist2;
   tables year*person_type /out=dot.hc_dist3;
   tables earn_type*firm_type /out=dot.hc_dist4;
   tables person_type*firm_type /out=dot.hc_dist5;
   tables earn_type*person_type /out=dot.hc_dist6;
   tables year*earn_type*firm_type /out=dot.hc_dist7;
   tables year*person_type*firm_type /out=dot.hc_dist8;
   tables year*earn_type*person_type /out=dot.hc_dist9;
   tables firm_type*person_type*earn_type /out=dot.hc_dist10;
   tables firm_type*skill_type*earn_type /out=dot.hc_dist11;
run;

proc print data=outputs.pik_year_hc_dist(obs=1000);
run;
