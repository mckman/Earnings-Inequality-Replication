*** Examine workers that have a 1_1 earn_type at some point during 2008-2013 ***;

%include "config.sas";

options obs=1000000;

data temp0(drop=year rename=(y=year));
   set outputs.pik_year_hc_dist(keep=pik year earn_type);
      by pik;

   length ehist $10;

   retain ehist;

   array one{2005:2013} _TEMPORARY_;

   if first.pik then do;
      ehist=repeat(" ",9);
      do y=2005 to 2013;
         one{y}=0;
      end;
   end;

   et1n=input(substr(earn_type,1,1),1.);
   et3n=input(substr(earn_type,3,1),1.);

   if et1n>2 then et1n=2;
   if et3n>2 then et3n=2;

   if year=2005 then substr(ehist,1,1)=put(et1n,1.);
   if year=2005 then substr(ehist,2,1)=put(et3n,1.);
   else if year=2006 then substr(ehist,3,1)=put(et3n,1.);
   else if year=2007 then substr(ehist,4,1)=put(et3n,1.);
   else if year=2008 then substr(ehist,5,1)=put(et3n,1.);
   else if year=2009 then substr(ehist,6,1)=put(et3n,1.);
   else if year=2010 then substr(ehist,7,1)=put(et3n,1.);
   else if year=2011 then substr(ehist,8,1)=put(et3n,1.);
   else if year=2012 then substr(ehist,9,1)=put(et3n,1.);
   else if year=2013 then substr(ehist,10,1)=put(et3n,1.);

   if earn_type="1_1" then one{year}=1;

   if last.pik then do;
      do y=2005 to 2013;
         if one{y}=1 then output;
      end;
   end;
run;
  

proc contents;
proc print data=temp0(obs=1000);

proc tabulate data=temp0;
   class year ehist /missing;
   table year all, n*f=comma14.0 pctn;
   table ehist all, n*f=comma14.0 pctn;
   table year*(ehist all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<ehist all> pctn;
run;

proc freq data=temp0;
   tables year*ehist /out=temp0f;
run;

proc sort data=temp0f;
   by year descending count;
run;

proc print data=temp0f;
run;

endsas;

   table one_prev all, n*f=comma14.0 pctn;
   table earn_post all, n*f=comma14.0 pctn;
   table one_post all, n*f=comma14.0 pctn;
   table year*(one_post all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<one_post all> pctn;
   table year*earn_prev*(one_post all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<one_post all> pctn;
   table year*earn_prev*(one_prev all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<one_prev all> pctn;
   table year*earn_post*(one_post all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<one_post all> pctn;
run;
proc print data=temp0(obs=1000);
run;

endsas;

data temp1;
   merge outputs.pik_year_hc_dist temp0;
      by pik;

   date1=mdy(1,1,year);
   date2=mdy(12,31,year);
   age1=(date1-DOB)/365.2425;
   age2=(date2-DOB)/365.2425;

   age=(age1+age2)/2;

   male=gender="M";

   white=pcf_race="1";

   born_us=POB="A";
run;

proc contents data=temp1;
proc tabulate data=temp1(where=(earn_type="1_1" and years_eligible=9 and years_earn>=1));
   class year years_1_1 years_earn;
   table year all, n*f=comma14.0 pctn;
   table years_1_1 all, n*f=comma14.0 pctn;
   table years_earn all, n*f=comma14.0 pctn;
   table year*(years_1_1 all='Subtotal') all='Total'
         , n*f=comma14.0 pctn<years_1_1 all> pctn;
run;

endsas;

proc summary data=temp1 nway;
   class earn_type;
   output out=dot.echars mean(age male white born_us)=m_age m_male m_white m_born_us
                std(age male white born_us)=s_age s_male s_white s_born_us;
run; 

proc print data=dot.echars;
run;

proc summary data=temp1 nway;
   class person_type;
   output out=dot.pchars mean(age male white born_us)=m_age m_male m_white m_born_us
                std(age male white born_us)=s_age s_male s_white s_born_us;
run; 

proc print data=dot.pchars;
run;

proc means data=temp1 n mean stddev;
   class et1;
   var age male white born_us;
run;

proc means data=temp1 n mean stddev;
   class pt1;
   var age male white born_us;
run;

proc means data=temp1 n mean stddev;
   class et3;
   var age male white born_us;
run;

proc means data=temp1 n mean stddev;
   class pt3;
   var age male white born_us;
run;

