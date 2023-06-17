/*
 Copyright (C) 2023 SAS Institute Inc. Cary, NC, USA
*/

/**
   \file
   \anchor  pcpr_filter_partition
   \brief   This macro is used to create modeling, backtesting, and/or business backtesting based on user specified filter conditions through generic table.
            Before calling this macro, create a configuraiton table by calling a function ${function:GetSASDSCode(Params.spreadsheet.rowState, "&generic_lib..&generic_table_name.")}                  
   \param [in] CONFIG_TABLE_LIB         Configuration table library
   \param [in] CONFIG_TABLE_NM          Configuration table name
   \param [in] REQUIRED_COL_LIST        List of columns required by this macro in the configuration table, space separated
   \param [in] PARTITION_TABLE_LIB      CAS library for the input and output partition tables
       
   
   \details create modeling, backtesting, and bsuiness backtsting tables by filtering input tables.
   \Note   This macro is called by filter partition script

   \ingroup Macros
   \author  SAS Institute Inc.
   \date    2023
*/

%macro pcpr_filter_partition(CONFIG_TABLE_LIB=, CONFIG_TABLE_NM=, REQUIRED_COL_LIST=, PARTITION_TABLE_LIB=);

    /*Make sure config table exist*/
    %if not %rsk_dsexist(&CONFIG_TABLE_LIB..&CONFIG_TABLE_NM.) %then %do;
        %PUT ERROR: Configuration table &CONFIG_TABLE_LIB..&CONFIG_TABLE_NM. does not exist.;
        %abort;
    %end;

    %if &REQUIRED_COL_LIST eq %then %do;
       %PUT ERROR: A list of required columns needs to be specified.;
       %abort;
    %end;
    
    %global SUCCESS_FLG MISSING_VAR  ;

    %rsk_verify_ds_col(REQUIRED_COL_LIST=&REQUIRED_COL_LIST., IN_DS_LIB =&CONFIG_TABLE_LIB., IN_DS_NM =&CONFIG_TABLE_NM., OUT_SUCCESS_FLG =SUCCESS_FLG, OUT_MISSING_VAR =MISSING_VAR);

    %if &SUCCESS_FLG.=N %then %do;
        %PUT ERROR: The following variable "&MISSING_VAR." is not present in &CONFIG_TABLE_LIB..&CONFIG_TABLE_NM..;
        %abort;
    %end;

   %if %rsk_attrn(&CONFIG_TABLE_LIB..&CONFIG_TABLE_NM., nobs) %then %do;
        /*Check missing values in the table*/
        %let n_col=%rsk_wordcount(&REQUIRED_COL_LIST.);
        %let check_list=;
        %do i=1 %to &n_col;
              %let check_col=%scan(&REQUIRED_COL_LIST.,&i);
              %if &i=&n_col %then %do;
                 %let check_list=&check_list missing(&check_col);
              %end;
              %else %do;
                 %let check_list=&check_list missing(&check_col) or;
              %end;
        %end;
        %put &check_list.;
        data &CONFIG_TABLE_LIB..&CONFIG_TABLE_NM._MISSING;
             set &CONFIG_TABLE_LIB..&CONFIG_TABLE_NM.;
             if &check_list.;
        run;
        %if %rsk_attrn(&CONFIG_TABLE_LIB..&CONFIG_TABLE_NM._MISSING, nobs) %then %do;
             %PUT ERROR: There are missing values in &CONFIG_TABLE_LIB..&config_table_nm..;
             %abort;
        %end;
        
         /*Add additional information column*/
        data &CONFIG_TABLE_LIB..&CONFIG_TABLE_NM.;
            set &CONFIG_TABLE_LIB..&CONFIG_TABLE_NM.;
            format filter_expression $256. cas_lib $32.;
            filter_expression=cat(strip(ColumnName),' ', strip(Operator),' ', strip(ColumnValue));
            cas_lib="&PARTITION_TABLE_LIB.";
        run;

        /*create file to run code from the configuration table*/
        filename filter filesrvc folderPath='/Products/SAS Dynamic Actuarial Modeling' filename= "filter_code.sas" debug=http lrecl = 33000;

        data _NULL_;
            length STATEMENT $2000. ;
                set &CONFIG_TABLE_LIB..&CONFIG_TABLE_NM.;
                file filter;
                STATEMENT =  cat('%pcpr_filter_cas_table(INCASTABLE=',strip(InputTableName), 
                                                    ',INCASLIB=',strip(cas_lib),
                                                    ',OUTCASTABLE=',strip(OutputTableName),
                                                    ',OUTCASLIB=',strip(cas_lib),
                                                    ', FILTER_EXPRESSION=%bquote(',%bquote(trim(filter_expression)),
                                                    '));'
                                );

                put STATEMENT ;
        run;

        /*run code if code file is created sucessfully*/
        %if %sysfunc(fexist(filter)) %then %do ;
            %inc filter ;
        %end ;
    %end;
    %else %do;
        %PUT NOTE: There are no observations in the configuration table &CONFIG_TABLE_LIB..&config_table_nm..;
    %end;
%mend pcpr_filter_partition;
