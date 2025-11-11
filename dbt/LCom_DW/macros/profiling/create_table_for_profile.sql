{#-
  Macro: create_table_for_profile
  Purpose: Create the profiles table if it does not exist (AWS Redshift).
  Args:
    - profiles_db (str): Database name where the profiles table is located.
    - profiles_schema (str): Schema name where the profiles table is located.
    - profiles_table (str): Name of the profiles table to create.
-#}

{% macro create_table_for_profile(profiles_db, profiles_schema, profiles_table) %}


{% set rel_pt = adapter.get_relation(
    database=profiles_db | lower,
    schema=profiles_schema | lower,
    identifier=profiles_table | lower
) %}

{% if rel_pt is none %}
  {{ log('Table does not exist and will be created: ' ~ profiles_db ~ '.' ~ profiles_schema ~ '.' ~ profiles_table, info=True) }}

  {% set create_table_sql %}

  DROP TABLE IF EXISTS {{ profiles_db }}.{{ profiles_schema }}.{{ profiles_table }};
  CREATE TABLE  {{ profiles_db }}.{{ profiles_schema }}.{{ profiles_table }} (
      profile_column_id                 VARCHAR(32)                     ENCODE lzo NOT NULL,
      profile_name                      VARCHAR(5000)                   ENCODE lzo NOT NULL,
      profile_limited_to_where_clause   VARCHAR(4000)                   ENCODE lzo,
      profile_limited_to_rows           INTEGER                         ENCODE az64,
      database_name                     VARCHAR(128)                    ENCODE lzo NOT NULL,
      schema_name                       VARCHAR(128)                    ENCODE lzo NOT NULL,
      table_name                        VARCHAR(128)                    ENCODE lzo NOT NULL,
      column_name                       VARCHAR(128)                    ENCODE lzo NOT NULL,
      ordinal_position                  INTEGER                         ENCODE RAW NOT NULL,
      data_type                         VARCHAR(128)                    ENCODE lzo NOT NULL,
      length_or_precision               VARCHAR(25)                     ENCODE lzo,
      is_nullable                       VARCHAR(128)                    ENCODE lzo,
      column_default                    VARCHAR(4000)                   ENCODE lzo,
      data_type_category                VARCHAR(10)                     ENCODE lzo NOT NULL,
      total_rows                        INTEGER                         ENCODE az64 NOT NULL,
      cnt_nulls                         INTEGER                         ENCODE az64 NOT NULL,
      pct_nulls                         NUMERIC(38,10)                  ENCODE az64 NOT NULL,
      cnt_uniqs                         INTEGER                         ENCODE az64 NOT NULL,
      pct_uniqs                         NUMERIC(38,10)                  ENCODE az64 NOT NULL,
      num_cnt_placeholders              INTEGER                         ENCODE az64,
      num_pct_placeholders              NUMERIC(38,10)                  ENCODE az64,
      num_min                           NUMERIC(38,10)                  ENCODE az64,
      num_max                           NUMERIC(38,10)                  ENCODE az64,
      num_mean                          NUMERIC(38,10)                  ENCODE az64,
      num_sd_pop                        NUMERIC(38,10)                  ENCODE az64,
      num_cnt_neg                       INTEGER                         ENCODE az64,
      num_pct_neg                       NUMERIC(38,10)                  ENCODE az64,
      num_cnt_zero                      INTEGER                         ENCODE az64,
      num_pct_zero                      NUMERIC(38,10)                  ENCODE az64,
      num_cnt_pos                       INTEGER                         ENCODE az64,
      num_pct_pos                       NUMERIC(38,10)                  ENCODE az64,
      num_cnt_int                       INTEGER                         ENCODE az64,
      num_pct_int                       NUMERIC(38,10)                  ENCODE az64,        
      -- additional numeric distribution stats
      num_sd_samp                       NUMERIC(38,10)                  ENCODE az64,
      num_q1                            NUMERIC(38,10)                  ENCODE az64,
      num_q3                            NUMERIC(38,10)                  ENCODE az64,
      skewness                          NUMERIC(38,10)                  ENCODE az64,
      excess_kurtosis                   NUMERIC(38,10)                  ENCODE az64,
      outlier_method                    VARCHAR(10)                     ENCODE lzo,
      outlier_lo                        NUMERIC(38,10)                  ENCODE az64,
      outlier_hi                        NUMERIC(38,10)                  ENCODE az64,
      num_cnt_outlier                   INTEGER                         ENCODE az64,
      num_pct_outlier                   NUMERIC(38,10)                  ENCODE az64,
      num_histogram                     SUPER                           ENCODE zstd,
      -- varchar/text stats
      vc_cnt_placeholders               INTEGER                         ENCODE az64,
      vc_pct_placeholders               NUMERIC(38,10)                  ENCODE az64,
      vc_min_length                     INTEGER                         ENCODE az64,
      vc_max_length                     INTEGER                         ENCODE az64,
      vc_avg_length                     INTEGER                         ENCODE az64,
      vc_cnt_leading_ws                 INTEGER                         ENCODE az64,
      vc_pct_leading_ws                 NUMERIC(38,10)                  ENCODE az64,
      vc_cnt_trailing_ws                INTEGER                         ENCODE az64,
      vc_pct_trailing_ws                NUMERIC(38,10)                  ENCODE az64,
      vc_cnt_empty_after_trim           INTEGER                         ENCODE az64,
      vc_pct_empty_after_trim           NUMERIC(25,2)                   ENCODE az64,
      vc_cnt_lower                      INTEGER                         ENCODE az64,
      vc_pct_lower                      NUMERIC(38,10)                  ENCODE az64,
      vc_cnt_upper                      INTEGER                         ENCODE az64,
      vc_pct_upper                      NUMERIC(38,10)                  ENCODE az64,
      vc_cnt_mixed                      INTEGER                         ENCODE az64,
      vc_pct_mixed                      NUMERIC(38,10)                  ENCODE az64,
      vc_cnt_cast_int                   INTEGER                         ENCODE az64,
      vc_pct_cast_int                   NUMERIC(38,10)                  ENCODE az64,
      vc_cnt_cast_decimal               INTEGER                         ENCODE az64,
      vc_pct_cast_decimal               NUMERIC(38,10)                  ENCODE az64,
      vc_cnt_cast_date                  INTEGER                         ENCODE az64,
      vc_pct_cast_date                  NUMERIC(38,10)                  ENCODE az64,
      vc_cnt_cast_ts                    INTEGER                         ENCODE az64,
      vc_pct_cast_ts                    NUMERIC(38,10)                  ENCODE az64,
      vc_top3_pct                       SUPER                           ENCODE zstd,
      vc_shannon_entropy                NUMERIC(38,10)                  ENCODE az64,
      vc_normalized_shannon_entropy     NUMERIC(38,10)                  ENCODE az64,
      -- date/time stats
      dt_cnt_placeholders               INTEGER                         ENCODE az64,
      dt_pct_placeholders               NUMERIC(38,10)                  ENCODE az64,
      dt_min                            VARCHAR(20)                     ENCODE lzo,
      dt_max                            VARCHAR(20)                     ENCODE lzo,
      -- meta
      remarks                           VARCHAR(256)                    ENCODE lzo,
      loaddate                          TIMESTAMP WITHOUT TIME ZONE     ENCODE az64 NOT NULL
  )
  DISTSTYLE ALL;

  

  ALTER TABLE {{ profiles_db }}.{{ profiles_schema }}.{{ profiles_table }}
    ADD CONSTRAINT  {{ profiles_table }}_pk PRIMARY KEY (profile_column_id);

  {% endset %}

  {{ run_query(create_table_sql) }}
  {{ log('Table created: ' ~ profiles_db ~ '.' ~ profiles_schema ~ '.' ~ profiles_table, info=True) }}



{% else %}
  {{ log('Table already exists: ' ~ profiles_db ~ '.' ~ profiles_schema ~ '.' ~ profiles_table, info=True) }}
{% endif %}

{% endmacro %}


{% macro profiling_table_template () %}

SELECT 
      null::VARCHAR(32)                  AS profile_column_id,
      null::VARCHAR(5000)                   AS profile_name,
      null::VARCHAR(4000)                   AS profile_limited_to_where_clause,
      null::INTEGER                   AS profile_limited_to_rows,
      null::VARCHAR(128)                    AS database_name,
      null::VARCHAR(128)                    AS schema_name,
      null::VARCHAR(128)                    AS table_name,
      null::VARCHAR(128)                    AS column_name,
      null::INTEGER                    AS ordinal_position,
      null::VARCHAR(128)                    AS data_type,
      null::VARCHAR(25)                    AS length_or_precision,
      null::VARCHAR(128)                    AS is_nullable,
      null::VARCHAR(4000)                    AS column_default,
      null::VARCHAR(10)                    AS data_type_category,
      null::INTEGER                    AS total_rows,
      null::INTEGER                    AS cnt_nulls,
      null::NUMERIC(38,10)                    AS pct_nulls,
      null::INTEGER                    AS cnt_uniqs,
      null::NUMERIC(38,10)                    AS pct_uniqs,
      null::INTEGER                    AS num_cnt_placeholders,
      null::NUMERIC(38,10)                    AS num_pct_placeholders,
      null::NUMERIC(38,10)                    AS num_min,
      null::NUMERIC(38,10)                    AS num_max,
      null::NUMERIC(38,10)                    AS num_mean,
      null::NUMERIC(38,10)                    AS num_sd_pop,
      null::INTEGER                    AS num_cnt_neg,
      null::NUMERIC(38,10)                    AS num_pct_neg,
      null::INTEGER                    AS num_cnt_zero,
      null::NUMERIC(38,10)                    AS num_pct_zero,
      null::INTEGER                    AS num_cnt_pos,
      null::NUMERIC(38,10)                    AS num_pct_pos,
      null::INTEGER                    AS num_cnt_int,
      null::NUMERIC(38,10)                    AS num_pct_int,      
      -- additional numeric distribution stats
      null::NUMERIC(38,10)                    AS num_sd_samp,
      null::NUMERIC(38,10)                    AS num_q1,
      null::NUMERIC(38,10)                    AS num_q3,
      null::NUMERIC(38,10)                    AS skewness,
      null::NUMERIC(38,10)                    AS excess_kurtosis,
      null::VARCHAR(10)                    AS outlier_method,
      null::NUMERIC(38,10)                    AS outlier_lo,
      null::NUMERIC(38,10)                    AS outlier_hi,
      null::INTEGER                    AS num_cnt_outlier,
      null::NUMERIC(38,10)                    AS num_pct_outlier,
      null::SUPER                      AS num_histogram,
      -- varchar/text stats
      null::INTEGER                    AS vc_cnt_placeholders,
      null::NUMERIC(38,10)                    AS vc_pct_placeholders,
      null::INTEGER                    AS vc_min_length,
      null::INTEGER                    AS vc_max_length,
      null::INTEGER                    AS vc_avg_length,
      null::INTEGER                    AS vc_cnt_leading_ws,
      null::NUMERIC(38,10)                    AS vc_pct_leading_ws,
      null::INTEGER                    AS vc_cnt_trailing_ws,
      null::NUMERIC(38,10)                    AS vc_pct_trailing_ws,
      null::INTEGER                    AS vc_cnt_empty_after_trim,
      null::NUMERIC(25,2)                    AS vc_pct_empty_after_trim,
      null::INTEGER                    AS vc_cnt_lower,
      null::NUMERIC(38,10)                    AS vc_pct_lower,
      null::INTEGER                    AS vc_cnt_upper,
      null::NUMERIC(38,10)                    AS vc_pct_upper,
      null::INTEGER                    AS vc_cnt_mixed,
      null::NUMERIC(38,10)                    AS vc_pct_mixed,
      null::INTEGER                    AS vc_cnt_cast_int,
      null::NUMERIC(38,10)                    AS vc_pct_cast_int,
      null::INTEGER                    AS vc_cnt_cast_decimal,
      null::NUMERIC(38,10)                    AS vc_pct_cast_decimal,
      null::INTEGER                    AS vc_cnt_cast_date,
      null::NUMERIC(38,10)                    AS vc_pct_cast_date,
      null::INTEGER                    AS vc_cnt_cast_ts,
      null::NUMERIC(38,10)                    AS vc_pct_cast_ts,
      null::SUPER                    AS vc_top3_pct,
      null::NUMERIC(38,10)                    AS vc_shannon_entropy,
      null::NUMERIC(38,10)                    AS vc_normalized_shannon_entropy,
      -- date/time stats
      null::INTEGER                    AS dt_cnt_placeholders,
      null::NUMERIC(38,10)                    AS dt_pct_placeholders,
      null::VARCHAR(20)                    AS dt_min,
      null::VARCHAR(20)                    AS dt_max,
      -- meta
      null::VARCHAR(256)                    AS remarks,
      null::TIMESTAMP WITHOUT TIME ZONE                    AS loaddate


{% endmacro %}