{% macro run_vacuum_and_analyze_main_set()  %} 


    


 {% set run_va_operation_main_set %}

vacuum {{ ref('dim_account') }};
vacuum {{ ref('dim_account_history') }};
vacuum {{ ref('dim_employee') }};
vacuum {{ ref('dim_lcom_sku') }};
vacuum {{ ref('dim_lcom_sku_learning_object') }};
vacuum {{ ref('dim_lcom_suite') }};
vacuum {{ ref('dim_lcom_suite_sku') }};
vacuum {{ ref('dim_license_order_school') }};
vacuum {{ ref('dim_opportunity_line') }};
vacuum {{ ref('dim_sequence') }};
vacuum {{ ref('dim_sequence_learning_object') }};
vacuum {{ ref('dim_sfdc_product') }};
vacuum {{ ref('fact_case') }};
vacuum {{ ref('fact_case_history') }};
vacuum {{ ref('fact_customers_monthly_snapshots') }};
vacuum {{ ref('fact_launches_monthly_snapshots') }};
vacuum {{ ref('fact_launches_weekly_snapshots') }};
vacuum {{ ref('fact_license_order') }};
vacuum {{ ref('fact_license_order_history') }};
vacuum {{ ref('fact_opportunity') }};
vacuum {{ ref('fact_opportunity_history') }};
vacuum {{ ref('lcom_sfdc_account_mapping') }};
vacuum {{ ref('monthly_snapshot_data_district_level') }};

vacuum {{ ref('stg_customers_churn_monthly_snapshots') }};
vacuum {{ ref('stg_customers_contract_monthly_snapshots') }};
vacuum {{ ref('stg_customers_new_monthly_snapshots') }};
vacuum {{ ref('stg_customers_nonrenewal_monthly_snapshots') }};

--

analyze {{ ref('dim_account') }};
analyze {{ ref('dim_account_history') }};
analyze {{ ref('dim_employee') }};
analyze {{ ref('dim_lcom_sku') }};
analyze {{ ref('dim_lcom_sku_learning_object') }};
analyze {{ ref('dim_lcom_suite') }};
analyze {{ ref('dim_lcom_suite_sku') }};
analyze {{ ref('dim_license_order_school') }};
analyze {{ ref('dim_opportunity_line') }};
analyze {{ ref('dim_sequence') }};
analyze {{ ref('dim_sequence_learning_object') }};
analyze {{ ref('dim_sfdc_product') }};
analyze {{ ref('fact_case') }};
analyze {{ ref('fact_case_history') }};
analyze {{ ref('fact_customers_monthly_snapshots') }};
analyze {{ ref('fact_launches_monthly_snapshots') }};
analyze {{ ref('fact_launches_weekly_snapshots') }};
analyze {{ ref('fact_license_order') }};
analyze {{ ref('fact_license_order_history') }};
analyze {{ ref('fact_opportunity') }};
analyze {{ ref('fact_opportunity_history') }};
analyze {{ ref('lcom_sfdc_account_mapping') }};
analyze {{ ref('monthly_snapshot_data_district_level') }};


analyze {{ ref('stg_customers_churn_monthly_snapshots') }};
analyze {{ ref('stg_customers_contract_monthly_snapshots') }};
analyze {{ ref('stg_customers_new_monthly_snapshots') }};
analyze {{ ref('stg_customers_nonrenewal_monthly_snapshots') }};

 {% endset %}

{% do run_query(run_va_operation_main_set) %}



{% endmacro %}


{% macro run_vacuum_and_analyze_product_usage()  %} 


    


 {% set run_va_operation_product_usage %}

 vacuum {{ ref('dim_product_category') }};
 vacuum {{ ref('dim_product_category_learning_object_monthly') }};
 vacuum {{ ref('fact_students_usage_monthly_snapshots') }};

--


analyze {{ ref('dim_product_category') }};
analyze {{ ref('dim_product_category_learning_object_monthly') }};
analyze {{ ref('fact_students_usage_monthly_snapshots') }};

 {% endset %}

{% do run_query(run_va_operation_product_usage) %}



{% endmacro %}