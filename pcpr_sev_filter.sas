/*
Copyright (C) 2023 SAS Institute Inc. Cary, NC, USA
*/

/**
\file
\anchor  pcpr_sev_filter
\brief   Creation of severity dataset

\param [in] cas_session_name      Cas session name
\param [in] INCASLIB              Input Cas library name
\param [in] INCASTABLE            Input Cas table name
\param [in] OUTCASLIB             Output Cas library name
\param [in] OUTCASTABLE           Output Cas table name
\param [in] AVG_CLAIMS_AMT_CAP    Maximum value that the variable AVG_CLAIMS_AMT can assume

\details Only the observations whose claim amount is positive are retained. Average claim amount is calculated and a cap is inserted to limit its maximum value.
\ingroup Macros
\author  SAS Institute Inc.
\date    2023
*/

%macro pcpr_sev_filter(INCASLIB=,INCASTABLE=,OUTCASLIB=,OUTCASTABLE=, AVG_CLAIMS_AMT_CAP= ,CAS_SESSION_NAME=&casSessionName.);

proc cas; 
datastep.runcode /
code =  "data  &OUTCASLIB..&OUTCASTABLE.  (drop = AVG_CLAIMS_AMT_CALC );
set &INCASLIB..&INCASTABLE.(WHERE = (CLAIMS_CNT>0));
AVG_CLAIMS_AMT_CALC= CLAIMS_AMT/CLAIMS_CNT;
AVERAGE_CLAIMS_AMT=min(&AVG_CLAIMS_AMT_CAP.,AVG_CLAIMS_AMT_CALC);
IF CLAIMS_AMT >0 THEN OUTPUT; 
run;";
run;

%mend pcpr_sev_filter;

