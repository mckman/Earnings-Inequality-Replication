*** Percent of UI Records by Type ***;

%include "config.sas";

libname in_meta "/mixedtmp/co00538/snap_user/s2013_2015_07_30/library/sasdata";

proc summary data=in_meta.st_yr_qtr_pik2(where=(yr_qtr="2012:1")) nway;
   class state ui;
   output out=temp1 sum(count earn)=cnt ern;
run;

proc print data=temp1;
   format cnt ern COMMA15.0;
run;

proc summary data=in_meta.st_yr_qtr_pik2(where=(yr_qtr="2012:1")) nway;
   output out=temp1t sum(count earn)=cnt_t ern_t;
run;

proc print data=temp1t;
   format cnt_t ern_t COMMA24.0;
run;

proc summary data=in_meta.st_yr_qtr_pik2(where=(yr_qtr="2012:1")) nway;
   class state;
   output out=temp1s sum(count earn)=cnt_s ern_s;
run;

proc print data=temp1s;
   format cnt_s ern_s COMMA24.0;
run;

data temp2(drop=ui);
   merge temp1(drop=_FREQ_ _TYPE_) temp1s(keep=state cnt_s ern_s);
      by state;
  
   retain pct_cnt_ui pct_cnt_op pct_ern_ui pct_ern_op;

   if first.state then do;
      pct_cnt_ui=.;
      pct_cnt_op=.;
      pct_ern_ui=.;
      pct_ern_op=.;
   end;

   if ui="1" then pct_cnt_ui=cnt/cnt_s;
   if ui="0" then pct_cnt_op=cnt/cnt_s;

   if ui="1" then pct_ern_ui=ern/ern_s;
   if ui="0" then pct_ern_op=ern/ern_s;

   if last.state then output;
run;

proc print data=temp2;
   format cnt ern COMMA17.0 pct_cnt_ui pct_cnt_op pct_ern_ui pct_ern_op PERCENT8.2;
run;

data temp3;
   retain cnt_t ern_t;
   if _N_=1 then set temp1t(keep=cnt_t ern_t);

   set temp1s;
     

   pct_cnt_t=cnt_s/cnt_t;
   pct_ern_t=ern_s/ern_t;
run;

proc print data=temp3;
   format cnt ern COMMA17.0 pct_cnt_t pct_ern_t PERCENT8.2;
run;

proc summary data=in_meta.st_yr_qtr_pik2(where=(yr_qtr="2012:1" and state~="DC")) nway;
   class ui;
   output out=temp1u sum(count earn)=cnt_u ern_u;
run;
proc print data=temp1u;
   format cnt_u ern_u COMMA24.0;
run;

proc summary data=in_meta.st_yr_qtr_pik2(where=(yr_qtr="2012:1" and state="DC")) nway;
   class ui;
   output out=temp1u sum(count earn)=cnt_u ern_u;
run;
proc print data=temp1u;
   format cnt_u ern_u COMMA24.0;
run;
