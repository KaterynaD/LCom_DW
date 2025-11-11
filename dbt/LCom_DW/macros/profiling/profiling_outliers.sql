{#-
  Macro: profiling_outliers
  Purpose: Compute outlier statistics for specified numeric columns from a temp table and
           update matching rows in the profiles table.
  Arguments:
      - num_outliers_columns: List of numeric columns to profile for outliers.
      - columns_categories: List of tuples (column_name, data_type) for all columns in the table.
      - temp_table_name: Name of the temporary table containing the data to profile.
      - profiles_db: Database name where the profiles table is located.
      - profiles_schema: Schema name where the profiles table is located.
      - profiles_table: Name of the profiles table to update.
      - schema_name: Schema name of the table being profiled.
      - table_name: Name of the table being profiled.
      - profile_name: Name of the profile.
-#}
{% macro profiling_outliers(
    num_outliers_columns,
    columns_categories,
    temp_table_name,
    profiles_db,
    profiles_schema,
    profiles_table,
    schema_name,
    table_name,
    profile_name
) %}


{% set ns_list = namespace(outlier_columns = []) %}

  {% if num_outliers_columns  | length > 0 %}

   {% if num_outliers_columns[0] | lower == 'all' or  num_outliers_columns[0] | lower == 'auto' %}
     
  

    {{ log('10.1 Profiling outliers in all numeric columns', info=True) }}

    {% for col_cat in columns_categories %}
      {% if col_cat[1] == 'numeric' %}
        {% set ns_list.outlier_columns = ns_list.outlier_columns + [col_cat[0]] %}
      {% endif %}
    {% endfor %}


  {% else %}

   {{ log('10.1 Profiling outliers for list of provided columns if they are numeric: ' ~ num_outliers_columns, info=True) }}

   {% set ns_list.outlier_columns = num_outliers_columns %}


   {% endif %}
  {% endif %}








  {# Iterate over configured columns; skip if not categorized as numeric #}
  {% for col in ns_list.outlier_columns %}
    {{ log('Outliers: processing column ' ~ col, info=True) }}

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



    {# Build outlier metrics over non-null values for the column #}
    {% set outliers %}
      WITH data AS (
        SELECT {{ col }} AS value
        FROM {{ temp_table_name }}
        WHERE {{ col }} IS NOT NULL
      ),
      moments AS (
        SELECT
          COUNT(*)        AS n,
          AVG(value)      AS mean_v,
          STDDEV_SAMP(value) AS sd_v
        FROM data
      ),
      percentiles AS (
        SELECT DISTINCT
          PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY value) OVER () AS q1,
          PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY value) OVER () AS q3
        FROM data
      ),
      shape AS (
        SELECT
          CASE WHEN m.sd_v > 0
               THEN AVG(POWER((f.value - m.mean_v) / nullif(m.sd_v,0), 3))
               ELSE 0 END AS skewness,
          CASE WHEN m.sd_v > 0
               THEN AVG(POWER((f.value - m.mean_v) / nullif(m.sd_v,0), 4)) - 3
               ELSE 0 END AS excess_kurtosis
        FROM data f
        CROSS JOIN moments m
        GROUP BY m.sd_v
      ),
      fences AS (
        SELECT
          m.n,
          m.mean_v,
          m.sd_v,
          p.q1,
          p.q3,
          (p.q3 - p.q1)              AS iqr,
          (m.mean_v - 3 * m.sd_v)    AS sigma3_lo,
          (m.mean_v + 3 * m.sd_v)    AS sigma3_hi,
          (p.q1 - 1.5 * (p.q3 - p.q1)) AS tukey_lo,
          (p.q3 + 1.5 * (p.q3 - p.q1)) AS tukey_hi
        FROM moments m
        CROSS JOIN percentiles p
      ),
      config AS (
        SELECT
          f.n,
          f.mean_v,
          f.sd_v,
          f.q1,
          f.q3,
          f.iqr,
          f.sigma3_lo,
          f.sigma3_hi,
          f.tukey_lo,
          f.tukey_hi,
          s.skewness,
          s.excess_kurtosis,
          CASE
            WHEN f.n >= 100
             AND f.sd_v > 0
             AND ABS(s.skewness) <= 0.5
             AND s.excess_kurtosis BETWEEN -0.5 AND 0.5
            THEN 'sigma3'
            ELSE 'tukey_iqr'
          END AS recommendation,
          CASE
            WHEN f.n >= 100
             AND f.sd_v > 0
             AND ABS(s.skewness) <= 0.5
             AND s.excess_kurtosis BETWEEN -0.5 AND 0.5
            THEN 'Low skew & near-normal tails → use 3-sigma.'
            ELSE 'Skewed/heavy-tailed or small N → use Tukey IQR.'
          END AS recommendation_reason
        FROM fences f
        CROSS JOIN shape s
      )
      SELECT
        config.n,
        config.sd_v,
        config.q1,
        config.q3,
        config.skewness,
        config.excess_kurtosis,
        config.recommendation AS outlier_method,
        CASE WHEN config.recommendation = 'tukey_iqr' THEN config.tukey_lo ELSE config.sigma3_lo END AS outlier_lo,
        CASE WHEN config.recommendation = 'tukey_iqr' THEN config.tukey_hi ELSE config.sigma3_hi END AS outlier_hi,
        SUM(
          CASE
            WHEN outlier_lo >= data.value THEN 1
            WHEN outlier_hi <= data.value THEN 1
            ELSE 0
          END
        ) AS num_cnt_outlier,
        ROUND(100 * num_cnt_outlier::DECIMAL / nullif(n,0), 2)::DECIMAL(38,10) AS num_pct_outlier
      FROM data
      CROSS JOIN config
      GROUP BY
        config.n,
        config.sd_v,
        config.q1,
        config.q3,
        config.iqr,
        config.sigma3_lo,
        config.sigma3_hi,
        config.tukey_lo,
        config.tukey_hi,
        config.skewness,
        config.excess_kurtosis,
        config.recommendation
    {% endset %}

    {% set cols_tbl = run_query(outliers) %}



    {% if cols_tbl | length == 0 %}
      {{ log('⚠️ No data found for column: ' ~ col, info=True) }}
      {% continue %}
    {% endif %}
    {# Update profiles table with the computed outlier metrics for the column #}





   
    {% set update_profiles_table %}
      UPDATE {{ profiles_db }}.{{ profiles_schema }}.{{ profiles_table }}
      SET
        num_sd_samp      = {% if not cols_tbl.rows[0][1] %} Null {% else %} {{ cols_tbl.rows[0][1] }} {% endif %},
        num_q1           = {% if not cols_tbl.rows[0][2] %} Null {% else %} {{ cols_tbl.rows[0][2] }} {% endif %},
        num_q3           = {% if not cols_tbl.rows[0][3] %} Null {% else %} {{ cols_tbl.rows[0][3] }} {% endif %},
        skewness         = {% if not cols_tbl.rows[0][4] %} Null {% else %} {{ cols_tbl.rows[0][4] }} {% endif %},
        excess_kurtosis  = {% if not cols_tbl.rows[0][5] %} Null {% else %} {{ cols_tbl.rows[0][5] }} {% endif %},
        outlier_method   = '{{ cols_tbl.rows[0][6] }}',
        outlier_lo       = {% if not cols_tbl.rows[0][7] %} Null {% else %} {{ cols_tbl.rows[0][7] }} {% endif %},
        outlier_hi       = {% if not cols_tbl.rows[0][8] %} Null {% else %} {{ cols_tbl.rows[0][8] }} {% endif %},
        num_cnt_outlier  = {% if not cols_tbl.rows[0][9] %} Null {% else %} {{ cols_tbl.rows[0][9] }} {% endif %},
        num_pct_outlier  = {% if not cols_tbl.rows[0][10] %} Null {% else %} {{ cols_tbl.rows[0][10] }} {% endif %}
      WHERE database_name = '{{ target.database }}'
        AND schema_name   = '{{ schema_name }}'
        AND table_name    = '{{ table_name }}'
        AND profile_name  = '{{ profile_name }}'
        AND column_name   = '{{ col }}';
    {% endset %}

    {{ run_query(update_profiles_table) }}
    {{ log('Outliers: finished ' ~ col, info=True) }}

  {% endfor %}
a
{% endmacro %}
