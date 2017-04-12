/* Merge the Numident with the AKM input files */

%include "config.sas";

%let fdir=;

%include "&fdir./fips_std2.sas"; /* fipstam */
%include "&fdir./fips_us.sas"; /* fipus */
%include "&fdir./std_region_code5.sas"; /* regcode */
%include "&fdir./bestrace.sas"; /* raceb */

/* Date of Birth */;
data dob(keep=pik dob dob_flag dob_year dob_month dob_day);
   set outputs.cnum_pik(keep=pik dobcc dobyy dobmm dobdd);

   %include "00.02_dob_final.txt";
run;

proc contents data=dob;
proc tabulate data=dob;
   class dob_year dob_flag /missing;
   table dob_year all, n*f=comma14.0 pctn;
   table dob_flag all, n*f=comma14.0 pctn;
run;
proc print data=dob(obs=100);
run;

/* Date of Death */;
data dod(keep=pik dob dob_flag dob_year dob_month dob_day
         rename=(dob=DOD
                 dob_flag=DOD_flag
                 dob_year=DOD_year
                 dob_month=DOD_month
                 dob_day=DOD_day));
   set outputs.cnum_pik(keep=pik dodcc dodyy dodmm doddd
                      rename=(dodcc=dobcc
                              dodyy=dobyy
                              dodmm=dobmm
                              doddd=dobdd));

   %include "00.02_dob_final.txt";
run;

proc contents data=dod;
proc tabulate data=dod;
   class dod_year dod_flag /missing;
   table dod_year all, n*f=comma14.0 pctn;
   table dod_flag all, n*f=comma14.0 pctn;
run;
proc print data=dod(obs=100);
run;

/* Oldest Cycle Date */;
data doc(keep=pik dob dob_flag dob_year dob_month dob_day
         rename=(dob=DOC
                 dob_flag=DOC_flag
                 dob_year=DOC_year
                 dob_month=DOC_month
                 dob_day=DOC_day));
   set outputs.cnum_pik(keep=pik ocycc ocyyy ocymm ocydd
                      rename=(ocycc=dobcc
                              ocyyy=dobyy
                              ocymm=dobmm
                              ocydd=dobdd));

   %include "00.02_dob_final.txt";
run;

proc contents data=doc;
proc tabulate data=doc;
   class doc_year doc_flag /missing;
   table doc_year all, n*f=comma14.0 pctn;
   table doc_flag all, n*f=comma14.0 pctn;
run;
proc print data=doc(obs=100);
run;

/* Sex */;
data sex(keep=pik gender gender_flag);
   set outputs.cnum_pik(keep=pik gender rename=(gender=pcf_gender)); 

   %include "00.03_sex_final.txt";
run;

proc contents data=sex;
proc tabulate data=sex;
   class gender gender_flag /missing;
   table gender all, n*f=comma14.0 pctn;
   table gender_flag all, n*f=comma14.0 pctn;
run;
proc print data=sex(obs=100);
run;

/* POB */;
data pob(keep=pik pob pob_flag pcf_pob ssn3st pcf_st);
   set outputs.cnum_pik(keep=pik pobfin pobst ssn3st);

   length pcf_st $2;

   %include "00.04_pob_final.txt";

   if pob in ('A') then pcf_st=fipstate(input(pcf_pob,3.));
run;

proc contents data=pob;
proc tabulate data=pob;
   class pob pob_flag ssn3st pcf_st /missing;
   table pob all, n*f=comma14.0 pctn;
   table pob_flag all , n*f=comma14.0 pctn;
   table ssn3st all, n*f=comma14.0 pctn;
   table pcf_st all, n*f=comma14.0 pctn;
run;
proc print data=pob(obs=100);
run;

/* Race */;
data race(keep=pik pcf_race);
   set outputs.cnum_pik(keep=pik bestrace);

   %include "00.05_race_final.txt";
run;

proc contents data=race;
proc tabulate data=race;
   class pcf_race /missing;
   table pcf_race all, n*f=comma14.0 pctn;
run;
proc print data=race(obs=100);
run;

/* Bring it all together */;
data outputs.cnum_strip;
   merge dob dod doc sex pob race;
      by pik;
run;

proc contents data=outputs.cnum_strip;
proc print data=outputs.cnum_strip(obs=100);
run;

proc datasets library=outputs;
   delete cnum_pik;
run;
