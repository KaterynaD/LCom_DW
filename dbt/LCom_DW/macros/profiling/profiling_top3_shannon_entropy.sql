{#-
  Macro: profiling_top3_shannon_entropy
  Purpose: For selected VARCHAR columns, compute top-3 value percentages (plus "Other")
           and Shannon entropy (H) with its normalized version. Results are written
           into the profiles table.
  Arguments:
      - vc_top3_columns: List of varchar columns to profile.
      - columns_categories: List of tuples (column_name, data_type) for all columns in the table.
      - temp_table_name: Name of the temporary table containing the data to profile.
      - profiles_db: Database name where the profiles table is located.
      - profiles_schema: Schema name where the profiles table is located.
      - profiles_table: Name of the profiles table to update.
      - schema_name: Schema name of the table being profiled.
      - table_name: Name of the table being profiled.
      - profile_name: Name of the profile.
-#}
{% macro profiling_top3_shannon_entropy(
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
) %}

  
  {% set ns_list = namespace(top3_columns = []) %}

  {% if vc_top3_columns  | length > 0 %}

   {% if vc_top3_columns[0] | lower == 'all' %}
     
  

    {{ log('10.1 Profiling top3 and Shannon entropy for all varchar columns', info=True) }}

    {% for col_cat in columns_categories %}
      {% if col_cat[1] == 'varchar' %}
        {% set ns_list.top3_columns = ns_list.top3_columns + [col_cat[0]] %}
      {% endif %}
    {% endfor %}



   {% elif vc_top3_columns[0] | lower  == 'auto' %}
   


   {{ log('10.1 Profiling top3 and Shannon entropy for varchar columns if there are no more then '~ auto_for_top3_num_unq_val ~' unique values', info=True) }}

   {% set cols_sql %}
    SELECT
      column_name
    FROM {{ profiles_db }}.{{ profiles_schema }}.{{ profiles_table }}
    WHERE database_name = '{{ target.database }}'
        AND schema_name   = '{{ schema_name }}'
        AND table_name    = '{{ table_name }}'
        AND profile_name  = '{{ profile_name }}'
        AND data_type_category='varchar'
        AND cnt_uniqs between 2 and {{ auto_for_top3_num_unq_val }}
    ORDER BY ordinal_position;
  {% endset %}

  {% set cols = run_query(cols_sql) %}
    
  {% for col in cols.rows %}

   {% set ns_list.top3_columns = ns_list.top3_columns + [col[0]] %}

  {% endfor %}

  {{ log('10.2 Found: '~ ns_list.top3_columns | length ~ ' columns for profiling top3  and Shannon entropy ', info=True) }}

  {% else %}

   {{ log('10.1 Profiling top3 and Shannon entropy for list of provided columns if they are varchar: ' ~ vc_top3_columns, info=True) }}

   {% set ns_list.top3_columns = vc_top3_columns %}


   {% endif %}
  {% endif %}
  
  {% for col in ns_list.top3_columns %}
    {{ log('Top3/Entropy: processing ' ~ col, info=True) }}

    {# Ensure the column exists and is VARCHAR in the provided categories #}
    {% set ns = namespace(found_varchar=false) %}
    {% for col_cat in columns_categories %}
      {% if col_cat[0] == col and col_cat[1] == 'varchar' %}
        {% set ns.found_varchar = true %}
        {% break %}
      {% endif %}
    {% endfor %}

    {% if not ns.found_varchar %}
      {{ log('⚠️ Skipping non-varchar or missing column: ' ~ col, info=True) }}
      {% continue %}
    {% endif %}

    {# Build a single query that returns:
       - top3_pct_json::SUPER
       - shannon entropy H
       - normalized entropy H / ln(k), where k is number of unique values
    #}
    {% set top3 %}
      WITH base AS (
        SELECT replace(replace({{ col }},'"',''),'''','')  AS value
        FROM {{ temp_table_name }}
      ),
      counts AS (
        SELECT value, COUNT(*)::BIGINT AS cnt
        FROM base
        GROUP BY value
      ),
      totals AS (
        SELECT COUNT(*)::BIGINT AS n FROM base
      ),
      kvals AS (
        SELECT COUNT(*)::INT AS k FROM counts
      ),
      entropy AS (
        -- Shannon entropy H = -Σ p ln p
        SELECT
          COALESCE(
            SUM(
              CASE WHEN t.n > 0 THEN
                - (c.cnt::DOUBLE PRECISION / t.n::DOUBLE PRECISION)
                  * LN(c.cnt::DOUBLE PRECISION / t.n::DOUBLE PRECISION)
              ELSE 0.0 END
            ),
            0.0
          ) AS H
        FROM counts c
        CROSS JOIN totals t
      ),
      top3 AS (
        SELECT
          value,
          cnt,
          ROW_NUMBER() OVER (
            ORDER BY cnt DESC,
                     CASE WHEN value IS NULL THEN 1 ELSE 0 END,
                     value
          ) AS rn
        FROM counts
      ),
      top3_pcts AS (
        SELECT
          t3.value,
          t3.cnt,
          ROUND(
            CASE WHEN tot.n > 0
                 THEN 100.0 * t3.cnt::DOUBLE PRECISION / tot.n::DOUBLE PRECISION
                 ELSE 0.0 END,
            2
          ) AS pct
        FROM top3 t3
        CROSS JOIN totals tot
        WHERE t3.rn <= 3
      ),
      sum3 AS (
        SELECT COALESCE(SUM(pct), 0.0) AS sum_pct FROM top3_pcts
      ),
      top3_pairs AS (
        SELECT
          CASE
            WHEN value IS NULL THEN JSON_SERIALIZE('NULL'::SUPER)
            ELSE JSON_SERIALIZE(value::SUPER)
          END AS key_json,
          TO_CHAR(pct, 'FM999999990.00') AS pct_txt,
          cnt AS sort_cnt
        FROM top3_pcts
      ),
      json_obj AS (
        SELECT
          CASE
            WHEN (SELECT n FROM totals) = 0 THEN '{}'
            ELSE
              '{'
              || COALESCE(
                   (SELECT LISTAGG(key_json || ':' || pct_txt, ', ')
                      WITHIN GROUP (ORDER BY sort_cnt DESC, key_json)
                    FROM top3_pairs),
                   ''
                 )
              || ', ' || JSON_SERIALIZE('Other_'::SUPER) || ':'
              || TO_CHAR(
                   ROUND(GREATEST(0.0, 100.0 - (SELECT sum_pct FROM sum3)), 2),
                   'FM999999990.##'
                 )
              || '}'
          END AS top3_pct_json
      )
      SELECT
        rtrim(ltrim(j.top3_pct_json::varchar,'"'),'"') as top3_pct_json,
        e.H AS shannon_entropy,
        CASE WHEN k.k > 1 THEN e.H / LN(k.k::DOUBLE PRECISION) ELSE 0.0 END AS normalized_shannon_entropy
      FROM json_obj j
      CROSS JOIN entropy e
      CROSS JOIN kvals k;
    {% endset %}

    {% set cols_tbl = run_query(top3) %}

    {% if cols_tbl | length == 0 %}
      {{ log('⚠️ No data found for column: ' ~ col, info=True) }}
      {% continue %}
    {% endif %}

    {{ log('top3: ' ~ col, info=True) }}

    {# Update profiles table for this column #}
    {% set update_profiles_table %}
      UPDATE {{ profiles_db }}.{{ profiles_schema }}.{{ profiles_table }}
      SET
        vc_top3_pct                    = {% if not cols_tbl.rows[0][0] %} Null {% else %} json_parse(rtrim(ltrim('{{ cols_tbl.rows[0][0] }}'::varchar,'"'),'"')) {% endif %}  ,
        vc_shannon_entropy             = {% if not cols_tbl.rows[0][1] %} Null {% else %} {{ cols_tbl.rows[0][1] }} {% endif %},
        vc_normalized_shannon_entropy  = {% if not cols_tbl.rows[0][2] %} Null {% else %} {{ cols_tbl.rows[0][2] }} {% endif %}
      WHERE database_name = '{{ target.database }}'
        AND schema_name   = '{{ schema_name }}'
        AND table_name    = '{{ table_name }}'
        AND profile_name  = '{{ profile_name }}'
        AND column_name   = '{{ col }}';
    {% endset %}

    {{ run_query(update_profiles_table) }}
    {{ log('Top3/Entropy: finished ' ~ col, info=True) }}
  {% endfor %}

{% endmacro %}
