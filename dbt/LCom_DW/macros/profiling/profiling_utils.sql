{#-
  Macro: sql_in_list_str
  Purpose: Return a single-quoted, comma-separated string for an IN() list.
           Properly escapes single quotes and lowercases values.
  Arguments:
    values (list): Values to include.
  Returns:
    str: e.g., 'a', 'b', 'c'
-#}
{% macro sql_in_list_str(values) %}
  {%- set out = [] -%}
  {%- for v in values | list -%}
    {%- set v_escaped = (v | string) | replace("'", "''") | lower -%}
    {%- do out.append("'" ~ v_escaped ~ "'") -%}
  {%- endfor -%}
  {{ return(out | join(', ')) }}
{% endmacro %}

{# ===================================================================================== #}

{#-
  Macro: get_columns_categories
  Purpose: Retrieve table columns with a simplified data-type category.
  Arguments:
    schema_name : Schema of the table.
    table_name  : Table name.
    include_columns : Only include these columns (case-insensitive).
    exclude_columns : Exclude these columns (case-insensitive).
  Returns:
    agate.Table: Rows of (column_name, data_type_category)
-#}
{% macro get_columns_categories(database_name,
                                schema_name,
                                table_name,
                                include_columns=[],
                                exclude_columns=[]) %}

  {% set cols_sql %}
    SELECT
      column_name,
      CASE
        /* -------- numeric -------- */
        WHEN LOWER(data_type) IN ('smallint','integer','int','bigint','decimal','numeric','real','double precision') THEN 'numeric'
        WHEN LOWER(data_type) LIKE 'float%%'                                                                     THEN 'numeric'  -- float, float4, float8
        WHEN LOWER(data_type) = 'number'                                                                         THEN 'numeric'

        /* -------- varchar / character -------- */
        WHEN LOWER(data_type) IN ('character varying','varchar','character','char','bpchar','text')              THEN 'varchar'

        /* -------- date / time family -------- */
        WHEN LOWER(data_type) = 'date'                                                                           THEN 'date'
        WHEN LOWER(data_type) LIKE 'timestamp%%'                                                                 THEN 'date'    -- timestamp, timestamptz
        WHEN LOWER(data_type) IN ('time','timetz')                                                                THEN 'date'

        /* -------- everything else -------- */
        ELSE 'other'
      END AS data_type_category
    FROM svv_columns
    WHERE table_catalog='{{ database_name | lower}}'
      AND table_schema = '{{ schema_name | lower }}'
      AND table_name   = '{{ table_name | lower }}'
      AND data_type <> 'super'  -- SUPER can't be COUNT(DISTINCT)

      {% if include_columns | length > 0 %}
        AND LOWER(column_name) IN ({{ sql_in_list_str(include_columns) }})
      {% endif %}

      {% if exclude_columns | length > 0 %}
        AND LOWER(column_name) NOT IN ({{ sql_in_list_str(exclude_columns) }})
      {% endif %}

    ORDER BY ordinal_position;
  {% endset %}

  {% set cols_tbl = run_query(cols_sql) %}

  {{ return(cols_tbl) }}

{% endmacro %}

{# ===================================================================================== #}

{#-
  Macro: create_temp_table
  Purpose: Create a temporary table from a source relation with optional filters and limits.
  Arguments:
    temp_table_name : Name of the temp table to create.
    columns (list[(col, typecat)]): Columns to include (tuples; only the 1st element is selected).
    schema_name : Source schema.
    table_name : Source table.
    where_clause : Raw WHERE condition without the keyword WHERE.
    row_limit : Limit number of rows.
-#}
{% macro create_temp_table(temp_table_name,
                           columns,
                           database_name,
                           schema_name,
                           table_name,
                           where_clause=None,
                           row_limit=None) %}

  {% set create_temp_table %}
    SET SEED TO 42;
    DROP TABLE IF EXISTS {{ temp_table_name }};
    CREATE TEMPORARY TABLE {{ temp_table_name }} AS
    SELECT
      {% for c in columns %}
        {% if not loop.first %}, {% endif %}
        {{ c[0] }}
      {% endfor %}
    FROM {{ database_name }}.{{ schema_name }}.{{ table_name }}
    {%- if where_clause %}
      WHERE ({{ where_clause }})
    {%- endif %}
    {%- if row_limit %}
      LIMIT {{ row_limit }}
    {%- endif %}
  {% endset %}

  {{ run_query(create_temp_table) }}
{% endmacro %}

{# ===================================================================================== #}

{#-
  Macro: create_temp_table_from_SQL
  Purpose: Create a temporary table from provided SQL.
  Arguments:
    temp_table_name : Name of the temp table to create.
    SQL_to_Profile: SQL query to use for creating the temp table.
-#}
{% macro create_temp_table_from_SQL(temp_table_name,
                                    SQL_to_Profile) %}

  {% set create_temp_table %}
    SET SEED TO 42;
    DROP TABLE IF EXISTS {{ temp_table_name }};
    CREATE TEMPORARY TABLE {{ temp_table_name }} AS
    {{ SQL_to_Profile }}
  {% endset %}
  
  {{ run_query(create_temp_table) }}

  {% set get_schema_name %}

    SELECT schema_name
    FROM SVV_ALL_TABLES
    WHERE table_name = '{{ temp_table_name }}';

  {% endset %}


  {% set schema_name = run_query(get_schema_name).columns[0][0] %}
  {{ return(schema_name) }}

{% endmacro %}

{# ===================================================================================== #}

{#-
  Macro: drop_temp_table
  Purpose: Drop a temporary table if it exists.
  Arguments:
    temp_table_name : Temp table to drop.
-#}
{% macro drop_temp_table(temp_table_name) %}
  {% set drop_temp_table %}
    DROP TABLE IF EXISTS {{ temp_table_name }};
  {% endset %}
  {{ run_query(drop_temp_table) }}
{% endmacro %}

{# ===================================================================================== #}

{#-
  Macro: delete_profile
  Purpose: Remove existing profiling rows for a given (db,schema,table,profile_name).
  Arguments:
    profiles_db
    profiles_schema
    profiles_table
    schema_name
    table_name 
    profile_name
-#}
{% macro delete_profile(profiles_db, profiles_schema, profiles_table, database_name, schema_name, table_name, profile_name) %}

  {% set delete_profile_sql %}
    DELETE FROM {{ profiles_db }}.{{ profiles_schema }}.{{ profiles_table }}
    WHERE database_name = '{{ database_name | lower}}'
      AND schema_name   = '{{ schema_name | lower}}'
      AND table_name    = '{{ table_name | lower}}'
      AND profile_name  = '{{ profile_name }}';
  {% endset %}

  {{ run_query(delete_profile_sql) }}
{% endmacro %}
{# ===================================================================================== #}

{#-
  Macro: clean_up_profiling_table
  Purpose: Clean up profiling table from empty record used to create the table in materialization.
  Arguments:
    temp_table_name : Temp table to drop.
-#}
{% macro clean_up_profiling_table(profiles_db, profiles_schema, profiles_table) %}
  {% set drop_temp_table %}
    DELETE FROM {{ profiles_db }}.{{ profiles_schema }}.{{ profiles_table }} WHERE profile_name IS NULL;
  {% endset %}
  {{ run_query(drop_temp_table) }}
{% endmacro %}