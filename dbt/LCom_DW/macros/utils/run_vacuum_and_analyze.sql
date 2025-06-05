{% macro run_vacuum_and_analyze()  %} 


    


 {% set run_va_operation %}

vacuum {{ ref('dim_account_history') }};
--
vacuum {{ ref('fact_license_order') }};
vacuum {{ ref('fact_license_order_history') }};
--
vacuum {{ ref('fact_opportunity_history') }};
--
vacuum {{ ref('dim_license_order_school') }};
vacuum {{ ref('dim_lcom_sku') }};
vacuum {{ ref('dim_sfdc_product') }};
--

analyze {{ ref('dim_account_history') }};
--
analyze {{ ref('fact_license_order') }};
analyze {{ ref('fact_license_order_history') }};
--
analyze {{ ref('fact_opportunity_history') }};
 
--
analyze {{ ref('dim_license_order_school') }};
analyze {{ ref('dim_lcom_sku') }};
analyze {{ ref('dim_sfdc_product') }};

 {% endset %}

{% do run_query(run_va_operation) %}



{% endmacro %}