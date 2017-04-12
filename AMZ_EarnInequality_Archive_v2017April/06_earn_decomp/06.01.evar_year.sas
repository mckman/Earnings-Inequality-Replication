*** Current year earnings measures ***;

%include "config.sas";

options ls=240;

*** average earnings for all eligible persons ***;
title "average earnings for all eligible persons";

data temp1(keep=year never_work earn_type e_all_m9 e_all_m8 e_all_m7 e_all_m6 e_all_m5 e_all_m4 e_all_m3 e_all_m2 e_all_m1
                                count_ee  e_all_z0 e_all_p1 e_all_p2 e_all_p3 e_all_p4 e_all_p5 e_all_p6 e_all_p7 e_all_p8);
   set dot.emp_history;

   e_all_m9=s_em9/count_ee;
   e_all_m8=s_em8/count_ee;
   e_all_m7=s_em7/count_ee;
   e_all_m6=s_em6/count_ee;
   e_all_m5=s_em5/count_ee;
   e_all_m4=s_em4/count_ee;
   e_all_m3=s_em3/count_ee;
   e_all_m2=s_em2/count_ee;
   e_all_m1=s_em1/count_ee;
   e_all_z0=s_ez0/count_ee;
   e_all_p1=s_ep1/count_ee;
   e_all_p2=s_ep2/count_ee;
   e_all_p3=s_ep3/count_ee;
   e_all_p4=s_ep4/count_ee;
   e_all_p5=s_ep5/count_ee;
   e_all_p6=s_ep6/count_ee;
   e_all_p7=s_ep7/count_ee;
   e_all_p8=s_ep8/count_ee;
run;

proc sort data=temp1;
   by never_work earn_type year;
run;

proc print data=temp1;
   format count_ee COMMA10.0 e_all_m9 e_all_m8 e_all_m7 e_all_m6 e_all_m5 e_all_m4 e_all_m3 e_all_m2 e_all_m1
          e_all_z0 e_all_p1 e_all_p2 e_all_p3 e_all_p4 e_all_p5 e_all_p6 e_all_p7 e_all_p8 COMMA9.0;
run;

*** average earnings for all persons with earn>0 ***;
title "average earnings for all persons with earn>0";

data temp1(keep=year never_work earn_type e_pos_m9 e_pos_m8 e_pos_m7 e_pos_m6 e_pos_m5 e_pos_m4 e_pos_m3 e_pos_m2 e_pos_m1
                                count_ss  e_pos_z0 e_pos_p1 e_pos_p2 e_pos_p3 e_pos_p4 e_pos_p5 e_pos_p6 e_pos_p7 e_pos_p8);
   set dot.emp_history;

   if s_sm9>0 then e_pos_m9=s_em9/s_sm9;
   if s_sm8>0 then e_pos_m8=s_em8/s_sm8;
   if s_sm7>0 then e_pos_m7=s_em7/s_sm7;
   if s_sm6>0 then e_pos_m6=s_em6/s_sm6;
   if s_sm5>0 then e_pos_m5=s_em5/s_sm5;
   if s_sm4>0 then e_pos_m4=s_em4/s_sm4;
   if s_sm3>0 then e_pos_m3=s_em3/s_sm3;
   if s_sm2>0 then e_pos_m2=s_em2/s_sm2;
   if s_sm1>0 then e_pos_m1=s_em1/s_sm1;
   if s_sz0>0 then e_pos_z0=s_ez0/s_sz0;
   if s_sp1>0 then e_pos_p1=s_ep1/s_sp1;
   if s_sp2>0 then e_pos_p2=s_ep2/s_sp2;
   if s_sp3>0 then e_pos_p3=s_ep3/s_sp3;
   if s_sp4>0 then e_pos_p4=s_ep4/s_sp4;
   if s_sp5>0 then e_pos_p5=s_ep5/s_sp5;
   if s_sp6>0 then e_pos_p6=s_ep6/s_sp6;
   if s_sp7>0 then e_pos_p7=s_ep7/s_sp7;
   if s_sp8>0 then e_pos_p8=s_ep8/s_sp8;
run;

proc sort data=temp1;
   by never_work earn_type year;
run;

proc print data=temp1;
   format count_ss COMMA10.0 e_pos_m9 e_pos_m8 e_pos_m7 e_pos_m6 e_pos_m5 e_pos_m4 e_pos_m3 e_pos_m2 e_pos_m1
          e_pos_z0 e_pos_p1 e_pos_p2 e_pos_p3 e_pos_p4 e_pos_p5 e_pos_p6 e_pos_p7 e_pos_p8 COMMA9.0;
run;

*** Percent Persons with earn>0 ***;
title "Percent Persons with earn>0";

data temp1(keep=year never_work earn_type w_pos_m9 w_pos_m8 w_pos_m7 w_pos_m6 w_pos_m5 w_pos_m4 w_pos_m3 w_pos_m2 w_pos_m1
                                count_ss  w_pos_z0 w_pos_p1 w_pos_p2 w_pos_p3 w_pos_p4 w_pos_p5 w_pos_p6 w_pos_p7 w_pos_p8);
   set dot.emp_history;

   w_pos_m9=s_sm9/count_ee;
   w_pos_m8=s_sm8/count_ee;
   w_pos_m7=s_sm7/count_ee;
   w_pos_m6=s_sm6/count_ee;
   w_pos_m5=s_sm5/count_ee;
   w_pos_m4=s_sm4/count_ee;
   w_pos_m3=s_sm3/count_ee;
   w_pos_m2=s_sm2/count_ee;
   w_pos_m1=s_sm1/count_ee;
   w_pos_z0=s_sz0/count_ee;
   w_pos_p1=s_sp1/count_ee;
   w_pos_p2=s_sp2/count_ee;
   w_pos_p3=s_sp3/count_ee;
   w_pos_p4=s_sp4/count_ee;
   w_pos_p5=s_sp5/count_ee;
   w_pos_p6=s_sp6/count_ee;
   w_pos_p7=s_sp7/count_ee;
   w_pos_p8=s_sp8/count_ee;
run;

proc sort data=temp1;
   by never_work earn_type year;
run;

proc print data=temp1;
   format count_ss COMMA10.0 w_pos_m9 w_pos_m8 w_pos_m7 w_pos_m6 w_pos_m5 w_pos_m4 w_pos_m3 w_pos_m2 w_pos_m1
          w_pos_z0 w_pos_p1 w_pos_p2 w_pos_p3 w_pos_p4 w_pos_p5 w_pos_p6 w_pos_p7 w_pos_p8 COMMA6.4;
run;

*** CUMULATIVE SECTION ***;

*** average cumulative earnings for all eligible persons ***;
title "average cumulative earnings for all eligible persons"; 

data temp1(keep=year never_work earn_type ec_all_m9 ec_all_m8 ec_all_m7 ec_all_m6 ec_all_m5 ec_all_m4 ec_all_m3 ec_all_m2 ec_all_m1
                                count_ee  ec_all_z0 ec_all_p1 ec_all_p2 ec_all_p3 ec_all_p4 ec_all_p5 ec_all_p6 ec_all_p7 ec_all_p8);
   set dot.emp_history;

   ec_all_m9=s_cm9/count_ee;
   ec_all_m8=s_cm8/count_ee;
   ec_all_m7=s_cm7/count_ee;
   ec_all_m6=s_cm6/count_ee;
   ec_all_m5=s_cm5/count_ee;
   ec_all_m4=s_cm4/count_ee;
   ec_all_m3=s_cm3/count_ee;
   ec_all_m2=s_cm2/count_ee;
   ec_all_m1=s_cm1/count_ee;
   ec_all_z0=s_cz0/count_ee;
   ec_all_p1=s_cp1/count_ee;
   ec_all_p2=s_cp2/count_ee;
   ec_all_p3=s_cp3/count_ee;
   ec_all_p4=s_cp4/count_ee;
   ec_all_p5=s_cp5/count_ee;
   ec_all_p6=s_cp6/count_ee;
   ec_all_p7=s_cp7/count_ee;
   ec_all_p8=s_cp8/count_ee;
run;

proc sort data=temp1;
   by never_work earn_type year;
run;

proc print data=temp1;
   format count_ee COMMA10.0 ec_all_m9 ec_all_m8 ec_all_m7 ec_all_m6 ec_all_m5 ec_all_m4 ec_all_m3 ec_all_m2 ec_all_m1
          ec_all_z0 ec_all_p1 ec_all_p2 ec_all_p3 ec_all_p4 ec_all_p5 ec_all_p6 ec_all_p7 ec_all_p8 COMMA10.0;
run;


*** cumulate average annual earnings per year for all eligible persons ***;
title "cumulate average annual earnings per year for all eligible persons";

data temp1(keep=year never_work earn_type eca_all_m9 eca_all_m8 eca_all_m7 eca_all_m6 eca_all_m5 eca_all_m4 eca_all_m3 eca_all_m2 eca_all_m1
                                count_ss  eca_all_z0 eca_all_p1 eca_all_p2 eca_all_p3 eca_all_p4 eca_all_p5 eca_all_p6 eca_all_p7 eca_all_p8);
   set dot.emp_history;

   if (s_am9+s_im9)>0 then eca_all_m9=s_cm9/(s_am9+s_im9);
   if (s_am8+s_im8)>0 then eca_all_m8=s_cm8/(s_am8+s_im8);
   if (s_am7+s_im7)>0 then eca_all_m7=s_cm7/(s_am7+s_im7);
   if (s_am6+s_im6)>0 then eca_all_m6=s_cm6/(s_am6+s_im6);
   if (s_am5+s_im5)>0 then eca_all_m5=s_cm5/(s_am5+s_im5);
   if (s_am4+s_im4)>0 then eca_all_m4=s_cm4/(s_am4+s_im4);
   if (s_am3+s_im3)>0 then eca_all_m3=s_cm3/(s_am3+s_im3);
   if (s_am2+s_im2)>0 then eca_all_m2=s_cm2/(s_am2+s_im2);
   if (s_am1+s_im1)>0 then eca_all_m1=s_cm1/(s_am1+s_im1);
   if (s_az0+s_iz0)>0 then eca_all_z0=s_cz0/(s_az0+s_iz0);
   if (s_ap1+s_ip1)>0 then eca_all_p1=s_cp1/(s_ap1+s_ip1);
   if (s_ap2+s_ip2)>0 then eca_all_p2=s_cp2/(s_ap2+s_ip2);
   if (s_ap3+s_ip3)>0 then eca_all_p3=s_cp3/(s_ap3+s_ip3);
   if (s_ap4+s_ip4)>0 then eca_all_p4=s_cp4/(s_ap4+s_ip4);
   if (s_ap5+s_ip5)>0 then eca_all_p5=s_cp5/(s_ap5+s_ip5);
   if (s_ap6+s_ip6)>0 then eca_all_p6=s_cp6/(s_ap6+s_ip6);
   if (s_ap7+s_ip7)>0 then eca_all_p7=s_cp7/(s_ap7+s_ip7);
   if (s_ap8+s_ip8)>0 then eca_all_p8=s_cp8/(s_ap8+s_ip8);
run;

proc sort data=temp1;
   by never_work earn_type year;
run;

proc print data=temp1;
   format count_ss COMMA10.0 eca_all_m9 eca_all_m8 eca_all_m7 eca_all_m6 eca_all_m5 eca_all_m4 eca_all_m3 eca_all_m2 eca_all_m1
          eca_all_z0 eca_all_p1 eca_all_p2 eca_all_p3 eca_all_p4 eca_all_p5 eca_all_p6 eca_all_p7 eca_all_p8 COMMA9.0;
run;

*** cumulate average annual earnings per year for years where earn>0 ***;
title "cumulate average annual earnings per year for years where earn>0";

data temp1(keep=year never_work earn_type eca_pos_m9 eca_pos_m8 eca_pos_m7 eca_pos_m6 eca_pos_m5 eca_pos_m4 eca_pos_m3 eca_pos_m2 eca_pos_m1
                                count_ss  eca_pos_z0 eca_pos_p1 eca_pos_p2 eca_pos_p3 eca_pos_p4 eca_pos_p5 eca_pos_p6 eca_pos_p7 eca_pos_p8);
   set dot.emp_history;

   if (s_am9)>0 then eca_pos_m9=s_cm9/(s_am9);
   if (s_am8)>0 then eca_pos_m8=s_cm8/(s_am8);
   if (s_am7)>0 then eca_pos_m7=s_cm7/(s_am7);
   if (s_am6)>0 then eca_pos_m6=s_cm6/(s_am6);
   if (s_am5)>0 then eca_pos_m5=s_cm5/(s_am5);
   if (s_am4)>0 then eca_pos_m4=s_cm4/(s_am4);
   if (s_am3)>0 then eca_pos_m3=s_cm3/(s_am3);
   if (s_am2)>0 then eca_pos_m2=s_cm2/(s_am2);
   if (s_am1)>0 then eca_pos_m1=s_cm1/(s_am1);
   if (s_az0)>0 then eca_pos_z0=s_cz0/(s_az0);
   if (s_ap1)>0 then eca_pos_p1=s_cp1/(s_ap1);
   if (s_ap2)>0 then eca_pos_p2=s_cp2/(s_ap2);
   if (s_ap3)>0 then eca_pos_p3=s_cp3/(s_ap3);
   if (s_ap4)>0 then eca_pos_p4=s_cp4/(s_ap4);
   if (s_ap5)>0 then eca_pos_p5=s_cp5/(s_ap5);
   if (s_ap6)>0 then eca_pos_p6=s_cp6/(s_ap6);
   if (s_ap7)>0 then eca_pos_p7=s_cp7/(s_ap7);
   if (s_ap8)>0 then eca_pos_p8=s_cp8/(s_ap8);
run;

proc sort data=temp1;
   by never_work earn_type year;
run;

proc print data=temp1;
   format count_ss COMMA10.0 eca_pos_m9 eca_pos_m8 eca_pos_m7 eca_pos_m6 eca_pos_m5 eca_pos_m4 eca_pos_m3 eca_pos_m2 eca_pos_m1
          eca_pos_z0 eca_pos_p1 eca_pos_p2 eca_pos_p3 eca_pos_p4 eca_pos_p5 eca_pos_p6 eca_pos_p7 eca_pos_p8 COMMA9.0;
run;

*** Cumulative years earn>0 per eligible person ***;
title "Cumulative years earn>0 per eligible person";

data temp1(keep=year never_work earn_type wca_all_m9 wca_all_m8 wca_all_m7 wca_all_m6 wca_all_m5 wca_all_m4 wca_all_m3 wca_all_m2 wca_all_m1
                                count_ss  wca_all_z0 wca_all_p1 wca_all_p2 wca_all_p3 wca_all_p4 wca_all_p5 wca_all_p6 wca_all_p7 wca_all_p8);
   set dot.emp_history;

   wca_all_m9=s_am9/count_ee;
   wca_all_m8=s_am8/count_ee;
   wca_all_m7=s_am7/count_ee;
   wca_all_m6=s_am6/count_ee;
   wca_all_m5=s_am5/count_ee;
   wca_all_m4=s_am4/count_ee;
   wca_all_m3=s_am3/count_ee;
   wca_all_m2=s_am2/count_ee;
   wca_all_m1=s_am1/count_ee;
   wca_all_z0=s_az0/count_ee;
   wca_all_p1=s_ap1/count_ee;
   wca_all_p2=s_ap2/count_ee;
   wca_all_p3=s_ap3/count_ee;
   wca_all_p4=s_ap4/count_ee;
   wca_all_p5=s_ap5/count_ee;
   wca_all_p6=s_ap6/count_ee;
   wca_all_p7=s_ap7/count_ee;
   wca_all_p8=s_ap8/count_ee;
run;

proc sort data=temp1;
   by never_work earn_type year;
run;

proc print data=temp1;
   format count_ss COMMA10.0 wca_all_m9 wca_all_m8 wca_all_m7 wca_all_m6 wca_all_m5 wca_all_m4 wca_all_m3 wca_all_m2 wca_all_m1
          wca_all_z0 wca_all_p1 wca_all_p2 wca_all_p3 wca_all_p4 wca_all_p5 wca_all_p6 wca_all_p7 wca_all_p8 COMMA6.4;
run;


*** Cumulative average percent years with earn>0 ***;
title "Cumulative average percent years with earn>0";

data temp1(keep=year never_work earn_type wca_pos_m9 wca_pos_m8 wca_pos_m7 wca_pos_m6 wca_pos_m5 wca_pos_m4 wca_pos_m3 wca_pos_m2 wca_pos_m1
                                count_ss  wca_pos_z0 wca_pos_p1 wca_pos_p2 wca_pos_p3 wca_pos_p4 wca_pos_p5 wca_pos_p6 wca_pos_p7 wca_pos_p8);
   set dot.emp_history;

   if (s_am9+s_im9)>0 then wca_pos_m9=s_am9/(s_am9+s_im9);
   if (s_am8+s_im8)>0 then wca_pos_m8=s_am8/(s_am8+s_im8);
   if (s_am7+s_im7)>0 then wca_pos_m7=s_am7/(s_am7+s_im7);
   if (s_am6+s_im6)>0 then wca_pos_m6=s_am6/(s_am6+s_im6);
   if (s_am5+s_im5)>0 then wca_pos_m5=s_am5/(s_am5+s_im5);
   if (s_am4+s_im4)>0 then wca_pos_m4=s_am4/(s_am4+s_im4);
   if (s_am3+s_im3)>0 then wca_pos_m3=s_am3/(s_am3+s_im3);
   if (s_am2+s_im2)>0 then wca_pos_m2=s_am2/(s_am2+s_im2);
   if (s_am1+s_im1)>0 then wca_pos_m1=s_am1/(s_am1+s_im1);
   if (s_az0+s_iz0)>0 then wca_pos_z0=s_az0/(s_az0+s_iz0);
   if (s_ap1+s_ip1)>0 then wca_pos_p1=s_ap1/(s_ap1+s_ip1);
   if (s_ap2+s_ip2)>0 then wca_pos_p2=s_ap2/(s_ap2+s_ip2);
   if (s_ap3+s_ip3)>0 then wca_pos_p3=s_ap3/(s_ap3+s_ip3);
   if (s_ap4+s_ip4)>0 then wca_pos_p4=s_ap4/(s_ap4+s_ip4);
   if (s_ap5+s_ip5)>0 then wca_pos_p5=s_ap5/(s_ap5+s_ip5);
   if (s_ap6+s_ip6)>0 then wca_pos_p6=s_ap6/(s_ap6+s_ip6);
   if (s_ap7+s_ip7)>0 then wca_pos_p7=s_ap7/(s_ap7+s_ip7);
   if (s_ap8+s_ip8)>0 then wca_pos_p8=s_ap8/(s_ap8+s_ip8);
run;

proc sort data=temp1;
   by never_work earn_type year;
run;

proc print data=temp1;
   format count_ss COMMA10.0 wca_pos_m9 wca_pos_m8 wca_pos_m7 wca_pos_m6 wca_pos_m5 wca_pos_m4 wca_pos_m3 wca_pos_m2 wca_pos_m1
          wca_pos_z0 wca_pos_p1 wca_pos_p2 wca_pos_p3 wca_pos_p4 wca_pos_p5 wca_pos_p6 wca_pos_p7 wca_pos_p8 COMMA6.4;
run;

