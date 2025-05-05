{% macro dbt_tmp() %} 





 {% set run_at_date = get_run_at_date() %}

{{ print("Run at date: " ~ run_at_date) }}

{% endmacro %}