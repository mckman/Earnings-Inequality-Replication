*** Print the distribution category counts by year ****;

%include "config.sas";

options obs=max;

proc print data=dot.hc_year2;
run;

proc summary data=dot.hc_year2 nway;
   class year;
   output out=temp1y sum(COUNT)=count_year;
run;

proc means data=temp1y;
run;

data temp1;
   merge dot.hc_year2(drop=PERCENT) temp1y(drop=_TYPE_ _FREQ_);
      by year;

   retain ft_1 ft_2 ft_3 ft_4;

   if first.year then do;
      ft_1=0;
      ft_2=0;
      ft_3=0;
      ft_4=0;
   end;

   if lf_r=. then ft_1=ft_1+COUNT;
   else if lf_r>=0 and lf_r<=1 then ft_2=ft_2+COUNT;
   else if lf_r>=2 and lf_r<=7 then ft_3=ft_3+COUNT;
   else if lf_r>=8 and lf_r<=9 then ft_4=ft_4+COUNT;

   if last.year then do;
      ft_1_p=ft_1/count_year;
      ft_2_p=ft_2/count_year;
      ft_3_p=ft_3/count_year;
      ft_4_p=ft_4/count_year;
      output;
   end;
run;

proc print data=temp1;
   var year ft_1 ft_2 ft_3 ft_4 ft_1_p ft_2_p ft_3_p ft_4_p;
run;
