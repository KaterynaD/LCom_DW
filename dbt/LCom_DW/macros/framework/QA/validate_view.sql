{% macro validate_view() %}

 {% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %} 

    {% set model_name = model.get('alias', model.get('name'))  %}
    {% set model_schema = model.config.schema | default(target.schema, true) %}
    {% set model_database = model.config.database | default(target.database, true) %}

    {{ log("Validating model: " ~ model_name, info=True) }}

        {% set sql %}
            -- Set a statement timeout to prevent long-running validation late binding views queries
            -- There is an intermitten Redshift issue when a view works in dev and QA but validation stuck in DW (Prod)
            
            set statement_timeout = 600000;

            select *
            from {{ model_database }}.{{ model_schema }}.{{ model_name }}
            limit 1
        {% endset %}    

        {% do run_query(sql) %}

    {{ log(model_name ~ " validated successfully", info=True) }}


{% endif %}

{% endmacro %}