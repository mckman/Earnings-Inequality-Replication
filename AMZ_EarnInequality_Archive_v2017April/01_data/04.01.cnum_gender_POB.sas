/* For DOB after 1920 there are no good gender predictors available on the NUMIDENT */;
/* Most of the missing data is prior to 1920 so we do a simple impute */;

%include "config.sas";

options obs=max;

data outputs.cnum_strip3(drop=uni i date1 date2 age1 age2);
   merge outputs.cnum_strip2 outputs.merge_cnum_ui;
      by pik;

   length eligible 3;

   /* Gender */;

   if gender_flag=9 then do;
      uni=rand('UNIFORM');
      if uni<=0.5 then gender="F";
      else gender="M";
      gender_flag=1;
   end;

   if POB_flag=9 then do;
      POB="A";
      POB_flag=1;
   end;

   if source=1 or source=3 then do;
      age1990=(mdy(1,1,1990)-DOB)/365.2425;
      age2014=(mdy(1,1,2014)-DOB)/365.2425;
      eligible=0;
      if dod=. or dod>mdy(1,1,1990) then do;
         age_first=.;
         age_last=.;
         year_first=.;
         year_last=.;
         do i=1990 to 2013;
            /* Insert code to do first and last year */
            /* Add adjustment for DOD */
            date1=mdy(1,1,i);
            date2=mdy(12,31,i);
            age1=(date1-DOB)/365.2425;
            age2=(date2-DOB)/365.2425;
            if POB~="A" and DOC_year>. then years_us=(i-DOC_year);
            if age2>=18 and age1<=70 and (dod=. or dod>date1)
               and (years_us=. or years_us>=0) then do;
               if age_first=. then age_first=age1;
               if year_first=. then year_first=i;
               age_last=age2;
               year_last=i;
               eligible=1;
            end;
         end;
      end;
      if eligible=1 then eligible_years=year_last-year_first+1;
   end;
run;

proc contents data=outputs.cnum_strip3;
proc means data=outputs.cnum_strip3 n mean min p25 median p75 max;
   class source eligible;
   var age1990 age2014 eligible_years age_first age_last year_first year_last;
run;
proc tabulate data=outputs.cnum_strip3;
   class source eligible dob_flag gender_flag POB_flag /missing;
   table source all, n*f=comma14.0 pctn;
   table eligible all, n*f=comma14.0 pctn;
   table source*(eligible all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<eligible all> pctn;
   table dob_flag all, n*f=comma14.0 pctn;
   table gender_flag all, n*f=comma14.0 pctn;
   table POB_flag all, n*f=comma14.0 pctn;
run;
proc tabulate data=outputs.cnum_strip3(where=(DOB_flag=8));
   class DOB_year /missing;
   table DOB_year all, n*f=comma14.0 pctn;
run;
proc tabulate data=outputs.cnum_strip3(where=(gender_flag=1));
   class gender /missing;
   table gender all, n*f=comma14.0 pctn;
run;
proc tabulate data=outputs.cnum_strip3(where=(POB_flag=1));
   class POB /missing;
   table POB all, n*f=comma14.0 pctn;
run;
proc print data=outputs.cnum_strip3(obs=100);
run;

endsas;

proc freq data=outputs.cnum_strip(where=(gender_flag~=9));
   tables POB*gender DOB_year*gender DOC_year*gender;
proc freq data=outputs.cnum_strip;
   tables POB*gender_flag DOB_year*gender_flag DOC_year*gender_flag;
run;

