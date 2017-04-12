*** Merge Census Numident (cnum) with the UI to see what records match ***;

%include "config.sas";
%include "pik2full.sas";

%let obsv=max;

%let cnvars=pik dobcc dobdd dobmm dobyy
                 dodcc doddd dodmm dodyy
                 ocycc ocydd ocymm ocyyy
                 gender
                 bestrace
                 pobfin pobst
                 ssn3st;

%let uivars=pik;

proc sort data=cnum.cnum_2012(keep=&cnvars) out=outputs.cnum_pik;
   by pik;
run;

proc contents data=outputs.cnum_pik;
run;

data temp0;
   %sline(lib=ui,data=analysis_dataset,keepvars=&uivars,type=0);
run;

proc sort data=temp0 out=uipik nodupkey;
   by pik;
run;

data outputs.merge_cnum_ui;
   merge outputs.cnum_pik(in=a keep=pik) uipik(in=b);
      by pik;

   length source 3;

   source=a+2*b;

   label source="1=CnumOnly 2=UIOnly 3=Both";
run;

proc contents data=outputs.merge_cnum_ui;
proc tabulate data=outputs.merge_cnum_ui;
   class source /missing;
   table source all, n*f=comma14.0 pctn;
run;
proc print data=outputs.merge_cnum_ui(obs=100);
run;
