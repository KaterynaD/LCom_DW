{#-
  Macro: create_profile
  Purpose: Orchestrates profiling of a given table (columns, outliers, top3, entropy) and writes results
           into a configured profiles table. Uses helper macros for temp table creation, batching,
           core stats, outliers, and top-3 distributions.
  Arguments:
      - schema_name: Schema of the table to profile.
      - table_name: Table to profile.
      - profile_name: Optional name for the profile; defaults to db_schema_table[_where_...][_limit_...].
      - profiles_db: Database where the profiles table is located; defaults to target database.
      - profiles_schema: Schema where the profiles table is located; defaults to target schema.
      - profiles_table: Name of the profiles table; defaults to 'profiles'.
      - include_columns: Optional list of columns to include; if empty, all columns are included.
      - exclude_columns: Optional list of columns to exclude from profiling.
      - include_stats_numeric: Optional list of numeric stats to compute; if empty all are computed: 'placeholder','min','max','avg','stddev_pop','cnt_neg','cnt_zero','cnt_pos','cnt_int'
      - exclude_stats_numeric: Optional list of numeric stats to skip.
      - include_stats_varchar: Optional list of varchar stats to compute; if empty all are computed: 'placeholder','min_length','max_length','avg_length','cnt_leading_ws','cnt_trailing_ws','cnt_empty_after_trim','cnt_lower','cnt_upper','cnt_mixed','cnt_cast_int','cnt_cast_decimal','cnt_cast_date','cnt_cast_timestamp'
      - exclude_stats_varchar: Optional list of varchar stats to skip.
      - include_stats_datetime: Optional list of datetime stats to compute; if empty all are computed: 'placeholder','min','max'
      - exclude_stats_datetime: Optional list of datetime stats to skip.
      - num_outliers_columns: Optional list of numeric columns for outlier detection.
      - vc_top3_columns: Optional list of varchar columns for top-3 value and entropy analysis.
      - placeholders: Optional Dict with placeholder values per data type (numeric, text, date); if empty: numeric=0, text='Unknown', date='1900-01-01'
      - where_clause: Optional SQL WHERE clause to filter rows for profiling.
      - row_limit: Optional limit on number of rows to profile.
      - max_columns_per_batch: Max columns to process per batch; defaults to 20.
      - loaddate: Optional timestamp for when profiling was performed; defaults to current timestamp.
-#}
{% macro create_profile(
    schema_name,
    table_name,
    database_name=None,
    profile_name=None,
    profiles_db=None,
    profiles_schema=None,
    profiles_table=None,
    include_columns=[],
    exclude_columns=[],
    include_stats_numeric=['placeholder','min','max','avg','stddev_pop','cnt_neg','cnt_zero','cnt_pos','cnt_int'],
    exclude_stats_numeric=[],
    include_stats_varchar=['placeholder','min_length','max_length','avg_length','cnt_leading_ws','cnt_trailing_ws','cnt_empty_after_trim','cnt_lower','cnt_upper','cnt_mixed','cnt_cast_int','cnt_cast_decimal','cnt_cast_date','cnt_cast_timestamp'],
    exclude_stats_varchar=[],
    include_stats_datetime=['placeholder','min','max'],
    exclude_stats_datetime=[],
    num_outliers_columns=[],
    num_distribution_columns=[],
    vc_top3_columns=[],
    placeholders=dict(numeric=0, text='Unknown', date='1900-01-01'),
    where_clause=None,
    row_limit=None,
    max_columns_per_batch=20,
    auto_for_top3_num_unq_val=20,  
    loaddate=None,
    invocated_from_materialization = 'N',
    SQL_to_Profile = None
) %}

  {% set database_name     = database_name     | default(target.database, true) %}



    {% if not SQL_to_Profile %}
  {{ log('1. Verifying table to profile exists: ' ~ schema_name ~ '.' ~ table_name, info=True) }}
  
  {% set rel = adapter.get_relation(
      database=target.database,
      schema=schema_name | lower,
      identifier=table_name | lower
  ) %}
  {% if not rel %}
    {{ exceptions.raise_compiler_error('Relation not found or not visible: ' ~ schema_name ~ '.' ~ table_name) }}
  {% endif %}
  
  {{ log('1. Done', info=True) }}

  {% endif %}


 

  {{ log('2. Processing profiling parameters', info=True) }}
  {% set profiles_db     = profiles_db     | default(target.database, true) %}
  {% set profiles_schema = profiles_schema | default(target.schema,   true) %}
  {% set profiles_table  = profiles_table  | default('profiles',      true) %}

  {# Build default profile_name; append where/limit qualifiers when present #}
  {% set default_profile_name = database_name ~ '_' ~ schema_name ~ '_' ~ table_name %}
  {% if where_clause %}
    {% set default_profile_name = default_profile_name ~ '_where_' ~ (where_clause | replace("'", "''")) %}
  {% endif %}
  {% if row_limit %}
    {% set default_profile_name = default_profile_name ~ '_limit_' ~ row_limit %}
  {% endif %}
  {% set profile_name = profile_name | default(default_profile_name, true) %}

  {# Merge explicit include list with columns requested for outliers/top3 when include list provided #}
  {% if include_columns | length > 0 %}
    {% set all_columns_to_include = include_columns + num_outliers_columns + vc_top3_columns + num_distribution_columns %}
  {% else %}
    {% set all_columns_to_include = include_columns %}
  {% endif %}

  {# Normalize lists to lower case for comparison later #}
  {% set include_columns          = (all_columns_to_include      | default([])) | map('lower') | list %}
  {% set exclude_columns          = (exclude_columns             | default([])) | map('lower') | list %}
  {% set include_stats_numeric    = (include_stats_numeric       | default([])) | map('lower') | list %}
  {% set exclude_stats_numeric    = (exclude_stats_numeric       | default([])) | map('lower') | list %}
  {% set include_stats_varchar    = (include_stats_varchar       | default([])) | map('lower') | list %}
  {% set exclude_stats_varchar    = (exclude_stats_varchar       | default([])) | map('lower') | list %}
  {% set include_stats_datetime   = (include_stats_datetime      | default([])) | map('lower') | list %}
  {% set exclude_stats_datetime   = (exclude_stats_datetime      | default([])) | map('lower') | list %}

  {% if  include_stats_numeric | length == 0 %}
    {% set include_stats_numeric = ['placeholder','min','max','avg','stddev_pop','cnt_neg','cnt_zero','cnt_pos','cnt_int'] %}
  {% endif %}

  {% if  include_stats_varchar | length == 0 %}
    {% set include_stats_varchar = ['placeholder','min_length','max_length','avg_length','cnt_leading_ws','cnt_trailing_ws','cnt_empty_after_trim','cnt_lower','cnt_upper','cnt_mixed','cnt_cast_int','cnt_cast_decimal','cnt_cast_date','cnt_cast_timestamp'] %}
  {% endif %}

  {% if  include_stats_datetime | length == 0 %}
    {% set include_stats_datetime = ['placeholder','min','max'] %}
  {% endif %}

  {% if  not placeholders  %}
    {% set placeholders = dict(numeric=0, text='Unknown', date='1900-01-01') %}
  {% endif %}



  {% set placeholder_numeric = placeholders.numeric %}
  {% set placeholder_text    = placeholders.text %}
  {% set placeholder_date    = placeholders.date %}

  {% set max_cols_to_process = (max_columns_per_batch | int) if max_columns_per_batch is not none else 20 %}


  {{ log('2. Done', info=True) }}



  {% if invocated_from_materialization == 'N' %}

  {{ log('3. Verifying and creating profile table if not exists', info=True) }}
  {{ create_table_for_profile(profiles_db, profiles_schema, profiles_table) }}
  {{ log('3. Done', info=True) }}  

  {% else %}

  {{ log('3. Profile table if not exists is created in materialization flow based on an empty record - clean up', info=True) }}
  {{ clean_up_profiling_table(profiles_db, profiles_schema, profiles_table) }}
  {{ log('3. Done', info=True) }}

  {% endif %}

{# Temporary table is used for profiling data set #}
 {% set temp_table_name = 'temp_' ~ database_name ~ '_' ~ schema_name ~ '_' ~ table_name ~ '_' ~ invocation_id | replace('-', '_') %}

 {% if not SQL_to_Profile %}

  {{ log('4. Retrieving columns and their categories for profiling', info=True) }}
  {% set cols_tbl = get_columns_categories(database_name, schema_name, table_name, include_columns, exclude_columns) %}

  {% if cols_tbl is none or cols_tbl.rows | length == 0 %}
    {{ exceptions.raise_compiler_error('No columns found for ' ~ schema_name ~ '.' ~ table_name) }}
  {% endif %}
  {% set columns_categories = cols_tbl.rows %}
  {{ log('4. Done', info=True) }}

  {{ log('5. Materializing data set for profiling in a temporary table', info=True) }}
  
  {{ create_temp_table(temp_table_name, columns_categories, database_name, schema_name, table_name, where_clause, row_limit) }}
  {{ log('5. Done', info=True) }}

  {% else %}

  {{ log('4. Materializing SQL_to_Profile for profiling in a temporary table', info=True) }}  
  
  {% set schema_name = create_temp_table_from_SQL(temp_table_name, SQL_to_Profile) %}
  {% set table_name = temp_table_name %}

  {{ log(temp_table_name ~ ' was created in ' ~ schema_name ~ ' schema ', info=True) }}

  {{ log('4. Done', info=True) }}

  
  {{ log('5. Retrieving columns and their categories for profiling', info=True) }}
  {% set cols_tbl = get_columns_categories(database_name, schema_name, table_name, include_columns, exclude_columns) %}

  {% if cols_tbl is none or cols_tbl.rows | length == 0 %}
    {{ exceptions.raise_compiler_error('No columns found for ' ~ schema_name ~ '.' ~ table_name) }}
  {% endif %}
  {% set columns_categories = cols_tbl.rows %}
  {{ log('5. Done', info=True) }}


  {% endif %}

  {{ log('6. Creating batches of columns for processing of ' ~ max_cols_to_process, info=True) }}
  {% set batches = [] %}
  {% for i in range(0, columns_categories | length, max_cols_to_process) %}
    {% do batches.append(columns_categories[i : i + max_cols_to_process]) %}
  {% endfor %}
  {{ log('6. Done', info=True) }}
  {{ log((batches | length) ~ ' batches created', info=True) }}

  {# Optional: echo batch composition to logs #}
  {% for batch in batches %}
    {% set batch_id = loop.index %}
    {{ log('Batch # ' ~ batch_id, info=True) }}
    {{ log('----------------------------------------------------', info=True) }}
    {%- for c in batch %}
      {%- set col = c[0] -%}
      {%- set data_type_cat = c[1] -%}
      {{ log(col ~ ' (' ~ data_type_cat ~ ')', info=True) }}
    {% endfor %}
    {{ log('----------------------------------------------------', info=True) }}
  {% endfor %}

  {{ log('7. Cleaning up profiling rows from a previous run (same profile_name)', info=True) }}
  {{ delete_profile(profiles_db, profiles_schema, profiles_table, database_name, schema_name, table_name, profile_name) }}
  {{ log('7. Done', info=True) }}

  {{ log('8. Profiling columns (core stats)', info=True) }}
  {{ profiling_columns_core(
      batches,
      temp_table_name,
      profiles_db,
      profiles_schema,
      profiles_table,
      database_name,
      schema_name,
      table_name,
      profile_name,
      where_clause,
      row_limit,
      include_stats_numeric,
      exclude_stats_numeric,
      include_stats_varchar,
      exclude_stats_varchar,
      include_stats_datetime,
      exclude_stats_datetime,
      placeholder_numeric,
      placeholder_text,
      placeholder_date,
      loaddate
  ) }}
  {{ log('8. Done', info=True) }}



  {{ log('9. Profiling outliers (numeric)', info=True) }}
  {{ profiling_outliers(
      num_outliers_columns,
      columns_categories,
      temp_table_name,
      profiles_db,
      profiles_schema,
      profiles_table,
      schema_name,
      table_name,
      profile_name
  ) }}
  {{ log('9. Done', info=True) }}


    {{ log('10. Profiling distribution (numeric)', info=True) }}
  {{ profiling_distribution(
      num_distribution_columns,
      columns_categories,
      temp_table_name,
      profiles_db,
      profiles_schema,
      profiles_table,
      schema_name,
      table_name,
      profile_name
  ) }}

  {{ log('11. Profiling top3 and Shannon entropy (varchar)', info=True) }}
  {{ profiling_top3_shannon_entropy(
      vc_top3_columns,
      columns_categories,
      temp_table_name,
      profiles_db,
      profiles_schema,
      profiles_table,
      schema_name,
      table_name,
      profile_name,
      auto_for_top3_num_unq_val
  ) }}
  {{ log('11. Done', info=True) }}

  {{ log('12. Dropping temporary table', info=True) }}
  {{ drop_temp_table(temp_table_name) }}
  {{ log('12. Done', info=True) }}




  {% if invocated_from_materialization == 'N' %}
  {# The following commit is not needed when invoked from materialization as materialization does its own commit #}
  
  {{ log('13. Committing the transaction', info=True) }}
  {{ adapter.commit() }}
  {{ log('14. Done', info=True) }}

  {% endif %}

  {{ log('All steps completed successfully!', info=True) }}
{% endmacro %}
