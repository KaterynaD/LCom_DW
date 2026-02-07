{% macro reset_profiles_current_to_base() %}

  {% if not execute %}
    {{ return("") }}
  {% endif %}

  {% set tables = get_sfdc_schema_drift_tables() %}

  {% for t in tables %}

    {# sfdc_<table_name>_profile is a dbt model with profile #}
    {% set model_name = "sfdc_" ~ t.table_name | lower ~ "_profile" %}

    {% do log("Updating model: " ~ model_name, info=true) %}

    {% set sql %}
      update {{ ref(model_name) }}
      set profile_name = 'base'
      where profile_name = 'current'
    {% endset %}

    {% do run_query(sql) %}

  {% endfor %}

  {{ return("") }}

{% endmacro %}