/*
Copyright (C) 2023 SAS Institute Inc. Cary, NC, USA
*/

/**
\file
\anchor  pcpr_drop_columns
\brief  Removing columns inserted into a list

\param [in] cas_session_name       Cas session name
\param [in] INCASLIB               Input Cas library name
\param [in] INCASTABLE             Input Cas table name
\param [in] OUTCASLIB              Output Cas library name
\param [in] OUTCASTABLE            Output Cas table name
\param [in] DROP_LIST              List of columns to remove

\details the list should be composed as follows: string containing the variables to be removed separated by a space
\ingroup Macros
\author  SAS Institute Inc.
\date    2023
*/

%macro pcpr_drop_columns(INCASLIB=,INCASTABLE=,OUTCASLIB=,OUTCASTABLE=,DROP_LIST=,CAS_SESSION_NAME=&casSessionName.);

%local SUCCESS_FLG MISSING_VAR  ;

%rsk_verify_ds_col(REQUIRED_COL_LIST=&DROP_LIST., IN_DS_LIB =&INCASLIB., IN_DS_NM =&INCASTABLE., OUT_SUCCESS_FLG =SUCCESS_FLG, OUT_MISSING_VAR =MISSING_VAR);

%if &SUCCESS_FLG.=N %then %do;
%PUT ERROR, VARIABLE &MISSING_VAR. is not present in &INCASLIB..&INCASTABLE. !!!!;
%abort;
%end;

proc cas; 
datastep.runCode /
code =  "data  &OUTCASLIB..&OUTCASTABLE. (drop = &DROP_LIST. );
set &INCASLIB..&INCASTABLE.; 
run; " ;
run;

quit;

%mend pcpr_drop_columns;