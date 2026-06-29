{% macro run_DDL(object_name, sql) %}

    {% if execute
        and flags.WHICH in ('run', 'run-operation', 'build')
        and var('deploy_flag', False) %}

        {{ log("Deploying " ~ object_name, info=True) }}
        {% do run_query(sql) %}

    {% endif %}

{% endmacro %}