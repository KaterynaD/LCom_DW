{% macro get_sfdc_schema_drift_tables() %}
  {# Returns a list of dicts: [{database_name, schema_name, table_name}, ...] #}

  {% if not execute %}
    {{ return([]) }}
  {% endif %}

  {% set drift_sql %}
    select distinct
      database_name,
      schema_name,
      table_name
    from {{ ref('vw_sfdc_schema_audit') }}
    where table_name is not null
      and schema_name is not null
  {% endset %}

  {% set res = run_query(drift_sql) %}

  {% if res is none %}
    {{ return([]) }}
  {% endif %}

  {% set out = [] %}
  {% for row in res.rows %}
    {# row is a tuple in the same order as select list #}
    {% do out.append({
      "database_name": row[0],
      "schema_name": row[1],
      "table_name": row[2]
    }) %}
  {% endfor %}

  {{ return(out) }}
{% endmacro %}