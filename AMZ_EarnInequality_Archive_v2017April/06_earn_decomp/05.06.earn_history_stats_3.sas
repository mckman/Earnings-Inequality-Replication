**** Create stats for eligible=10 workers ***;

%include "config.sas";


data temp1(drop=_merge) temp1m(keep=_merge);
   merge outputs.pik_year_hc_dist(in=a keep=pik year earn_type DOB gender) outputs.pik_year_earn_history(in=b); 
      by pik year;

   length _merge fm9 fm8 fm7 fm6 fm5 fm4 fm3 fm2 fm1 fz0 fp1 fp2 fp3 fp4 fp5 fp6 fp7 fp8 3;

   _merge=a+2*b;

   fm9=sm9>.;
   fm8=sm8>.;
   fm7=sm7>.;
   fm6=sm6>.;
   fm5=sm5>.;
   fm4=sm4>.;
   fm3=sm3>.;
   fm2=sm2>.;
   fm1=sm1>.;
   fz0=sz0>.;
   fp1=sp1>.;
   fp2=sp2>.;
   fp3=sp3>.;
   fp4=sp4>.;
   fp5=sp5>.;
   fp6=sp6>.;
   fp7=sp7>.;
   fp8=sp8>.;

   date1=mdy(1,1,year);
   date2=mdy(12,31,year);
   age1=(date1-DOB)/365.2425;
   age2=(date2-DOB)/365.2425;

   if age2>=25 and age1<=45 and _merge=3 then output temp1;
   output temp1m;

run;

proc contents data=temp1;
proc tabulate data=temp1m;
   class _merge /missing;
   table _merge all, n*f=comma14.0 pctn;
run;
proc print data=temp1(obs=1000);
run;

proc summary data=temp1(where=(never_work=0)) nway;
   class gender earn_type;
   output out=dy_ff(drop=_TYPE_) sum(fm9 fm8 fm7 fm6 fm5 fm4 fm3 fm2 fm1 fz0 fp1 fp2 fp3 fp4 fp5 fp6 fp7 fp8)=
                   s_fm9 s_fm8 s_fm7 s_fm6 s_fm5 s_fm4 s_fm3 s_fm2 s_fm1 s_fz0 s_fp1 s_fp2 s_fp3 s_fp4 s_fp5 s_fp6 s_fp7 s_fp8;
run;
proc print data=dy_ff;
run;

proc summary data=temp1(where=(never_work=0)) nway;
   class gender earn_type;
   output out=dy_ee(drop=_TYPE_) sum(em9 em8 em7 em6 em5 em4 em3 em2 em1 ez0 ep1 ep2 ep3 ep4 ep5 ep6 ep7 ep8)=
                   s_em9 s_em8 s_em7 s_em6 s_em5 s_em4 s_em3 s_em2 s_em1 s_ez0 s_ep1 s_ep2 s_ep3 s_ep4 s_ep5 s_ep6 s_ep7 s_ep8;
run;
proc print data=dy_ee;
run;

proc summary data=temp1(where=(never_work=0)) nway;
   class gender earn_type;
   output out=dy_cc(drop=_TYPE_) sum(cm9 cm8 cm7 cm6 cm5 cm4 cm3 cm2 cm1 cz0 cp1 cp2 cp3 cp4 cp5 cp6 cp7 cp8)=
                   s_cm9 s_cm8 s_cm7 s_cm6 s_cm5 s_cm4 s_cm3 s_cm2 s_cm1 s_cz0 s_cp1 s_cp2 s_cp3 s_cp4 s_cp5 s_cp6 s_cp7 s_cp8;
run;
proc print data=dy_cc;
run;

proc summary data=temp1(where=(never_work=0)) nway;
   class gender earn_type;
   output out=dy_ss(drop=_TYPE_) sum(sm9 sm8 sm7 sm6 sm5 sm4 sm3 sm2 sm1 sz0 sp1 sp2 sp3 sp4 sp5 sp6 sp7 sp8)=
                   s_sm9 s_sm8 s_sm7 s_sm6 s_sm5 s_sm4 s_sm3 s_sm2 s_sm1 s_sz0 s_sp1 s_sp2 s_sp3 s_sp4 s_sp5 s_sp6 s_sp7 s_sp8;
run;
proc print data=dy_ss;
run;

proc summary data=temp1(where=(never_work=0)) nway;
   class gender earn_type;
   output out=dy_aa(drop=_TYPE_) sum(am9 am8 am7 am6 am5 am4 am3 am2 am1 az0 ap1 ap2 ap3 ap4 ap5 ap6 ap7 ap8)=
                   s_am9 s_am8 s_am7 s_am6 s_am5 s_am4 s_am3 s_am2 s_am1 s_az0 s_ap1 s_ap2 s_ap3 s_ap4 s_ap5 s_ap6 s_ap7 s_ap8;
run;
proc print data=dy_aa;
run;

proc summary data=temp1(where=(never_work=0)) nway;
   class gender earn_type;
   output out=dy_ii(drop=_TYPE_) sum(im9 im8 im7 im6 im5 im4 im3 im2 im1 iz0 ip1 ip2 ip3 ip4 ip5 ip6 ip7 ip8)=
                   s_im9 s_im8 s_im7 s_im6 s_im5 s_im4 s_im3 s_im2 s_im1 s_iz0 s_ip1 s_ip2 s_ip3 s_ip4 s_ip5 s_ip6 s_ip7 s_ip8;
run;
proc print data=dy_ii;
run;

data dot.emp_history_3;
   merge dy_ff(rename=(_FREQ_=count_ff))
         dy_ee(rename=(_FREQ_=count_ee)) 
         dy_cc(rename=(_FREQ_=count_cc))
         dy_ss(rename=(_FREQ_=count_ss))
         dy_aa(rename=(_FREQ_=count_aa))
         dy_ii(rename=(_FREQ_=count_ii));
      by gender earn_type;
run;
