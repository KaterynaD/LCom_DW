{% macro delete_base_profile() %}

  {% if not execute %}
    {{ return("") }}
  {% endif %}

  {% set tables = get_sfdc_schema_drift_tables() %}

  {% for t in tables %}

    {# sfdc_<table_name>_profile is a dbt model with profile #}
    {% set model_name = "sfdc_" ~ t.table_name | lower ~ "_profile" %}

    {% do log("Deleting from table: " ~ model_name, info=true) %}

    {% set sql %}
      delete from  {{ ref(model_name) }}
      where profile_name = 'base'
    {% endset %}

    {% do run_query(sql) %}

  {% endfor %}

  {{ return("") }}

{% endmacro %}