{% macro dbt_run_log_insert(operation, comments) %} 

{%- if target.name == 'Prod' %}
    


 {% set insert_starttime_operation %}

 {% set run_at_date = get_datetime_now() %}

{% if operation|length > 1  %} 
  
  {% set run_operation =  operation  %}

{% else %} 
 
  {% set run_operation =   this   %}

{% endif %}
 
 INSERT INTO {{ source("audit","dbt_run_log") }} (run_id, start_time, operation, comments) VALUES ('{{ invocation_id }}','{{ run_at_date }}', '{{ run_operation }}','{{ comments }}');


 {% endset %}

{% do run_query(insert_starttime_operation) %}

 {%- endif %}

{% endmacro %}