{#-
  Macro: safe_select_list_from_profiles

  Purpose:
      Generate a stable, schema-drift-resilient SELECT list for a source table.
      The macro compares the list of columns used in a dbt model against
      base and current source table profiles and:
        - emits the real column when it exists in the current profile
        - substitutes a correctly typed default expression when the column is missing
      Column order always follows `used_columns`.

  Execution behavior:
      - During parse / compile (execute == false):
            Emits `alias.column AS column` placeholders only.
            No database access is attempted.
      - During runtime (execute == true):
            Detects missing columns via profiles and replaces them with defaults.

  Arguments:
      - table_name:
            Name of the source table being queried
            (e.g. 'account', 'opportunity')

      - alias:
            SQL alias used for the source relation in the model
            (e.g. 'sfdc_account' or 'stg_opportunity')

      - used_columns:
            Ordered list of column names (strings) explicitly used by the dbt model.
            Only these columns are checked for drift and rendered in the SELECT list.
            (e.g. ['id', 'name', 'created_date', 'custom_field_c'])

      - profile_src:
            schema and table name that stores  profiles
            Default: source('profiles', 'sfdc_schema_audit')

      - base_profile:
            Name of the profile representing the expected / designed source table column set.
            Used to retrieve data types and defaults for missing columns.
            Default: 'base'

      - current_profile:
            Name of the profile representing the current source table column set.
            Used to detect which columns are missing today.
            Default: 'current'
-#}

{% macro safe_select_list_from_profiles(
    table_name,
    alias,
    used_columns,
    profile_src=('profiles','sfdc_schema_audit'),
    base_profile='base',
    current_profile='current'
) %}
  


  {# during parsing, just emit alias.col placeholders #}
  {% if not execute %}
   {% set parts = [] %}
   {% for c in used_columns %}
     {% set col = c | lower | trim %}
     {% do parts.append(alias ~ '.' ~ col ~ ' as ' ~ col) %}
   {% endfor %}
   {{ return(parts | join(',\n    ')) }}
  {% endif %}


  {# at runtime, check for missing columns and emit defaults where needed #}
  {# missing_map is a dictionary mapping column names to default expressions #}

  {% set missing_map = missing_defaults_map(
      table_name=table_name,
      used_columns=used_columns,
      profile_src=profile_src,
      base_profile=base_profile,
      current_profile=current_profile
  ) %}

  {# build the select list #}
  {# default value if missing and a column name with alias if present in a profile source#}
  {% set parts = [] %}
  {% for c in used_columns %}
    {% set col = c | lower | trim %}
    {% if missing_map.get(col) is not none %}
      {% do parts.append(missing_map.get(col) ~ ' as ' ~ col) %}
    {% else %}
      {% do parts.append(alias ~ '.' ~ col ~ ' as ' ~ col) %}
    {% endif %}
  {% endfor %}

  {{ return(parts | join(',\n    ')) }}
{% endmacro %}
