{% macro validate_views(models) %}

    {% for model_name in models %}

    {{ log("Validating model: " ~ model_name, info=True) }}

        {% set sql %}
            select *
            from {{ ref(model_name) }}
            limit 1
        {% endset %}    

        {% do run_query(sql) %}

    {{ log(model_name ~ " validated successfully", info=True) }}

    {% endfor %}

{% endmacro %}