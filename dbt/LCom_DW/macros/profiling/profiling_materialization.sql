{% materialization profiling, default %}

{% set target_table = model.get('alias', model.get('name')) %}

 {% set config = model['config'] %}


  {% set profiles_db = model.database %}
  {% set profiles_schema = model.schema %}
  {% set profiles_table = target_table %}


{% set target_relation_exists, target_relation = get_or_create_relation(
      database=profiles_db,
      schema=profiles_schema,
      identifier=profiles_table,
          type='table') %}

 {% if not target_relation.is_table %}
    {% do exceptions.relation_wrong_type(target_relation, 'table') %}
  {% endif %}

 {% if not target_relation_exists  %}
  

   {% set build_sql = profiling_table_template() %}
 

   {% set final_sql = create_table_as(False, target_relation, build_sql) %}

  {% else %}

    {% set final_sql = "SELECT 1" %}
  {% endif %}

  {% call statement('main') %}      
      {{ final_sql }}
  {% endcall %}

  {% set profile_name = config['profile_name'] %}
  
  {% set database_name = config['database_name'] %}
  {% set schema_name = config['schema_name'] %}
  {% set table_name = config['table_name'] %}

  {% set include_columns = config['include_columns'] | default([], true) %}
  {% set exclude_columns = config['exclude_columns'] | default([], true)%}
  {% set include_stats_numeric = config['include_stats_numeric'] | default([], true) %}
  {% set exclude_stats_numeric = config['exclude_stats_numeric'] | default([], true) %}
  {% set include_stats_varchar = config['include_stats_varchar'] | default([], true) %}
  {% set exclude_stats_varchar = config['exclude_stats_varchar'] | default([], true) %}
  {% set include_stats_datetime = config['include_stats_datetime'] | default([], true) %}
  {% set exclude_stats_datetime = config['exclude_stats_datetime'] | default([], true) %}
  {% set num_outliers_columns = config['num_outliers_columns'] | default([], true) %}
  {% set num_distribution_columns = config['num_distribution_columns'] | default([], true) %}  
  {% set vc_top3_columns = config['vc_top3_columns'] | default([], true) %}  
  {% set placeholders = config['placeholders'] | default({}, true) %}
  {% set where_clause = config['where_clause'] | default(None, true) %}
  {% set row_limit = config['row_limit'] | default(None, true) %}
  {% set max_columns_per_batch = config['max_columns_per_batch'] | default(None, true) %}
  {% set loaddate = config['loaddate'] | default(None, true) %}

  {% set profile_tables = config['profile_tables'] %}
  
{{ run_hooks(pre_hooks, inside_transaction=False) }}

-- `BEGIN` happens here:
{{ run_hooks(pre_hooks, inside_transaction=True) }}

{# Profiling happens here  #}

{% if not flags.EMPTY %}

{% if table_name %}

{{ log('Profiling ' ~ schema_name ~ '.' ~ table_name, info=True) }}
     
{{ create_profile(
    profiles_db=profiles_db,
    profiles_schema = profiles_schema,
    profiles_table = profiles_table,
    profile_name = profile_name,
    database_name = database_name,
    schema_name = schema_name,
    table_name = table_name,
    include_columns = include_columns,
    exclude_columns = exclude_columns,
    include_stats_numeric = include_stats_numeric,
    exclude_stats_numeric = exclude_stats_numeric,
    include_stats_varchar = include_stats_varchar,
    exclude_stats_varchar = exclude_stats_varchar,
    include_stats_datetime = include_stats_datetime,
    exclude_stats_datetime = exclude_stats_datetime,
    num_outliers_columns = num_outliers_columns,
    num_distribution_columns = num_distribution_columns,
    vc_top3_columns = vc_top3_columns,
    placeholders = placeholders,
    where_clause = where_clause,
    row_limit = row_limit,
    max_columns_per_batch = max_columns_per_batch,
    loaddate = loaddate,
    invocated_from_materialization = 'Y')
}}

{% elif profile_tables %}

{% for profile in profile_tables %}


  {% set profile_name = profile.profile_name | default(profile_name, true) %}

  {% set database_name = profile.database_name | default(database_name, true)%}
  {% set schema_name = profile.schema_name | default(schema_name, true)%}
  {% set table_name = profile.table_name %}

  {% set include_columns = profile.include_columns | default(include_columns, true) %}
  {% set exclude_columns = profile.exclude_columns | default(exclude_columns, true) %}
  {% set include_stats_numeric = profile.include_stats_numeric | default(include_stats_numeric, true) %}
  {% set exclude_stats_numeric = profile.exclude_stats_numeric | default(exclude_stats_numeric, true) %}
  {% set include_stats_varchar = profile.include_stats_varchar | default(include_stats_varchar, true) %}
  {% set exclude_stats_varchar = profile.exclude_stats_varchar | default(exclude_stats_varchar, true) %}
  {% set include_stats_datetime = profile.include_stats_datetime | default(include_stats_datetime, true) %}
  {% set exclude_stats_datetime = profile.exclude_stats_datetime | default(exclude_stats_datetime, true) %}
  {% set num_outliers_columns = profile.num_outliers_columns | default(num_outliers_columns, true) %}
  {% set num_distribution_columns = profile.num_distribution_columns | default(num_distribution_columns, true) %}
  {% set vc_top3_columns = profile.vc_top3_columns | default(vc_top3_columns, true) %}  
  {% set placeholders = profile.placeholders | default(placeholders, true) %}
  {% set where_clause = profile.where_clause | default(where_clause, true) %}
  {% set row_limit = profile.row_limit | default(row_limit, true) %}
  {% set max_columns_per_batch = profile.max_columns_per_batch | default(max_columns_per_batch, true) %}


{{ log('Profiling ' ~ schema_name ~ '.' ~ table_name, info=True) }}

{{ create_profile(
    profiles_db=profiles_db,
    profiles_schema = profiles_schema,
    profiles_table = profiles_table,
    profile_name = profile_name,
    database_name = database_name,
    schema_name = schema_name,
    table_name = table_name,
    include_columns = include_columns,
    exclude_columns = exclude_columns,
    include_stats_numeric = include_stats_numeric,
    exclude_stats_numeric = exclude_stats_numeric,
    include_stats_varchar = include_stats_varchar,
    exclude_stats_varchar = exclude_stats_varchar,
    include_stats_datetime = include_stats_datetime,
    exclude_stats_datetime = exclude_stats_datetime,
    num_outliers_columns = num_outliers_columns,
    num_distribution_columns = num_distribution_columns,
    vc_top3_columns = vc_top3_columns,
    placeholders = placeholders,
    where_clause = where_clause,
    row_limit = row_limit,
    max_columns_per_batch = max_columns_per_batch,
    loaddate = loaddate,
    invocated_from_materialization = 'Y')
}}



{% endfor %}

{% elif model['compiled_code'] %}

{{ create_profile(
    profiles_db=profiles_db,
    profiles_schema = profiles_schema,
    profiles_table = profiles_table,
    profile_name = profile_name,
    schema_name = schema_name,
    table_name = table_name,
    include_columns = include_columns,
    exclude_columns = exclude_columns,
    include_stats_numeric = include_stats_numeric,
    exclude_stats_numeric = exclude_stats_numeric,
    include_stats_varchar = include_stats_varchar,
    exclude_stats_varchar = exclude_stats_varchar,
    include_stats_datetime = include_stats_datetime,
    exclude_stats_datetime = exclude_stats_datetime,
    num_outliers_columns = num_outliers_columns,
    num_distribution_columns = num_distribution_columns,
    vc_top3_columns = vc_top3_columns,
    placeholders = placeholders,
    where_clause = where_clause,
    row_limit = row_limit,
    max_columns_per_batch = max_columns_per_batch,
    loaddate = loaddate,
    invocated_from_materialization = 'Y',
    SQL_to_Profile = model['compiled_code'])
    
}}

{% else %}
  
  {{ exceptions.raise_compiler_error('Either table_name or profile_tables must be provided in the model config.') }}

{% endif %}

{% endif %}









{{ run_hooks(post_hooks, inside_transaction=True) }}

  {% set should_revoke = should_revoke(target_relation_exists, full_refresh_mode=False) %}
  {% do apply_grants(target_relation, grant_config, should_revoke=should_revoke) %}

  {% do persist_docs(target_relation, model) %}

  -- `COMMIT` happens here

  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}




 {{ return({'relations': [target_relation]}) }}

{% endmaterialization %}