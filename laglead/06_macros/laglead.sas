/*** HELP START ***//*

Macro: laglead

Purpose:
  Creates shifted copies of variable `var` by looking up the value from the
  same dataset at ±offset rows  based on row numbers. Negative offset = lag,
  positive offset = lead, offset=0 points to the current row.

Parameters:
  dataset=  Input dataset name (REQUIRED). Typically, specify the exact same
            dataset as the one used in the  DATA step’s SET statement;
  var=      Target variable to shift/copy (REQUIRED)
  offset=   Integer only. Negative=lag, Positive=lead, default -1. Decimals not allowed
  id=       Optional group ID (SINGLE variable only). When specified, the dataset
            MUST be pre-sorted and contiguous by `id`

Assumptions & Constraints:
  - `offset` must be an integer (no decimals)
  - `id` supports ONLY one variable (no composite keys)
  - If `id` is provided, the input must be sorted by `id` and records must be contiguous
  - Row-number-based lookup: with `id`, shifts occur within the same `id`;
    without `id`, shifts use the physical order of the dataset
  - Missing is returned when the target row does not exist

Output (naming convention):
  - offset<0:  &var._prev_abs(offset)
  - offset>0:  &var._next_abs(offset)
  - offset=0:  &var._next_0 (by current implementation)

Examples:
  data a;
    set sashelp.class(keep=name);
    %laglead(dataset=sashelp.class, var=name, offset=-1);
    %laglead(dataset=sashelp.class, var=name, offset=+2);
  run;

data b;
SUBJID="A";VISITNUM=1;AVAL=10;output;
SUBJID="A";VISITNUM=1;AVAL=20;output;
SUBJID="A";VISITNUM=1;AVAL=30;output;
SUBJID="A";VISITNUM=1;AVAL=40;output;
SUBJID="B";VISITNUM=1;AVAL=11;output;
SUBJID="B";VISITNUM=1;AVAL=21;output;
SUBJID="B";VISITNUM=1;AVAL=31;output;
run;

data c;
set b;
%laglead(
dataset=b
,var=AVAL
,offset= -1
,id=SUBJID
);

%laglead(
dataset=b
,var=AVAL
,offset= +1
,id=SUBJID
);

run;

*//*** HELP END ***/

%macro laglead(
dataset=
,var=
,offset = -1
,id =
);

%if %length(&dataset) eq 0 %then %do;
    %put ERROR:Be sure to include the dataset. Basically, specify the same thing as what is set.;
    %goto eoflabel ;
%end;
%if %length(&var) eq 0 %then %do;
    %put ERROR:var is Null;
    %goto eoflabel ;
%end;

key_obs = _N_ + &offset;

%let name  = &sysindex;
%if %eval(&offset) < 0 %then %do;
  %let _offset = _prev_%sysfunc(abs(&offset));
%end; 
%if %eval(&offset) >= 0 %then %do;
  %let _offset = _next_%sysfunc(abs(&offset));
%end; 

if 0 then set &dataset(keep=&var. rename=(&var.=&var&_offset.));

retain _N_&name 1;
if _N_&name = 1 then do;
  rc&name.=dosubl("
  data temp&name/view= temp&name.;
  set &dataset;
  key_obs = _N_ ;
  &var&_offset=&var;
  keep key_obs &var&_offset &id;
  run;
  ");
  declare hash h&name.(dataset:"temp&name.(keep= key_obs &var&_offset &id)" ,  duplicate:'E');
  %if %length(&id) eq 0 %then %do;
    h&name..definekey("key_obs");
  %end;
  %if %length(&id) ne 0 %then %do;
    h&name..definekey("key_obs", "&id");
  %end;
  h&name..definedata("&var&_offset");
  h&name..definedone();
  _N_&name = 0 ;
  call execute("proc sql noprint;
  drop view temp&name. ;
  quit;");
  drop  key_obs rc&name.;
end;

drop _N_&name ;

if h&name..find() ne  0 then do;
  call missing(of &var&_offset );
end;

%eoflabel:
%mend laglead;
