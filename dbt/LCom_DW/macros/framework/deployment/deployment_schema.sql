{% macro deployment_schema() %}

    {% if execute
        and flags.WHICH in ('run', 'run-operation', 'build')
        and var('deploy_flag', False) %}

    {% if flags.WHICH in ('run', 'build') %}
        {% set custom_schema = model.config.schema | default(target.schema, true) %}        
    {% else %}
        {% set custom_schema = target.schema %}  
    {% endif %}

    {{ log("Schema: " ~ custom_schema, info=True) }}

    {% else %}

        {% set custom_schema = 'Not_Deployment_Mode' %}

    {% endif %}

    {{ return(custom_schema) }}
    
{% endmacro %}