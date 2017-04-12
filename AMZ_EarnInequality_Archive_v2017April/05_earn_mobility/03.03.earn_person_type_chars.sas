*** Calculate the chars for each worker flow ***;

%include "config.sas";

options obs=max;

data temp1(keep=et1 pt1 et3 pt3 person_type earn_type age male white born_us);
   set outputs.pik_year_hc_dist;

   date1=mdy(1,1,year);
   date2=mdy(12,31,year);
   age1=(date1-DOB)/365.2425;
   age2=(date2-DOB)/365.2425;

   age=(age1+age2)/2;

   male=gender="M";

   white=pcf_race="1";

   born_us=POB="A";

   length et1 pt1 et3 pt3 $1;

   et1=substr(earn_type,1,1);
   pt1=substr(person_type,1,1);

   et3=substr(earn_type,3,1);
   pt3=substr(person_type,3,1);

run;

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

