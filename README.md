# laglead
SAS utilities for dynamic lead/lag value access.

![laglead](./laglead_small.png)

# %laglead()
Purpose:
  Creates shifted copies of variable `var` by looking up the value from the  
  same dataset at ﾂｱoffset rows  based on row numbers. Negative offset = lag,  
  positive offset = lead, offset=0 points to the current row.  

Parameters:  
~~~text
  dataset=  Input dataset name (REQUIRED). Typically, specify the exact same  
            dataset as the one used in the  DATA step窶冱 SET statement;  
  var=      Target variable to shift/copy (REQUIRED)  
  offset=   Integer only. Negative=lag, Positive=lead, default -1. Decimals not allowed  
  id=       Optional group ID (SINGLE variable only). When specified, the dataset  
            MUST be pre-sorted and contiguous by `id`
~~~

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
~~~sas
  data a;
    set sashelp.class(keep=name);
    %laglead(dataset=sashelp.class, var=name, offset=-1);
    %laglead(dataset=sashelp.class, var=name, offset=+2);
  run;
~~~

~~~sas
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
~~~

run;
