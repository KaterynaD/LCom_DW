{% macro run_vacuum_and_analyze()  %} 


    


 {% set run_va_operation %}

 
vacuum {{ ref('fact_license_order') }};
vacuum {{ ref('fact_license_order_history') }};
--
vacuum {{ ref('fact_opportunity_history') }};


analyze {{ ref('fact_license_order') }};
analyze {{ ref('fact_license_order_history') }};
--
analyze {{ ref('fact_opportunity_history') }};
 


 {% endset %}

{% do run_query(run_va_operation) %}



{% endmacro %}