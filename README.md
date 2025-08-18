# laglead
SAS utilities for dynamic lead/lag value access.  

<img width="180" height="180" alt="Image" src="https://github.com/user-attachments/assets/4fdc3e81-4584-4b0a-a285-2bae2f252f58" />

# %laglead()
Purpose:
  Creates shifted copies of variable `var` by looking up the value from the  
  same dataset at offset rows  based on row numbers. Negative offset = lag,  
  positive offset = lead, offset=0 points to the current row.  

Parameters:  
~~~text
  dataset=  Input dataset name (REQUIRED). Typically, specify the exact same  
            dataset as the one used in the  DATA step SET statement;  
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

<img width="206" height="262" alt="Image" src="https://github.com/user-attachments/assets/9da12ef9-0e27-4ace-9838-08b01b1e3be8" />

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
run;
~~~

<img width="327" height="117" alt="Image" src="https://github.com/user-attachments/assets/172b32fa-55a3-4ebd-af2d-1e03e4066252" />

# version history<br>
0.1.0(15Auguat2025): Initial version<br>

## What is SAS Packages?  
The package is built on top of **SAS Packages framework(SPF)** developed by Bartosz Jablonski.
For more information about SAS Packages framework, see [SAS_PACKAGES](https://github.com/yabwon/SAS_PACKAGES).  
You can also find more SAS Packages(SASPACs) in [SASPAC](https://github.com/SASPAC).

## How to use SAS Packages? (quick start)
### 1. Set-up SPF(SAS Packages Framework)
Firstly, create directory for your packages and assign a fileref to it.
~~~sas      
filename packages "\path\to\your\packages";
~~~
Secondly, enable the SAS Packages Framework.  
(If you don't have SAS Packages Framework installed, follow the instruction in [SPF documentation](https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation) to install SAS Packages Framework.)  
~~~sas      
%include packages(SPFinit.sas)
~~~  
### 2. Install SAS package  
Install SAS package you want to use using %installPackage() in SPFinit.sas.
~~~sas      
%installPackage(packagename, sourcePath=\github\path\for\packagename)
~~~
(e.g. %installPackage(ABC, sourcePath=https://github.com/XXXXX/ABC/raw/main/))  
### 3. Load SAS package  
Load SAS package you want to use using %loadPackage() in SPFinit.sas.
~~~sas      
%loadPackage(packagename)
~~~
### Enjoy
