{% macro pre_deployment_tasks() %}

{% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %}


 {{ log('Starting pre deployment tasks', info=True) }}

 {% set pre_deployment_sql %}

 {% set target_db = (target.database | string) %}
					


 {% endset %}

    {% if pre_deployment_sql | trim %}
        {% do run_query(pre_deployment_sql) %}
        {{ log('Finished pre deployment tasks', info=True) }}
    {% else %}
        {{ log('No pre deployment tasks to execute', info=True) }}
    {% endif %}


{% endif %}
 
 {% endmacro %}