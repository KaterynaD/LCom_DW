{#-
  Macro: missing_defaults_map

  Purpose:
      Identify columns that are expected (base profile) but currently missing
      from a source table (current profile), limited to columns actually
      used by a dbt model, and return a mapping of those columns to correctly
      typed default SQL expressions.

      This macro is intended to be consumed by SELECT-list–generating macros
      (e.g. safe_select_list_from_profiles) to transparently substitute defaults
      for missing columns without failing dbt runs.

  Execution behavior:
      - During parse / compile (execute == false):
            Returns an empty dictionary.
            No database access is attempted.
      - During runtime (execute == true):
            Queries the profiles table to detect missing columns and infer
            default expressions using base profile data types.

  Arguments:
      - table_name:
            Name of the a source table being evaluated
            (e.g. 'account', 'opportunity')

      - used_columns:
            Ordered list of column names (strings) referenced by the dbt model.
            Only these columns are considered for drift detection and replacement.
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
{% macro missing_defaults_map(
    table_name,
    used_columns,
    profile_src=('profiles','sfdc_schema_audit'),
    base_profile='base',
    current_profile='current'
) %}

  {# ---------------------------------------------------------------------------
     PARSE / COMPILE PHASE (execute == false)
     Return an empty result to avoid database access during manifest generation.
     --------------------------------------------------------------------------- #}
  {% if not execute %}
    {{ return({}) }}
  {% endif %}

 

  {# Resolve the schema audit source relation #}
  {% set profiles_relation = source(profile_src[0], profile_src[1]) %}

  {# ---------------------------------------------------------------------------
     Normalize model-used column names to lowercase for case-insensitive matching
     --------------------------------------------------------------------------- #}
  {% set used_lower = [] %}
  {% for c in used_columns %}
    {% do used_lower.append(c | lower | trim) %}
  {% endfor %}

  {# Build SQL IN (...) list for filtering to model-used columns only #}
  {% set in_list = [] %}
  {% for c in used_lower %}
    {% do in_list.append("'" ~ c ~ "'") %}
  {% endfor %}

  {# Number of used columns #}
  {% set num_used_columns = in_list | length %}

  {# Validate Current profile is present and has at least 90% used columns #}
  {#  only if it's a Prod not QA, empty run                                #}
  {% if not flags.EMPTY %}
  {% set vq %}

      select
        count(column_name)/{{ num_used_columns }}::float as rt_present
      from {{ profiles_relation }}
      where profile_name = '{{ current_profile }}'
        and lower(table_name) = lower('{{ table_name }}')
        and lower(column_name) in ({{ in_list | join(', ') }})
        and pct_nulls < 100 --100% empty column is considered missing

  {% endset %}

  {# Execute the query against the warehouse #}
  {% set res = run_query(vq) %}
  {% if res is none %}
    {{ exceptions.raise_compiler_error(
        "current_profile: run_query returned none; check profiles source & permissions."
    ) }}
  {% endif %}

  {% set row = res.rows[0] %}
  {% set rt_present = row[0] %}
  {% if rt_present <= 0.6 %}
    {{ exceptions.raise_compiler_error(
        "current_profile: current profile is completely missing or more than 60% of used columns are not present"
    ) }}
  {% endif %}

  {% endif %}
  {# ---------------------------------------------------------------------------
     SQL logic:
       1. Identify columns present in base profile but missing in current profile
       2. Restrict to columns used by the model
       3. Derive typed default replacement expressions from base profile metadata
     --------------------------------------------------------------------------- #}
  {% set q %}
    with missing as (
      select
        lower(table_name)  as table_name,
        lower(column_name) as column_name
      from {{ profiles_relation }}
      where profile_name = '{{ base_profile }}'
        and lower(table_name) = lower('{{ table_name }}')

      except

      select
        lower(table_name)  as table_name,
        lower(column_name) as column_name
      from {{ profiles_relation }}
      where profile_name = '{{ current_profile }}'
        and lower(table_name) = lower('{{ table_name }}')
        and pct_nulls < 100 --100% empty column is considered missing
    )
    select
      a.column_name,
      case
        when a.data_type_category = 'varchar'
          then '''{{ var("default_varchar") }}''::varchar'
        when a.data_type_category = 'numeric'
          then '{{ var("default_numeric") }}::numeric'
        when a.data_type_category = 'date'
          then '''{{ var("default_date") }}''::date'
        when a.data_type = 'boolean'
          then '{{ var("default_boolean") }}::boolean'
        else 'null'
      end as replace_to_default
    from {{ profiles_relation }} a
    join missing m
      on lower(a.table_name)  = m.table_name
     and lower(a.column_name) = m.column_name
    where a.profile_name = '{{ base_profile }}'
      and lower(a.table_name) = lower('{{ table_name }}')
      and lower(a.column_name) in ({{ in_list | join(', ') }})
  {% endset %}

  {# Execute the query against the warehouse #}
  {% set res = run_query(q) %}
  {% if res is none %}
    {{ exceptions.raise_compiler_error(
        "missing_defaults_map: run_query returned none; check profiles source & permissions."
    ) }}
  {% endif %}

  {# ---------------------------------------------------------------------------
     Build output dictionary:
       { column_name -> default_sql_expression }
     --------------------------------------------------------------------------- #}
  {% set out = {} %}
  {% for row in res.rows %}
    {% set col = row[0] %}
    {% set defexpr = row[1] %}
    {% do out.update({ col: defexpr }) %}
  {% endfor %}

  {{ return(out) }}

{% endmacro %}
