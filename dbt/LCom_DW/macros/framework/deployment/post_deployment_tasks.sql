{% macro post_deployment_tasks() %}

{% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %}


 {{ log('Starting post deployment tasks', info=True) }}

 {% set post_deployment_sql %}


 {% endset %}


    {% if post_deployment_sql | trim %}
        {% do run_query(post_deployment_sql) %}
        {{ log('Finished post deployment tasks', info=True) }}
    {% else %}
        {{ log('No post deployment tasks to execute', info=True) }}
    {% endif %}


{% endif %}
 
 {% endmacro %}