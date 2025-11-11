{#-
  Macro: profiling_columns_core
  Purpose: Iterate over batches of columns from a temp table and compute core profiling
           statistics, inserting results into the profiles table.
  Arguments:           
      - batches: List of batches, each is a list of (column_name, data_type_category)
      - temp_table_name: Name of the temporary table with data to profile
      - profiles_db / profiles_schema / profiles_table: Destination for results
      - schema_name / table_name: Relation being profiled
      - profile_name: Name of the profile
      - where_clause / row_limit: Optional filters for the profiled dataset
      - include/exclude_stats_*: Stat toggles per category
      - placeholder_*: Placeholder values per category
      - loaddate: Timestamp for when profiling was performed
-#}
{% macro profiling_columns_core(
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
) %}



  {% for batch in batches %}
    {% set batch_id = loop.index %}
    {{ log('Processing batch # ' ~ batch_id, info=True) }}

    {% set profile_sql %}
    INSERT INTO {{ profiles_db }}.{{ profiles_schema }}.{{ profiles_table }}
    WITH agg AS (
      SELECT
        COUNT(*) AS total_rows,
        {% for c in batch %}
          {% set col = c[0] %}
          {% set data_type_cat = c[1] %}
          {% if not loop.first %},{% endif %}
          SUM(CASE WHEN {{ col }} IS NULL THEN 1 ELSE 0 END) AS cnt_nulls_{{ col }},
          COUNT(DISTINCT {{ col }}) AS cnt_uniqs_{{ col }},

          {% if data_type_cat == 'numeric' %}
            {%- if 'placeholder' in include_stats_numeric and 'placeholder' not in exclude_stats_numeric -%}
            SUM(CASE WHEN {{ col }} = {{ placeholder_numeric }} THEN 1 ELSE 0 END) AS num_cnt_placeholders_{{ col }},
            {%- else -%}
            NULL::INTEGER AS num_cnt_placeholders_{{ col }},
            {%- endif -%}

            {%- if 'min' in include_stats_numeric and 'min' not in exclude_stats_numeric -%}
            MIN({{ col }}) AS num_min_{{ col }},
            {%- else -%}
            NULL::DECIMAL(38,10) AS num_min_{{ col }},
            {%- endif -%}

            {%- if 'max' in include_stats_numeric and 'max' not in exclude_stats_numeric -%}
            MAX({{ col }}) AS num_max_{{ col }},
            {%- else -%}
            NULL::DECIMAL(38,10) AS num_max_{{ col }},
            {%- endif -%}

            {%- if 'avg' in include_stats_numeric and 'avg' not in exclude_stats_numeric -%}
            AVG({{ col }}) AS num_mean_{{ col }},
            {%- else -%}
            NULL::DECIMAL(38,10) AS num_mean_{{ col }},
            {%- endif -%}

            {%- if 'stddev_pop' in include_stats_numeric and 'stddev_pop' not in exclude_stats_numeric -%}
            STDDEV_POP({{ col }}) AS num_sd_{{ col }},
            {%- else -%}
            NULL::DECIMAL(38,10) AS num_sd_{{ col }},
            {%- endif -%}

            {%- if 'cnt_neg' in include_stats_numeric and 'cnt_neg' not in exclude_stats_numeric -%}
            SUM(CASE WHEN {{ col }} < 0 THEN 1 ELSE 0 END) AS num_cnt_neg_{{ col }},
            {%- else -%}
            NULL::INTEGER AS num_cnt_neg_{{ col }},
            {%- endif -%}

            {%- if 'cnt_zero' in include_stats_numeric and 'cnt_zero' not in exclude_stats_numeric -%}
            SUM(CASE WHEN {{ col }} = 0 THEN 1 ELSE 0 END) AS num_cnt_zero_{{ col }},
            {%- else -%}
            NULL::INTEGER AS num_cnt_zero_{{ col }},
            {%- endif -%}

            {%- if 'cnt_pos' in include_stats_numeric and 'cnt_pos' not in exclude_stats_numeric -%}
            SUM(CASE WHEN {{ col }} > 0 THEN 1 ELSE 0 END) AS num_cnt_pos_{{ col }},
            {%- else -%}
            NULL::INTEGER AS num_cnt_pos_{{ col }},
            {%- endif -%}

            {%- if 'cnt_int' in include_stats_numeric and 'cnt_int' not in exclude_stats_numeric -%}
            SUM(CASE WHEN ABS(floor({{ col }}) - {{ col }}) < 1e-9 THEN 1 ELSE 0 END) AS num_cnt_int_{{ col }},
            {%- else -%}
            NULL::INTEGER AS num_cnt_int_{{ col }},
            {%- endif -%}            

          {% else %}
            NULL::INTEGER        AS num_cnt_placeholders_{{ col }},
            NULL::DECIMAL(38,10) AS num_min_{{ col }},
            NULL::DECIMAL(38,10) AS num_max_{{ col }},
            NULL::DECIMAL(38,10) AS num_mean_{{ col }},
            NULL::DECIMAL(38,10) AS num_sd_{{ col }},
            NULL::INTEGER        AS num_cnt_neg_{{ col }},
            NULL::INTEGER        AS num_cnt_zero_{{ col }},
            NULL::INTEGER        AS num_cnt_pos_{{ col }},
            NULL::INTEGER        AS num_cnt_int_{{ col }},
          {% endif %}

          {% if data_type_cat == 'varchar' %}
            {%- if 'placeholder' in include_stats_varchar and 'placeholder' not in exclude_stats_varchar -%}
            SUM(CASE WHEN {{ col }} = '{{ placeholder_text }}' THEN 1 ELSE 0 END) AS vc_cnt_placeholders_{{ col }},
            {%- else -%}
            NULL::INTEGER AS vc_cnt_placeholders_{{ col }},
            {%- endif -%}

            {%- if 'min_length' in include_stats_varchar and 'min_length' not in exclude_stats_varchar -%}
            MIN(LENGTH({{ col }})) AS vc_min_length_{{ col }},
            {%- else -%}
            NULL::INTEGER AS vc_min_length_{{ col }},
            {%- endif -%}

            {%- if 'max_length' in include_stats_varchar and 'max_length' not in exclude_stats_varchar -%}
            MAX(LENGTH({{ col }})) AS vc_max_length_{{ col }},
            {%- else -%}
            NULL::INTEGER AS vc_max_length_{{ col }},
            {%- endif -%}

            {%- if 'avg_length' in include_stats_varchar and 'avg_length' not in exclude_stats_varchar -%}
            AVG(LENGTH({{ col }})) AS vc_avg_length_{{ col }},
            {%- else -%}
            NULL::INTEGER AS vc_avg_length_{{ col }},
            {%- endif -%}

            {%- if 'cnt_leading_ws' in include_stats_varchar and 'cnt_leading_ws' not in exclude_stats_varchar -%}
            SUM(CASE WHEN {{ col }} IS NOT NULL AND {{ col }} <> LTRIM({{ col }}) THEN 1 ELSE 0 END) AS vc_cnt_leading_ws_{{ col }},
            {%- else -%}
            NULL::INTEGER AS vc_cnt_leading_ws_{{ col }},
            {%- endif -%}

            {%- if 'cnt_trailing_ws' in include_stats_varchar and 'cnt_trailing_ws' not in exclude_stats_varchar -%}
            SUM(CASE WHEN {{ col }} IS NOT NULL AND {{ col }} <> RTRIM({{ col }}) THEN 1 ELSE 0 END) AS vc_cnt_trailing_ws_{{ col }},
            {%- else -%}
            NULL::INTEGER AS vc_cnt_trailing_ws_{{ col }},
            {%- endif -%}

            {%- if 'cnt_empty_after_trim' in include_stats_varchar and 'cnt_empty_after_trim' not in exclude_stats_varchar -%}
            SUM(CASE WHEN NULLIF(TRIM({{ col }}), '') IS NULL THEN 1 ELSE 0 END) AS vc_cnt_empty_after_trim_{{ col }},
            {%- else -%}
            NULL::INTEGER AS vc_cnt_empty_after_trim_{{ col }},
            {%- endif -%}

            {%- if 'cnt_lower' in include_stats_varchar and 'cnt_lower' not in exclude_stats_varchar -%}
            SUM(CASE WHEN {{ col }} IS NOT NULL AND {{ col }} = LOWER({{ col }}) AND {{ col }} <> UPPER({{ col }}) THEN 1 ELSE 0 END) AS vc_cnt_lower_{{ col }},
            {%- else -%}
            NULL::INTEGER AS vc_cnt_lower_{{ col }},
            {%- endif -%}

            {%- if 'cnt_upper' in include_stats_varchar and 'cnt_upper' not in exclude_stats_varchar -%}
            SUM(CASE WHEN {{ col }} IS NOT NULL AND {{ col }} = UPPER({{ col }}) AND {{ col }} <> LOWER({{ col }}) THEN 1 ELSE 0 END) AS vc_cnt_upper_{{ col }},
            {%- else -%}
            NULL::INTEGER AS vc_cnt_upper_{{ col }},
            {%- endif -%}

            {%- if 'cnt_mixed' in include_stats_varchar and 'cnt_mixed' not in exclude_stats_varchar -%}
            SUM(CASE WHEN {{ col }} IS NOT NULL AND {{ col }} <> UPPER({{ col }}) AND {{ col }} <> LOWER({{ col }}) THEN 1 ELSE 0 END) AS vc_cnt_mixed_{{ col }},
            {%- else -%}
            NULL::INTEGER AS vc_cnt_mixed_{{ col }},
            {%- endif -%}

            {%- if 'cnt_cast_int' in include_stats_varchar and 'cnt_cast_int' not in exclude_stats_varchar -%}
            SUM(CASE WHEN TRY_CAST({{ col }} AS INTEGER) IS NOT NULL THEN 1 ELSE 0 END) AS vc_cnt_cast_int_{{ col }},
            {%- else -%}
            NULL::INTEGER AS vc_cnt_cast_int_{{ col }},
            {%- endif -%}

            {%- if 'cnt_cast_decimal' in include_stats_varchar and 'cnt_cast_decimal' not in exclude_stats_varchar -%}
            SUM(CASE WHEN TRY_CAST({{ col }} AS DECIMAL(38,10)) IS NOT NULL THEN 1 ELSE 0 END) AS vc_cnt_cast_decimal_{{ col }},
            {%- else -%}
            NULL::INTEGER AS vc_cnt_cast_decimal_{{ col }},
            {%- endif -%}

            {# Avoid words like 'current' for Redshift casts #}
            {%- if 'cnt_cast_date' in include_stats_varchar and 'cnt_cast_date' not in exclude_stats_varchar -%}
            SUM(CASE WHEN TRY_CAST(CASE WHEN {{ col }} ILIKE '%current%' THEN NULL ELSE {{ col }} END AS DATE) IS NOT NULL THEN 1 ELSE 0 END) AS vc_cnt_cast_date_{{ col }},
            {%- else -%}
            NULL::INTEGER AS vc_cnt_cast_date_{{ col }},
            {%- endif -%}

            {%- if 'cnt_cast_timestamp' in include_stats_varchar and 'cnt_cast_timestamp' not in exclude_stats_varchar -%}
            SUM(CASE WHEN TRY_CAST(CASE WHEN {{ col }} ILIKE '%current%' THEN NULL ELSE {{ col }} END AS TIMESTAMP) IS NOT NULL THEN 1 ELSE 0 END) AS vc_cnt_cast_ts_{{ col }},
            {%- else -%}
            NULL::INTEGER AS vc_cnt_cast_ts_{{ col }},
            {%- endif -%}

          {% else %}
            NULL::INTEGER AS vc_cnt_placeholders_{{ col }},
            NULL::INTEGER AS vc_min_length_{{ col }},
            NULL::INTEGER AS vc_max_length_{{ col }},
            NULL::INTEGER AS vc_avg_length_{{ col }},
            NULL::INTEGER AS vc_cnt_leading_ws_{{ col }},
            NULL::INTEGER AS vc_cnt_trailing_ws_{{ col }},
            NULL::INTEGER AS vc_cnt_empty_after_trim_{{ col }},
            NULL::INTEGER AS vc_cnt_lower_{{ col }},
            NULL::INTEGER AS vc_cnt_upper_{{ col }},
            NULL::INTEGER AS vc_cnt_mixed_{{ col }},
            NULL::INTEGER AS vc_cnt_cast_int_{{ col }},
            NULL::INTEGER AS vc_cnt_cast_decimal_{{ col }},
            NULL::INTEGER AS vc_cnt_cast_date_{{ col }},
            NULL::INTEGER AS vc_cnt_cast_ts_{{ col }},
          {% endif %}

          {% if data_type_cat == 'date' %}
            {%- if 'placeholder' in include_stats_datetime and 'placeholder' not in exclude_stats_datetime -%}
            SUM(CASE WHEN {{ col }} = '{{ placeholder_date }}' THEN 1 ELSE 0 END) AS dt_cnt_placeholders_{{ col }},
            {%- else -%}
            NULL::INTEGER AS dt_cnt_placeholders_{{ col }},
            {%- endif -%}

            {%- if 'min' in include_stats_datetime and 'min' not in exclude_stats_datetime -%}
            MIN({{ col }}) AS dt_min_{{ col }},
            {%- else -%}
            NULL::VARCHAR(20) AS dt_min_{{ col }},
            {%- endif -%}

            {%- if 'max' in include_stats_datetime and 'max' not in exclude_stats_datetime -%}
            MAX({{ col }}) AS dt_max_{{ col }}
            {%- else -%}
            NULL::VARCHAR(20) AS dt_max_{{ col }}
            {%- endif -%}

          {% else %}
            NULL::INTEGER    AS dt_cnt_placeholders_{{ col }},
            NULL::VARCHAR(20) AS dt_min_{{ col }},
            NULL::VARCHAR(20) AS dt_max_{{ col }}
          {% endif %}
        {% endfor %}
      FROM {{ temp_table_name }}
    ),
    data AS (
      {# Reshape with UNION ALL per column in the batch #}
      {% for c in batch %}
        {% set col = c[0] %}
        {% set data_type_cat = c[1] %}
        {% if not loop.first %}UNION ALL {% endif %}
        SELECT
          {{ dbt.string_literal(col) }}::VARCHAR(100) AS column_name,
          '{{ data_type_cat }}'::VARCHAR(10) AS data_type_category,
          total_rows::INTEGER AS total_rows,
          cnt_nulls_{{ col }}::INTEGER AS cnt_nulls,
          cnt_uniqs_{{ col }}::INTEGER AS cnt_uniqs,
          -- numeric (nullable when not applicable)
          num_cnt_placeholders_{{ col }} AS num_cnt_placeholders,
          num_min_{{ col }}::DECIMAL(38,10) AS num_min,
          num_max_{{ col }}::DECIMAL(38,10) AS num_max,
          num_mean_{{ col }}::DECIMAL(38,10) AS num_mean,
          num_sd_{{ col }}::DECIMAL(38,10) AS num_sd,
          num_cnt_neg_{{ col }}::INTEGER AS num_cnt_neg,
          num_cnt_zero_{{ col }}::INTEGER AS num_cnt_zero,
          num_cnt_pos_{{ col }}::INTEGER AS num_cnt_pos,
          num_cnt_int_{{ col }}::INTEGER AS num_cnt_int,
          -- varchar
          vc_cnt_placeholders_{{ col }}::INTEGER AS vc_cnt_placeholders,
          vc_min_length_{{ col }}::INTEGER AS vc_min_length,
          vc_max_length_{{ col }}::INTEGER AS vc_max_length,
          vc_avg_length_{{ col }}::INTEGER AS vc_avg_length,
          vc_cnt_leading_ws_{{ col }}::INTEGER AS vc_cnt_leading_ws,
          vc_cnt_trailing_ws_{{ col }}::INTEGER AS vc_cnt_trailing_ws,
          vc_cnt_empty_after_trim_{{ col }}::INTEGER AS vc_cnt_empty_after_trim,
          vc_cnt_lower_{{ col }}::INTEGER AS vc_cnt_lower,
          vc_cnt_upper_{{ col }}::INTEGER AS vc_cnt_upper,
          vc_cnt_mixed_{{ col }}::INTEGER AS vc_cnt_mixed,
          vc_cnt_cast_int_{{ col }}::INTEGER AS vc_cnt_cast_int,
          vc_cnt_cast_decimal_{{ col }}::INTEGER AS vc_cnt_cast_decimal,
          vc_cnt_cast_date_{{ col }}::INTEGER AS vc_cnt_cast_date,
          vc_cnt_cast_ts_{{ col }}::INTEGER AS vc_cnt_cast_ts,
          -- date
          dt_cnt_placeholders_{{ col }}::INTEGER AS dt_cnt_placeholders,
          dt_min_{{ col }}::VARCHAR(20) AS dt_min,
          dt_max_{{ col }}::VARCHAR(20) AS dt_max
        FROM agg
      {% endfor %}
    )
    SELECT
      MD5(
        {% if profile_name %}
          '{{ profile_name }}' + c.column_name
        {% else %}
          c.table_catalog + c.table_schema + c.table_name
          {% if where_clause %} + '{{ where_clause | replace("'", "''") }}' {% endif %}
          {% if row_limit %} + '{{ row_limit }}' {% endif %}
          + c.column_name
        {% endif %}
      ) AS profile_column_id,
      '{{ profile_name }}'::VARCHAR(5000) AS profile_name,

      {% if where_clause %}
        '{{ where_clause | replace("'", "''") }}'::VARCHAR(4000)
      {% else %}
        NULL::VARCHAR(4000)
      {% endif %} AS profile_limited_to_where_clause,

      {% if row_limit %}
        {{ row_limit }}
      {% else %}
        NULL::INTEGER
      {% endif %} AS profile_limited_to_row_count,

      -- column metadata
      c.table_catalog AS database_name,
      c.table_schema,
      c.table_name,
      c.column_name,
      c.ordinal_position,
      c.data_type,
      COALESCE(
        c.character_maximum_length::VARCHAR,
        '(' + c.numeric_precision::VARCHAR + ',' + c.numeric_scale::VARCHAR + ')',
        c.datetime_precision::VARCHAR
      ) AS length_or_precision,
      c.is_nullable,
      c.column_default,

      -- data-type category
      data_type_category::VARCHAR(10) AS data_type_category,

      -- totals
      total_rows::INTEGER AS total_rows,

      -- common stats
      cnt_nulls::INTEGER AS cnt_nulls,
      ROUND(100 * cnt_nulls::DECIMAL / total_rows, 2)::DECIMAL(38,10) AS pct_nulls,
      cnt_uniqs::INTEGER AS cnt_uniqs,
      ROUND(100 * cnt_uniqs::DECIMAL / total_rows, 2)::DECIMAL(38,10) AS pct_uniqs,

      -- numeric stats
      num_cnt_placeholders::INTEGER AS num_cnt_placeholders,
      ROUND(100 * num_cnt_placeholders::DECIMAL / total_rows, 2)::DECIMAL(38,10) AS num_pct_placeholders,
      num_min::DECIMAL(38,10)  AS num_min,
      num_max::DECIMAL(38,10)  AS num_max,
      num_mean::DECIMAL(38,10) AS num_mean,
      num_sd::DECIMAL(38,10)   AS num_sd,
      num_cnt_neg::INTEGER     AS num_cnt_neg,
      ROUND(100 * num_cnt_neg::DECIMAL / total_rows, 2)::DECIMAL(38,10)  AS num_pct_neg,
      num_cnt_zero::INTEGER    AS num_cnt_zero,
      ROUND(100 * num_cnt_zero::DECIMAL / total_rows, 2)::DECIMAL(38,10) AS num_pct_zero,
      num_cnt_pos::INTEGER     AS num_cnt_pos,
      ROUND(100 * num_cnt_pos::DECIMAL / total_rows, 2)::DECIMAL(38,10)  AS num_pct_pos,
      num_cnt_int::INTEGER     AS num_cnt_int,
      ROUND(100 * num_cnt_int::DECIMAL / total_rows, 2)::DECIMAL(38,10)  AS num_pct_int,
      -- outlier placeholders (to be updated later)
      NULL::DECIMAL(38,10) AS num_sd_samp,
      NULL::DECIMAL(38,10) AS num_q1,
      NULL::DECIMAL(38,10) AS num_q3,
      NULL::DECIMAL(38,10) AS skewness,
      NULL::DECIMAL(38,10) AS excess_kurtosis,
      NULL::VARCHAR(10)    AS outlier_method,
      NULL::DECIMAL(38,10) AS outlier_lo,
      NULL::DECIMAL(38,10) AS outlier_hi,
      NULL::INTEGER        AS num_cnt_outlier,
      NULL::DECIMAL(38,10) AS num_pct_outlier,
      NULL::SUPER          AS num_histogram,
      -- varchar stats
      vc_cnt_placeholders::INTEGER AS vc_cnt_placeholders,
      ROUND(100 * vc_cnt_placeholders::DECIMAL / total_rows, 2)::DECIMAL(38,10) AS vc_pct_placeholders,
      vc_min_length::INTEGER AS vc_min_length,
      vc_max_length::INTEGER AS vc_max_length,
      vc_avg_length::INTEGER AS vc_avg_length,
      vc_cnt_leading_ws::INTEGER AS vc_cnt_leading_ws,
      ROUND(100 * vc_cnt_leading_ws::DECIMAL / total_rows, 2)::DECIMAL(38,10) AS vc_pct_leading_ws,
      vc_cnt_trailing_ws::INTEGER AS vc_cnt_trailing_ws,
      ROUND(100 * vc_cnt_trailing_ws::DECIMAL / total_rows, 2)::DECIMAL(38,10) AS vc_pct_trailing_ws,
      vc_cnt_empty_after_trim::INTEGER AS vc_cnt_empty_after_trim,
      ROUND(100 * vc_cnt_empty_after_trim::DECIMAL / total_rows, 2) AS vc_pct_empty_after_trim,
      vc_cnt_lower::INTEGER AS vc_cnt_lower,
      ROUND(100 * vc_cnt_lower::DECIMAL / total_rows, 2)::DECIMAL(38,10) AS vc_pct_lower,
      vc_cnt_upper::INTEGER AS vc_cnt_upper,
      ROUND(100 * vc_cnt_upper::DECIMAL / total_rows, 2)::DECIMAL(38,10) AS vc_pct_upper,
      vc_cnt_mixed::INTEGER AS vc_cnt_mixed,
      ROUND(100 * vc_cnt_mixed::DECIMAL / total_rows, 2)::DECIMAL(38,10) AS vc_pct_mixed,
      vc_cnt_cast_int::INTEGER AS vc_cnt_cast_int,
      ROUND(100 * vc_cnt_cast_int::DECIMAL / total_rows, 2)::DECIMAL(38,10) AS vc_pct_cast_int,
      vc_cnt_cast_decimal::INTEGER AS vc_cnt_cast_decimal,
      ROUND(100 * vc_cnt_cast_decimal::DECIMAL / total_rows, 2)::DECIMAL(38,10) AS vc_pct_cast_decimal,
      vc_cnt_cast_date::INTEGER AS vc_cnt_cast_date,
      ROUND(100 * vc_cnt_cast_date::DECIMAL / total_rows, 2)::DECIMAL(38,10) AS vc_pct_cast_date,
      vc_cnt_cast_ts::INTEGER AS vc_cnt_cast_ts,
      ROUND(100 * vc_cnt_cast_ts::DECIMAL / total_rows, 2)::DECIMAL(38,10) AS vc_pct_cast_ts,

      -- top3 / entropy placeholders (to be updated later)
      NULL::SUPER           AS vc_top3_pct,
      NULL::DECIMAL(38,10)  AS vc_shannon_entropy,
      NULL::DECIMAL(38,10)  AS vc_normalized_shannon_entropy,

      -- date stats
      dt_cnt_placeholders::INTEGER AS dt_cnt_placeholders,
      ROUND(100 * dt_cnt_placeholders::DECIMAL / total_rows, 2)::DECIMAL(38,10) AS dt_pct_placeholders,
      dt_min::VARCHAR(20) AS dt_min,
      dt_max::VARCHAR(20) AS dt_max,

      c.remarks,
      {% if loaddate is not none %}
        '{{ loaddate }}'::TIMESTAMP
      {% else %}
        GETDATE()
      {% endif %}   AS loaddate
    FROM data s
    JOIN svv_columns c
      ON s.column_name = c.column_name
    WHERE table_catalog='{{ database_name | lower}}'
      AND table_schema = '{{ schema_name | lower }}'
      AND table_name   = '{{ table_name | lower }}'
    ORDER BY c.ordinal_position;
    {% endset %}

    {{ run_query(profile_sql) }}
    {{ log('Batch # ' ~ batch_id ~ ' processed', info=True) }}
  {% endfor %}

{% endmacro %}