{% macro run_populating_dim_calendar()  %} 


    


 {% set run_sp_operation %}

 
 call {{target.database}}.common.populating_dim_calendar(cast('1990-08-01' as date), cast('2035-07-31' as date));
 


 {% endset %}

{% do run_query(run_sp_operation) %}



{% endmacro %}