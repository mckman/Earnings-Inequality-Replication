*** Create long term earning variables ***;

%include "config.sas";


data outputs.pik_year_earn_history(drop=all_real_earn et_all year_first y year_last year_start year_end c z);
   set outputs.pik_year_elig_yrs(keep=pik year all_real_earn);
      by pik;

   retain pik year year_first et_all;

   length em9 em8 em7 em6 em5 em4 em3 em2 em1 ez0 ep1 ep2 ep3 ep4 ep5 ep6 ep7 ep8
          cm9 cm8 cm7 cm6 cm5 cm4 cm3 cm2 cm1 cz0 cp1 cp2 cp3 cp4 cp5 cp6 cp7 cp8 6
          sm9 sm8 sm7 sm6 sm5 sm4 sm3 sm2 sm1 sz0 sp1 sp2 sp3 sp4 sp5 sp6 sp7 sp8
          am9 am8 am7 am6 am5 am4 am3 am2 am1 az0 ap1 ap2 ap3 ap4 ap5 ap6 ap7 ap8
          im9 im8 im7 im6 im5 im4 im3 im2 im1 iz0 ip1 ip2 ip3 ip4 ip5 ip6 ip7 ip8 never_work 3;

   array ae{2004:2013} _TEMPORARY_;
   array evar{-9:8} em9 em8 em7 em6 em5 em4 em3 em2 em1 ez0 ep1 ep2 ep3 ep4 ep5 ep6 ep7 ep8;
   array cvar{-9:8} cm9 cm8 cm7 cm6 cm5 cm4 cm3 cm2 cm1 cz0 cp1 cp2 cp3 cp4 cp5 cp6 cp7 cp8;
   array svar{-9:8} sm9 sm8 sm7 sm6 sm5 sm4 sm3 sm2 sm1 sz0 sp1 sp2 sp3 sp4 sp5 sp6 sp7 sp8;
   array avar{-9:8} am9 am8 am7 am6 am5 am4 am3 am2 am1 az0 ap1 ap2 ap3 ap4 ap5 ap6 ap7 ap8;
   array ivar{-9:8} im9 im8 im7 im6 im5 im4 im3 im2 im1 iz0 ip1 ip2 ip3 ip4 ip5 ip6 ip7 ip8;

   if first.pik then do;
      et_all=0;
      do y=2004 to 2013;
         ae{y}=0;
      end;
      year_first=year;
   end;

   if all_real_earn>0 then do;
      ae{year}=all_real_earn;
      et_all=et_all+all_real_earn;
   end;

   if last.pik then do;
      year_last=year;

      if year_first<=2005 then year_start=2005;
      else year_start=year_first;

      if year_last>=2013 then year_end=2013;
      else year_end=year_last+1;

      never_work=et_all=0;
      do y=year_start to year_end;
         do c=-9 to 8;
            evar{c}=.;
            cvar{c}=.;
            svar{c}=.;
            avar{c}=.;
            ivar{c}=.;
         end;
         *put pik= y= year_start= year_end= ae{y-1}= ae{y}=;
         evar{0}=ae{y};
         evar{-1}=ae{y-1};

         cvar{0}=ae{y};
         cvar{-1}=ae{y-1};

         svar{0}=ae{y}>0;
         svar{-1}=ae{y-1}>0;

         avar{0}=ae{y}>0;
         avar{-1}=ae{y-1}>0;

         ivar{0}=ae{y}<=0;
         ivar{-1}=ae{y-1}<=0;

         if y>=2006 then do;
            do z=y-1 to year_first by -1;
               if z=y-1 then do;
                  c=-1;
                  *put "enter neg loop " z= c=;
                  evar{c}=ae{z};
                  cvar{c}=ae{z};
                  svar{c}=ae{z}>0;
                  avar{c}=ae{z}>0;
                  ivar{c}=ae{z}<=0;
               end;
               else do;
                  *put "continue neg loop " z= c=;
                  evar{c}=ae{z};
                  cvar{c}=cvar{c+1}+ae{z};
                  svar{c}=ae{z}>0;
                  avar{c}=avar{c+1}+(ae{z}>0);
                  ivar{c}=ivar{c+1}+(ae{z}<=0);
               end;
               *put pik= y= z= evar{c}=;
               c=c-1;
            end;
         end;
         if y<=2012 then do;
            do z=y to year_last;
               if z=y then do;
                  c=0;
                  *put "enter pos loop " z=;
                  evar{c}=ae{z};
                  cvar{c}=ae{z};
                  svar{c}=ae{z}>0;
                  avar{c}=ae{z}>0;
                  ivar{c}=ae{z}<=0;
               end;
               else do;
                  *put "continue pos loop " z=;
                  evar{c}=ae{z};
                  cvar{c}=cvar{c-1}+ae{z};
                  svar{c}=ae{z}>0;
                  avar{c}=avar{c-1}+(ae{z}>0);
                  ivar{c}=ivar{c-1}+(ae{z}<=0);
               end;
               *put pik= y= z= evar{c}=;
               c=c+1;
            end;
         end;
         year=y;
         output;
      end;
   end;
run;

proc contents data=outputs.pik_year_earn_history;
proc print data=outputs.pik_year_earn_history(obs=1000);
run;
