*01.02.ACS_vars.sas;
*K. McKinney 20150914;
/* Create stacked PIK-ed ACS person file */

*** DATASETS ***;
/*
INPUTS:  ACS.acsYYYY
         ACSPIK.acs_YYYY_crosswalk
OUTPUTS: CPSACS.acs_person_01
*/

%include "config.sas";
options obs=max;

*** Person file variables ***;
%LET keepACS = CMID PNUM pwgt wgt NP SFN rel ST rdate sex age pows GQ
                                        frel         fsex fage fpows
                wag sem int ss ssi pa ret oi ti pern pinc wkh wkw esr cow wkl
               fwag fsem fint fss fssi fpa fret foi fti fpernpct fpincpct fwkh fwkw fesr fcow fwkl;


*** Stack yearly ACS files ***;
proc contents data=ACS.ACS&ACSstart.(keep=&keepACS.);
run;

proc contents data=ACS.ACS&ACSreformat.(keep=&keepACS.);
run;

%MACRO ACSstack(format=);

   /* Before the format change */
   %IF &format. = pre %THEN %DO;
           data work.ACSstack_&format.(drop=fage_temp fesr_temp fint_temp foi_temp fpa_temp
                                       fpows_temp frel_temp fret_temp fsem_temp fsex_temp
                                       fss_temp fssi_temp fti_temp fwag_temp fwkh_temp
                                       fwkw_temp fcow_temp);
                   length PERN PINC TI 8 pre 3 WKW_CAT $1;
                   format PERN 9. PINC 9. TI 9. WKW_CAT $1.;
                   length FAGE FESR FINT FOI FPA FPOWS FREL FRET FSEM FSEX FSS FSSI FTI FWAG FWKH FWKW FCOW FWKL $2;
                   format FAGE FESR FINT FOI FPA FPOWS FREL FRET FSEM FSEX FSS FSSI FTI FWAG FWKH FWKW FCOW FWKL $2.;
                   set
                           %DO i = &ACSstart. %TO &ACSreformat. - 1;
                                   ACS.acs&i.(keep=&keepACS. in=yr&i.
                                   rename=(FAGE=fage_temp
                                           FESR=fesr_temp
                                           FINT=fint_temp
                                           FOI=foi_temp
                                           FPA=fpa_temp
                                           FPOWS=fpows_temp
                                           FREL=frel_temp
                                           FRET=fret_temp
                                           FSEM=fsem_temp
                                           FSEX=fsex_temp
                                           FSS=fss_temp
                                           FSSI=fssi_temp
                                           FTI=fti_temp
                                           FWAG=fwag_temp
                                           FWKH=fwkh_temp
                                           FWKW=fwkw_temp
                                           FCOW=fcow_temp
                                           FWKL=fwkl_temp
                                           ))
                           %END;
                   ;
                   pre=1;
   
                   fage="0" || fage_temp;
                   fesr="0" || fesr_temp;
                   fint="0" || fint_temp;
                   foi="0" || foi_temp;
                   fpa="0" || fpa_temp;
                   fpows="0" || fpows_temp;
                   frel="0" || frel_temp;
                   fret="0" || fret_temp;
                   fsem="0" || fsem_temp;
                   fsex="0" || fsex_temp;
                   fss="0" || fss_temp;
                   fssi="0" || fssi_temp;
                   fti="0" || fti_temp;
                   fwag="0" || fwag_temp;
                   fwkh="0" || fwkh_temp;
                   fwkw="0" || fwkw_temp;
                   fcow="0" || fcow_temp;
                   fwkl="0" || fwkl_temp;

                   length year 3.;
                   %DO i = &ACSstart. %TO &ACSreformat. - 1;
                           if yr&i. = 1 then year = &i.;
                   %END;

                   label
                      FAGE   ="Age allocation flag"
                      FESR   ="Employment Status Recode allocation flag"
                      FINT   ="Interest allocation flag"
                      FOI    ="Other Income allocation flag"
                      FPA    ="Public Assistance Income allocation flag"
                      FPOWS  ="Place of Work State allocation flag"
                      FREL   ="Relationship allocation flag"
                      FRET   ="Retirement Income allocation flag"
                      FSEM   ="Self-employment Income allocation flag"
                      FSEX   ="Sex allocation flag"
                      FSS    ="Social Security Income allocation flag"
                      FSSI   ="Suplemental Security Income allocation flag"
                      FTI    ="Total Income allocation flag"
                      FWAG   ="Wages/Salary Income allocation flag"
                      FWKH   ="Hours Worked Per Week allocation flag"
                      FWKW   ="Weeks Worked Past 12 Months allocation flag"
                      FCOW   ="Class of Worker Allocation Flag"
                      FWKL   ="When last worked Allocation Flag"
                      WKW_CAT="Weeks Worked Last 12 months (CATEGORY)"
                      pre    ="Data is pre format change (2001-2007)"
                   ;

           run;
   %END; *if loop;
   
   /* After the format change */
   %IF &format. = post %THEN %DO;
           data work.ACSstack_&format.;
                   length ST $3 AGE 4 INT 6 NP 4 OI 6 PA 5 PNUM 4 RET SEM 6 SS SSI 5 WAG 6 WKH 4 pre 3 WKW 4;
                   format AGE 3. INT 6. NP 2. OI 6. PA 5. PNUM Z2. RET 6. SEM 6. SS 5. SSI 5. WAG 6. WKH 2. WKW 2.;
                   set
                           %DO i = &ACSreformat. %TO &ACSend.;
                                   ACS.acs&i.(keep=&keepACS. in=yr&i.
                                              rename=(WKW=wkw_temp
                                              ))
                           %END;
                   ;
                   pre=0;

                   rename wkw_temp=WKW_CAT;

                   if length(trim(left(ST)))=2 then ST="0" || ST;
   
                   length year 3.;
                   %DO i = &ACSreformat. %TO &ACSend.;
                           if yr&i. = 1 then year = &i.;
                   %END;

           run;
   %END; *if loop;
   
   /* Sort by year CMID PNUM */
   proc sort data=work.ACSstack_&format.;
           by year CMID PNUM;
   run;
   proc contents data=work.ACSstack_&format.;
   run;
   proc freq data=work.ACSstack_&format.;
      tables PNUM NP SFN rel ST rdate sex age pows GQ
             frel fsex fage fpows wkh wkw wkw_cat esr
             fwag fsem fint fss fssi fpa fret foi fti fwkh fwkw fesr /missing;
   run;
   proc print data=work.ACSstack_&format.(obs=100);
   run;

%MEND ACSstack;
%ACSstack(format = pre);
%ACSstack(format = post);

proc append base=work.ACSstack data=work.ACSstack_pre;
run;
proc append base=work.ACSstack data=work.ACSstack_post;
run;

proc contents data=work.ACSstack;
run;

*** Stack yearly ACS xwalk files ***;
%MACRO ACSxstack(format=);

%IF &format. = pre %THEN %DO;
        %LET start = &ACSstart.;
        %LET end = &ACSreformat. - 1;
%END;

%IF &format. = post %THEN %DO;
        %LET start = &ACSreformat.;
        %LET end = &ACSend.;
%END;

data work.ACSxstack_&format.;
        length pik $9 CMID $9 PNUM 4;
        set
                %DO i = &start. %TO &end.;
                        ACSPIK.acs_&i._crosswalk(keep=CMID PNUM pik where=(pik ~= " ") in=yr&i.)
                %END;
        ;

        length year 3.;
        %DO i = &start. %TO &end.;
                if yr&i. = 1 then year = &i.;
        %END;
        run;

proc sort data=work.ACSxstack_&format.;
        by year CMID PNUM;
run;

%MEND ACSxstack;
%ACSxstack(format = pre);
%ACSxstack(format = post);

proc append base=work.ACSxstack data=work.ACSxstack_pre;
proc append base=work.ACSxstack data=work.ACSxstack_post;
run;

proc contents data=work.ACSxstack;
run;

*** Merge the ACS data and the xwalk together ***;
data CPSACS.acs_person_01(drop=_merge) work.check(keep=year _merge);
   merge work.ACSstack(in=a) work.ACSxstack(in=b);
      by year CMID PNUM;

   length _merge pik_found 3;
   _merge=a+2*b;

   pik_found=_merge=3;

   label pik_found="PIK found on crosswalk";

   if a=1 then output CPSACS.acs_person_01;
   output check;
run;

proc sort data=CPSACS.acs_person_01;
   by year CMID PNUM pik;
run;

proc contents data=CPSACS.acs_person_01;
run;
options nolabel;
proc freq data=check;
   tables year*_merge;
run;
proc freq data=CPSACS.acs_person_01;
   tables year year*pik_found;
run;
proc means data=CPSACS.acs_person_01 n mean min p25 median p75 max;
run;
proc print data=CPSACS.acs_person_01(obs=100);
run;
