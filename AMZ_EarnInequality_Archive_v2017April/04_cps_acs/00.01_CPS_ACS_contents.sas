*00.01.CPS_ACS_contents.sas;
*K. McKinney 20150831;
/* CPS and ACS Input Files */

*** DATASETS ***;
/*
INPUTS:  CPS.personYYYY
         CPS.hhldYYYY
         CPSPIK.master_cpsxwalk
         CPSPIK.master_cpsxwalk_internal_py
         ACS.acsYYYY
         ACS.acs_YYYY_crosswalk
OUTPUTS: none
*/

%include "config.sas";

proc contents data=CPSPIK.master_cpsxwalk;
proc contents data=CPSPIK.master_cpsxwalk_internal_py;
run;

%macro loop;
   %do yr=&CPSstart %to &CPSend;
      proc contents data=CPS.person&yr. varnum;
      proc print data=CPS.person&yr.(obs=100);
         var ph_seq phf_seq ppposold a_famrel workyn wtemp nwlook wkswork hrswk wexp ptotval pearnval pothval wsal_val semp_val frse_val marsupwt;
         var                 i_workyn i_wtemp i_wkswk i_hrswk              i_ernval          i_wsval i_seval i_frmval;
      run;
      proc contents data=CPS.family&yr. varnum;
      proc print data=CPS.family&yr.(obs=25);
         var fh_seq ffpos ffposold fpersons fearns ftotval fearnval fothval fwsval fseval ffrval fsup_wgt;
      run;
      proc contents data=CPS.hhld&yr. varnum;
      proc print data=CPS.hhld&yr.(obs=20);
         var h_seq hhpos h_type h_year h_numper hnumfam hg_fips htotval hearnval hothval hwsval hwsval hseval hfrval hsup_wgt;
      run;
      run;
   %end;
%mend;
%loop;

%macro loop;
   %do yr=&ACSstart %to &ACSend;
      proc contents data=ACS.acs&yr. varnum;
      proc print data=ACS.acs&yr.(obs=100);
         var CMID PNUM pwgt wgt NP SFN rel ST rdate sex age pows GQ;
         var                          frel         fsex fage fpows; 
         var wag sem int ss ssi pa ret oi ti pern pinc wkh wkw esr;
         var fwag fsem fint fss fssi fpa fret foi fti fpernpct fpincpct fwkh fwkw fesr;
      run;
      proc contents data=ACSPIK.acs_&yr._crosswalk varnum;
      *proc print data=ACS.acs_&yr._crosswalk(obs=25);
         *var fh_seq ffpos ffposold fpersons fearns ftotval fearnval fothval fwsval fseval ffrval fsup_wgt;
      *run;
   %end;
%mend;
%loop;

