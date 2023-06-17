/*
 Copyright (C) 2022 SAS Institute Inc. Cary, NC, USA
*/

/**
   \file
   \brief   Load sample data in csv file to a target library 

   \param [in] tgt_lib      Intermediate libref where the sample data will be loaded
   \param [in] dir          Path to the sample data files
   \param [in] csv_table_list   The list of tables in the sample data directory   
   \param [in] caslib       caslib name that table will be loaded to   
   
   \details This macro loops through all .csv files found in the input directory {dir} or from a csv table list and upload them.

   \ingroup development
   \author  SAS Institute Inc.
   \date    2022
*/
%macro pcpr_load_csv_sample_data(tgt_lib =
                            , dir = 
                            , csv_table_list=
                            , caslib=
                            );
   
               /*Directory can't be empty*/                   
               %if %length(&dir.)=0 %then %do;
                  %return;
               %end;                            
               %if %length(&caslib) ^=0 %then %do;
                   %let caslib_nm=&caslib;
               %end;
               %else %do;
                   %let caslib_nm=public;   
               %end;                           

               options validvarname=any;
               %if %length(&csv_table_list.)^=0 %then %do;
                  %local csv_table_cnt l m;
                  %let l=1;
                  %let m=1;
                  %let csv_table_cnt=%rsk_wordcount(&csv_table_list.);
                  %do l = 1 %to &csv_table_cnt.;
                      %let csv_curr_table=%scan(&csv_table_list.,&l);
                      %let input=;
                      %let length=;
                      %if %upcase(&csv_curr_table)=PC_PRICING_ABT_RAW %then %do;
                          %let length="Policy number"n varchar(36) LINE_OF_BUSINESS_ID varchar(36) COVERAGE_CD varchar(20) POLICY_UW_YEAR_NO 8. "Start date"n 8. "End date"n 8. CANCELLATION_DT 8. NEW_POLICY_FLG varchar(1) Exposure 8. Frequency 8. Severity 8. CUST_AREA_CD varchar(10) CUST_REGION_CD varchar(10) CUST_POP_DENSITY_AMT 8. CUST_AGE_AMT 8. CUST_BONUS_MALUS_LEVEL_AMT 8. VEH_FUEL_TYPE_CD varchar(10) VEH_MAKE_MODEL_CD varchar(20) VEH_AGE_AMT 8. VEH_POWER_LEVEL_AMT 8.;         
                          %let input="Policy number"n :$36. LINE_OF_BUSINESS_ID :$36. COVERAGE_CD :$20. POLICY_UW_YEAR_NO "Start date"n :anydtdte12. "End date"n :anydtdte12. CANCELLATION_DT :anydtdte12. NEW_POLICY_FLG :$1. Exposure Frequency Severity CUST_AREA_CD :$10. CUST_REGION_CD :$10. CUST_POP_DENSITY_AMT CUST_AGE_AMT CUST_BONUS_MALUS_LEVEL_AMT VEH_FUEL_TYPE_CD :$10. VEH_MAKE_MODEL_CD :$20. VEH_AGE_AMT VEH_POWER_LEVEL_AMT;
                      %end;
                      %else %if %upcase(&csv_curr_table)=PC_PRICING_ABT_HOME_RAW %then %do;
                          %let length="Policy number"n varchar(36) LINE_OF_BUSINESS_ID varchar(36) COVERAGE_CD varchar(20) POLICY_UW_YEAR_NO 8. "Start date"n 8. "End date"n 8. CANCELLATION_DT 8. NEW_POLICY_FLG varchar(1) Exposure 8. Frequency 8. Severity 8. PERSONAL_PROPERTY_CAPITAL_AMT 8. DWELLING_CAPITAL_AMT 8. LIABILITY_CAPITAL_AMT 8.   ASSISTANCE_PREMIUM_AMT 8.  PERSONAL_PROPERTY_PREMIUM_AMT 8. DWELLING_PREMIUM_AMT 8. LIABILITY_PREMIUM_AMT 8.   CUST_BIRTH_DT 8.  PAYMENT_METHOD_CD varchar(36) PREMIUM_AMT 8. PREMIUM_FRACTIONARY_FLG varchar(1)  PREVIOUS_PREMIUM_AMT 8. POPULATION_TYPE_CD varchar(20)   RISK_BUILDING_SQM_AMT 8.   RISK_DWELLING_TYPE_CD varchar(20)   RISK_INHABITANTS_NO 8.  RISK_NOT_FLAMMABLE_FLG varchar(1)   RISK_PET_FLG varchar(1) RISK_PROPERTY_FLG varchar(1)  RISK_USAGE_CD varchar(20)  RISK_REGION_CD varchar(10) ;         
                          %let input="Policy number"n :$36. LINE_OF_BUSINESS_ID :$36. COVERAGE_CD :$20. POLICY_UW_YEAR_NO "Start date"n :anydtdte12. "End date"n :anydtdte12. CANCELLATION_DT :anydtdte12. NEW_POLICY_FLG :$1. Exposure Frequency Severity PERSONAL_PROPERTY_CAPITAL_AMT  DWELLING_CAPITAL_AMT LIABILITY_CAPITAL_AMT   ASSISTANCE_PREMIUM_AMT  PERSONAL_PROPERTY_PREMIUM_AMT DWELLING_PREMIUM_AMT LIABILITY_PREMIUM_AMT   CUST_BIRTH_DT :anydtdte12. PAYMENT_METHOD_CD :$36. PREMIUM_AMT PREMIUM_FRACTIONARY_FLG :$1.  PREVIOUS_PREMIUM_AMT POPULATION_TYPE_CD :$20.   RISK_BUILDING_SQM_AMT   RISK_DWELLING_TYPE_CD :$20.   RISK_INHABITANTS_NO  RISK_NOT_FLAMMABLE_FLG :$1.   RISK_PET_FLG :$1. RISK_PROPERTY_FLG :$1.  RISK_USAGE_CD :$20.  RISK_REGION_CD :$10.;
                      %end;
                      %else %if %upcase(&csv_curr_table)=PC_PRICING_DETL_CLAIM_RAW %then %do;
                          %let length=CLAIM_ID varchar(36) "Policy number"n varchar(36) COVERAGE_CD varchar(20) Severity 8.;
                          %let input=CLAIM_ID :$36. "Policy number"n :$36. COVERAGE_CD :$20. Severity;
                      %end;
                      %else %if %upcase(&csv_curr_table)=PC_PRICING_DETL_CUSTOMER_RAW %then %do;
                          %let length=CUST_ID varchar(36) "Policy Num"n varchar(36) "Birth Date"n 8. CUST_DRIVING_LICENSE_DT 8. CUST_GENDER_CD varchar(1) CUST_STATE_CD varchar(20) CUST_MARRIAGE_STATUS_CD varchar(40) CUST_JOB_TYPE_TXT varchar(100) CUST_ED_LEVEL_TYPE_TXT varchar(100);
                          %let input=CUST_ID :$36. "Policy Num"n :$36. "Birth Date"n :anydtdte12. CUST_DRIVING_LICENSE_DT :anydtdte12. CUST_GENDER_CD :$1. CUST_STATE_CD :$20. CUST_MARRIAGE_STATUS_CD :$40. CUST_JOB_TYPE_TXT :$100. CUST_ED_LEVEL_TYPE_TXT :$100.;
                      %end;
                      %else %if %upcase(&csv_curr_table)=PC_PRICING_DETL_POLICY_RAW %then %do;
                          %let length="Num of Policy"n varchar(36) LINE_OF_BUSINESS_ID varchar(36) POLICY_UW_YEAR_NO 8. "Start date"n 8. "End date"n 8. CANCELLATION_DT 8. NEW_POLICY_FLG varchar(1) Exposure 8. VEH_AGE_AMT 8. VEH_MAKE_MODEL_CD varchar(20) VEH_OWNER_TYPE_CD varchar(20) VEH_CUBIC_CAPACITY_AMT 8. VEH_SI_GROSS_AMT 8. VEH_SI_WS_AMT 8. VEH_SALE_CHANNELS_TYPE_TXT varchar(100) CUST_BONUS_MALUS_LEVEL_AMT 8.;
                          %let input="Num of Policy"n :$36. LINE_OF_BUSINESS_ID :$36. POLICY_UW_YEAR_NO "Start date"n :anydtdte12. "End date"n :anydtdte12. CANCELLATION_DT :anydtdte12. NEW_POLICY_FLG :$1. Exposure VEH_AGE_AMT VEH_MAKE_MODEL_CD :$20. VEH_OWNER_TYPE_CD :$20. VEH_CUBIC_CAPACITY_AMT VEH_SI_GROSS_AMT VEH_SI_WS_AMT VEH_SALE_CHANNELS_TYPE_TXT :$100. CUST_BONUS_MALUS_LEVEL_AMT;
                      %end;
                      filename cdata_&l. filesrvc folderpath="&sample_data_path/" filename= "&csv_curr_table..csv" debug=http;
                      data &tgt_lib.._&csv_curr_table.;
                          length &length.;
                          infile cdata_&l. dsd truncover firstobs=2;                          
                          input &input. ;
                      run;
                  %pcpr_promote_table_to_cas(cas_session_name=load_sampledata, input_caslib_nm =&tgt_lib.,input_table_nm =_&csv_curr_table.,output_caslib_nm =&caslib_nm.,output_table_nm =&csv_curr_table. ,drop_sess_scope_tbl_flg=N);        
                  %pcpr_save_table_to_cas(in_caslib_nm=&caslib_nm., in_table_nm=&csv_curr_table.,out_caslib_nm=&caslib_nm., out_table_nm=&csv_curr_table., replace_flg=true)         
                  %end;
               %end;

%mend pcpr_load_csv_sample_data;
