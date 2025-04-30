{% macro dbt_run_log_update(operation) %} 


{%- if target.name == 'Prod' %}    


 {% set update_endtime_operation %}

 {% set run_at_date = get_run_at_date() %}


{% if operation|length > 1  %} 
  
  {% set run_operation =  operation  %}

{% else %} 
 
  {% set run_operation =   this   %}

{% endif %}


 
 UPDATE {{ source("audit","dbt_run_log") }}
 SET end_time='{{ run_at_date }}'
 WHERE OPERATION='{{ run_operation }}'
 and run_id='{{ invocation_id }}'
 ;


 {% endset %}

{% do run_query(update_endtime_operation) %}

 {%- endif %}

{% endmacro %}