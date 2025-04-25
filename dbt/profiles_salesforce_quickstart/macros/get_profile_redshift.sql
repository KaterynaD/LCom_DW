{% macro default__get_profile(relation, exclude_measures=[], include_columns=[], exclude_columns=[], where_clause=none, group_by=[]) %}

{%- if include_columns and exclude_columns -%}
    {{ exceptions.raise_compiler_error("Both include_columns and exclude_columns arguments were provided to the `get_profile` macro. Only one is allowed.") }}
{%- endif -%}

{%- set all_measures = [
  "row_count",
  "not_null_proportion",
  "distinct_proportion",
  "distinct_count",
  "is_unique",
  "min",
  "max",
  "avg",
  "median",
  "std_dev_population",
  "std_dev_sample"
] -%}

{%- set include_measures = all_measures | reject("in", exclude_measures) -%}

{{ log("Include measures: " ~ include_measures, info=False) }}

{% if execute %}
  {% do dbt_profiler.assert_relation_exists(relation) %}

  {{ log("Get columns in relation %s" | format(relation.include()), info=False) }}
  {%- set relation_columns = adapter.get_columns_in_relation(relation) -%}
  {%- set relation_column_names = relation_columns | map(attribute="name") | list -%}
  {{ log("Relation columns: " ~ relation_column_names | join(', '), info=False) }}

  {%- if include_columns -%}
    {%- set profile_column_names = relation_column_names | select("in", include_columns) | list -%}
  {%- elif exclude_columns -%}
    {%- set profile_column_names = relation_column_names | reject("in", exclude_columns) | list -%}
  {%- else -%}
    {%- set profile_column_names = relation_column_names -%}
  {%- endif -%}

  {{ log("Profile columns: " ~ profile_column_names | join(', '), info=False) }}

  {% set information_schema_columns = run_query(dbt_profiler.select_from_information_schema_columns(relation)) %}
  {% set information_schema_columns = information_schema_columns.rename(information_schema_columns.column_names | map('lower')) %}
  {% set information_schema_data_types = information_schema_columns.columns['data_type'].values() | map('lower') | list %}
  {% set information_schema_column_names = information_schema_columns.columns['column_name'].values() | map('lower') | list %}
  {% set data_type_map = {} %}
  {% for column_name in information_schema_column_names %}
    {% do data_type_map.update({column_name: information_schema_data_types[loop.index-1]}) %}
  {% endfor %}
  {{ log("Column data types: " ~ data_type_map, info=False) }}

  {% set profile_sql %}
    with source_data as (
      select
       {{ dbt_profiler.measure_row_count(column_name, data_type) }} as row_count,
       {% for column_name in profile_column_names %}
        {% set data_type = data_type_map.get(column_name.lower(), "") %}

          {% if "not_null_proportion" not in exclude_measures -%}
            {{ dbt_profiler.measure_not_null_proportion(column_name, data_type) }} as not_null_proportion_{{ column_name }},
          {%- endif %}
          {% if "distinct_proportion" not in exclude_measures -%}
            {{ dbt_profiler.measure_distinct_proportion(column_name, data_type) }} as distinct_proportion_{{ column_name }},
          {%- endif %}
          {% if "distinct_count" not in exclude_measures -%}
            {{ dbt_profiler.measure_distinct_count(column_name, data_type) }} as distinct_count_{{ column_name }},
          {%- endif %}
          {% if "is_unique" not in exclude_measures -%}
            {{ dbt_profiler.measure_is_unique(column_name, data_type) }} as is_unique_{{ column_name }},
          {%- endif %}
          {% if "min" not in exclude_measures -%}
            {{ dbt_profiler.measure_min(column_name, data_type) }} as min_{{ column_name }},
          {%- endif %}
          {% if "max" not in exclude_measures -%}
            {{ dbt_profiler.measure_max(column_name, data_type) }} as max_{{ column_name }},
          {%- endif %}
          {% if "avg" not in exclude_measures -%}
            {{ dbt_profiler.measure_avg(column_name, data_type) }} as avg_{{ column_name }},
          {%- endif %}
          {% if "median" not in exclude_measures -%}
            ({{ dbt_profiler.measure_median(column_name, data_type, 'source_data') }}) as median_{{ column_name }},
          {%- endif %}
          {% if "std_dev_population" not in exclude_measures -%}
            {{ dbt_profiler.measure_std_dev_population(column_name, data_type) }} as std_dev_population_{{ column_name }},
          {%- endif %}
          {% if "std_dev_sample" not in exclude_measures -%}
            {{ dbt_profiler.measure_std_dev_sample(column_name, data_type) }} as std_dev_sample_{{ column_name }},
          {%- endif %}
      {% endfor %}
      cast(current_timestamp as {{ dbt_profiler.type_string() }}) as profiled_at
      from {{ relation }}
      {% if where_clause %}
        where {{ where_clause }}
      {% endif %}
    ),

    column_profiles as (
      {% for column_name in profile_column_names %}

        {% set data_type = data_type_map.get(column_name.lower(), "") %}
        select          
          lower('{{ column_name }}') as column_name,
          nullif(lower('{{ data_type }}'), '') as data_type,
          row_count,

          {% if "not_null_proportion" not in exclude_measures -%}
            not_null_proportion_{{ column_name }}/ cast(row_count as {{ dbt.type_numeric() }})  as not_null_proportion,
          {%- endif %}
          {% if "distinct_proportion" not in exclude_measures -%}
            distinct_proportion_{{ column_name }}/ cast(row_count as {{ dbt.type_numeric() }}) as distinct_proportion,
          {%- endif %}
          {% if "distinct_count" not in exclude_measures -%}
            distinct_count_{{ column_name }} as distinct_count,
          {%- endif %}
          {% if "is_unique" not in exclude_measures -%}
            is_unique_{{ column_name }} = row_count as is_unique,
          {%- endif %}
          {% if "min" not in exclude_measures -%}
            min_{{ column_name }} as "min",
          {%- endif %}
          {% if "max" not in exclude_measures -%}
            max_{{ column_name }} as "max",
          {%- endif %}
          {% if "avg" not in exclude_measures -%}
            avg_{{ column_name }} as "avg",
          {%- endif %}
          {% if "median" not in exclude_measures -%}
            median_{{ column_name }} as "median",
          {%- endif %}
          {% if "std_dev_population" not in exclude_measures -%}
            std_dev_population_{{ column_name }} as std_dev_population,
          {%- endif %}
          {% if "std_dev_sample" not in exclude_measures -%}
            std_dev_sample_{{ column_name }} as std_dev_sample,
          {%- endif %}   
          profiled_at,
          {{ loop.index }} as _column_position
        from source_data
        {% if not loop.last %}union all{% endif %}
      {% endfor %}
    )

    select
      *
    from column_profiles
    order by {% if group_by %}{{ group_by | join(", ") }},{% endif %} _column_position asc
  {% endset %}

  {% do return(profile_sql) %}
{% endif %}

{% endmacro %}

{%- macro default__measure_not_null_proportion(column_name, data_type) -%}

sum(case when {{ adapter.quote(column_name) }} is null then 0 else 1 end) 
{%- endmacro -%}

{%- macro default__measure_distinct_proportion(column_name, data_type) -%}
{%- if not dbt_profiler.is_struct_dtype(data_type) -%}

    count(distinct {{ adapter.quote(column_name) }})
{%- else -%}
    cast(null as {{ dbt.type_numeric() }})
{%- endif -%}
{%- endmacro -%}

{%- macro default__measure_is_unique(column_name, data_type) -%}
{%- if not dbt_profiler.is_struct_dtype(data_type) -%}
    count(distinct {{ adapter.quote(column_name) }})
{%- else -%}
    null
{%- endif -%}
{%- endmacro -%}