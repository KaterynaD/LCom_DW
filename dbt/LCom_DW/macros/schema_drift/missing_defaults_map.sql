{% macro missing_defaults_map(
    table_name,
    used_columns,
    profile_src=('profiles','sfdc_schema_audit'),
    base_profile='base',
    current_profile='current'
) %}
  {# Returns a dict: { 'col_name': 'default_expr' } for ONLY missing columns that are also in used_columns #}

  {% if not execute %}
    {{ return({}) }}
  {% endif %}

  {% set profiles_relation = source(profile_src[0], profile_src[1]) %}

  {# Normalize used columns to lowercase #}
  {% set used_lower = [] %}
  {% for c in used_columns %}
    {% do used_lower.append((c | lower | trim)) %}
  {% endfor %}

  {% set in_list = [] %}
  {% for c in used_lower %}
    {% do in_list.append("'" ~ c ~ "'") %}
  {% endfor %}

  {% set q %}
    with missing as (
      select lower(table_name) as table_name, lower(column_name) as column_name
      from {{ profiles_relation }}
      where profile_name = '{{ base_profile }}'
        and lower(table_name) = lower('{{ table_name }}')

      except

      select lower(table_name) as table_name, lower(column_name) as column_name
      from {{ profiles_relation }}
      where profile_name = '{{ current_profile }}'
        and lower(table_name) = lower('{{ table_name }}')
    )
    select
      a.column_name,
      case
        when a.data_type_category = 'varchar' then '''{{ var("default_varchar") }}''::varchar'
        when a.data_type_category = 'numeric' then '{{ var("default_numeric") }}::numeric'
        when a.data_type_category = 'date'    then '''{{ var("default_date") }}''::date'
        when a.data_type = 'boolean'          then '{{ var("default_boolean") }}::boolean'
        else 'null'
      end as replace_to_default
    from {{ profiles_relation }} a
    join missing m
      on lower(a.table_name) = m.table_name
     and lower(a.column_name) = m.column_name
    where a.profile_name = '{{ base_profile }}'
      and lower(a.table_name) = lower('{{ table_name }}')
      and lower(a.column_name) in ({{ in_list | join(', ') }})
  {% endset %}

  {% set res = run_query(q) %}
  {% if res is none %}
    {{ exceptions.raise_compiler_error("missing_defaults_map: run_query returned none; check profiles source & permissions.") }}
  {% endif %}

  {% set out = {} %}
  {% for row in res.rows %}
    {% set col = row[0] %}
    {% set defexpr = row[1] %}
    {% do out.update({ col: defexpr }) %}
  {% endfor %}

  {{ return(out) }}
{% endmacro %}