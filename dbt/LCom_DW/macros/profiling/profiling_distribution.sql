{% macro profiling_distribution(
    num_distribution_columns,
    columns_categories,
    temp_table_name,
    profiles_db,
    profiles_schema,
    profiles_table,
    schema_name,
    table_name,
    profile_name
) %}


  
  {% set ns_list = namespace(dist_columns = []) %}

  {% if num_distribution_columns  | length > 0 %}

   {% if num_distribution_columns[0] | lower == 'all' or num_distribution_columns[0] | lower  == 'auto' %}
     
  

    {{ log('10.1 Profiling distribution for all numeric columns', info=True) }}

    {% for col_cat in columns_categories %}
      {% if col_cat[1] == 'numeric' %}
        {% set ns_list.dist_columns = ns_list.dist_columns + [col_cat[0]] %}
      {% endif %}
    {% endfor %}
   

  {% else %}

   {{ log('10.1 Profiling distribution for list of provided columns if they are numeric: ' ~ num_distribution_columns, info=True) }}

   {% set ns_list.dist_columns = num_distribution_columns %}


   {% endif %}
  {% endif %}
  
  {% for col in ns_list.dist_columns %}
    {{ log('Distribution: processing ' ~ col, info=True) }}

    {# Ensure the column exists and is NUMERIC in the provided categories #}
    {% set ns = namespace(found_numeric=false) %}
    {% for col_cat in columns_categories %}
      {% if col_cat[0] == col and col_cat[1] == 'numeric' %}
        {% set ns.found_numeric = true %}
        {% break %}
      {% endif %}
    {% endfor %}

    {% if not ns.found_numeric %}
      {{ log('⚠️ Skipping non-numeric or missing column: ' ~ col, info=True) }}
      {% continue %}
    {% endif %}

    {# Build a single query that calculates
      10-bin histogram for each col using P1–P9 bounds (SUPER JSON)
      and returns:
       - histogram::SUPER
       - column
    #}
    {% set dist %}
WITH base AS (
    SELECT {{ col }} AS num_value
    FROM {{ temp_table_name }}
    WHERE {{ col }} IS NOT NULL
),
pct AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY num_value) OVER () AS p01,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY num_value) OVER () AS p99
    FROM base
),
binned AS (
    SELECT
        CASE
            WHEN p.p99 IS NULL OR p.p01 IS NULL THEN NULL       -- no data
            WHEN p.p99 = p.p01 THEN 10                          -- all values the same
            WHEN b.num_value >= p.p99 THEN 10                   -- clip upper tail
            WHEN b.num_value <= p.p01 THEN 1                    -- clip lower tail
            ELSE LEAST(
                10,
                GREATEST(
                    1,
                    FLOOR(((b.num_value - p.p01) / NULLIF(p.p99 - p.p01, 0)) * 10) + 1
                )
            )
        END::int AS bin_idx
    FROM base b
    CROSS JOIN pct p
),
counts AS (
    SELECT bin_idx, COUNT(*)::int AS cnt
    FROM binned
    WHERE bin_idx IS NOT NULL
    GROUP BY bin_idx
),
-- Generate 1..10
gen10 AS (
    SELECT 1 AS i UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
),
filled AS (
    SELECT g.i AS bin_idx, COALESCE(c.cnt, 0)::int AS cnt
    FROM gen10 g
    LEFT JOIN counts c ON c.bin_idx = g.i
),
totals AS (
    SELECT SUM(cnt)::float AS tot
    FROM filled
),
pct_filled AS (
    SELECT
        f.bin_idx,
        ROUND(100.0 * f.cnt / NULLIF(t.tot, 0), 2) AS pct
    FROM filled f
    CROSS JOIN totals t
)
,final as (
SELECT
    JSON_PARSE(
        '{' ||
        LISTAGG(
            '"Bin' || bin_idx::varchar || '": ' ||
            TO_CHAR(pct, 'FM999999990.00'),
            ', '
        ) WITHIN GROUP (ORDER BY bin_idx)
        || '}'
    )::super AS histogram
FROM pct_filled
)
SELECT *
FROM final
WHERE histogram IS NOT NULL;


    {% endset %}

    {% set cols_tbl = run_query(dist) %}



    {% if cols_tbl | length == 0 %}
      {{ log('⚠️ No data found for column: ' ~ col, info=True) }}
      {% continue %}
    {% endif %}

    {# Update profiles table for this column #}
    {% set update_profiles_table %}
      UPDATE {{ profiles_db }}.{{ profiles_schema }}.{{ profiles_table }}
      SET
        num_histogram                    = {% if not cols_tbl.rows[0][0] %} Null {% else %} json_parse(rtrim(ltrim('{{ cols_tbl.rows[0][0] }}'::varchar,'"'),'"')) {% endif %} 
      WHERE database_name = '{{ target.database }}'
        AND schema_name   = '{{ schema_name }}'
        AND table_name    = '{{ table_name }}'
        AND profile_name  = '{{ profile_name }}'
        AND column_name   = '{{ col }}';
    {% endset %}

    {{ run_query(update_profiles_table) }}
    {{ log('Distribution: finished ' ~ col, info=True) }}
  {% endfor %}

{% endmacro %}
