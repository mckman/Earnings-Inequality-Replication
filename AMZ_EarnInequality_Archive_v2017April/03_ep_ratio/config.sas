/* Configuration File */

*** OPTIONS ***;
options mlogic mprint symbolgen fullstimer msglevel=i ps=200 ls=200 nocenter obs=max;

%let obsv=max;

%let vshort=all;
%let vlong=&vshort._real_earn;

*** Vintage: snapshot | release date ***;
%let vintage = s2013_2015_07_30;

*** LIBNAMES ***;
libname dot ".";
libname cnum "";
libname ui "";
libname outputs "";

libname hcdom "";
libname hcall "";

libname out_ecf "";

*** States in LEHD ***;
%LET states = ak al ar az ca co ct dc de fl
              ga hi ia id il in ks ky la ma
              md me mi mn mo ms mt nc nd ne
              nh nj nm nv ny oh ok or pa ri
              sc sd tn tx ut va vt wa wi wv
              wy;

*** Start and end dates for qtime ***;
%LET ystart = 1985; *DO NOT ALTER (earliest year quarter of available UI data is 1985q1);
%LET qstart = 1; *DO NOT ALTER (earliest year quarter of available UI data is 1985q1);

%LET yend = 2014; *LAST AVAILABLE YEAR OF DATA ON SNAPSHOT 2013;
%LET qend = 3; *LAST AVAILABLE QUARTER OF DATA ON SNAPSHOT 2013;

*** Analysis years for AKM ***;
%LET ymin = 1990;
%LET ymax = 2013;

*** Macro to set the Earnings Data ***;
%macro sline(lib=,data=,keepvars=,type=);
   set
   %let i=1;
   %let NN = %scan(&PIK2short.,&i.);
   %do %until ("&NN" = "");
       %if &type=1 %then %do;
          &lib..&data._&NN.(keep=&keepvars. obs=&obsv.)
       %end;
       %else %do;
          &lib..pik&NN._&data(keep=&keepvars obs=&obsv)
       %end;
       %let i = %eval(&i.+1);
       %let NN = %scan(&PIK2short.,&i.," ");
   %end;;
%mend;


*** CPS/ACS earnings ***;
/* Reference year for real annual earnings */
	%let refyr=2000;
	%let refqtr=1;

*** UI ***;
/* Set dates for which UI data is available */
        %let UIstart = 1985; *earliest YEAR;
        %let UIend = 2014; *latest YEAR;
        %let qmax=%eval( 4 * ((&UIend - &UIstart)+1));  * latest sequential quarter for any state data;

*** CPS ***;
/* Set dates for which CPS data is available */
        %let CPSstart = 1990; *earliest INTERVIEW YEAR;
        %let CPSend = 2004; *latest INTERVIEW YEAR;

*** ACS ***;
/* Set dates for which ACS data is available */
        %let ACSstart = 2001; *RELEASE YEAR;
        %let ACSend = 2013; *RELEASE YEAR;

/* Year of format change to question: weeks worked in the past 12 months */
        %let ACSreformat = 2008; *RELEASE YEAR;

/* Path to CPS */
        libname CPS      "";
        libname CPSPIK   "";

/* ACS contains the data and ACSPIK contains the crosswalk files */
        libname ACS    "";
        libname ACSPIK "";

/* Path to the UI data */
       ***libname ui ("","") access=readonly;

/* Path to the OPM data */
       ***libname ui_opm ("","") access=readonly; 

*** CPS/ACS - user output files ***;
libname CPSACS "";
