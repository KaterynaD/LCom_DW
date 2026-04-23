
{{ config(
    materialized='incremental',
    unique_key=['schoolyear', 'organization_district_id', 'user_account_id', 'assessment_set_id'],
    incremental_strategy='merge',
    on_schema_change='fail'
) }}

with source as (
    select *
    from {{ ref('stg_skillscheck_schoolyear_data') }}
),
changed as (
    select
        s.schoolyear,
        s.country_code,
        coalesce(s.state_province_key, '') as state_province_key,
        s.organization_district_id,
        coalesce(s.organization_school_id, '{{ var("default_ID") }}') as organization_school_id,
        s.user_account_id,
        coalesce(s.user_grade_level_code, '') as user_grade_level_code,
        s.assessment_set_id,
        s.level,
        s.skill,
        s.took_both,
        coalesce(s.pre_learning_object_id, '{{ var("default_ID") }}') as pre_learning_object_id,
        coalesce(s.pre_score_datetime, '{{ var("default_date") }}') as pre_score_datetime,
        coalesce(s.pre_time_spent_seconds, '{{ var("default_numeric") }}') as pre_time_spent_seconds,
        coalesce(s.pre_time_spent_seconds_capped, '{{ var("default_numeric") }}') as pre_time_spent_seconds_capped,
        coalesce(s.pre_score, '{{ var("default_numeric") }}') as pre_score,
        coalesce(s.pre_possible_score, '{{ var("default_numeric") }}') as pre_possible_score,
        coalesce(s.pre_pct_score, '{{ var("default_numeric") }}') as pre_pct_score,
        coalesce(s.pre_performance_bucket, '{{ var("default_varchar") }}') as pre_performance_bucket,
        coalesce(s.post_learning_object_id, '{{ var("default_ID") }}') as post_learning_object_id,
        coalesce(s.post_score_datetime, '{{ var("default_date") }}') as post_score_datetime,
        coalesce(s.post_time_spent_seconds, '{{ var("default_numeric") }}') as post_time_spent_seconds,
        coalesce(s.post_time_spent_seconds_capped, '{{ var("default_numeric") }}') as post_time_spent_seconds_capped,
        coalesce(s.post_score, '{{ var("default_numeric") }}') as post_score,
        coalesce(s.post_possible_score, '{{ var("default_numeric") }}') as post_possible_score,
        coalesce(s.post_pct_score, '{{ var("default_numeric") }}') as post_pct_score,
        coalesce(s.post_performance_bucket, '{{ var("default_varchar") }}') as post_performance_bucket,
        coalesce(s.score_change, '{{ var("default_numeric") }}') as score_change,
        coalesce(s.pct_score_change, '{{ var("default_numeric") }}') as pct_score_change,
        coalesce(s.pct_growth, '{{ var("default_numeric") }}') as pct_growth,
        coalesce(s.unique_items_completed_before, '{{ var("default_numeric") }}') as unique_items_completed_before,
        coalesce(s.unique_items_completed_between, '{{ var("default_numeric") }}') as unique_items_completed_between
    from source s
    {% if is_incremental() %}
    left join {{ this }} t
      on s.schoolyear = t.schoolyear
     and s.organization_district_id = t.organization_district_id
     and s.user_account_id = t.user_account_id
     and s.assessment_set_id = t.assessment_set_id
   where t.user_account_id is null 
      or coalesce(s.pre_score_datetime, '{{ var("default_date")}}') <> coalesce(t.pre_score_datetime, '{{ var("default_date")}}')
      or coalesce(s.post_score_datetime, '{{ var("default_date")}}') > coalesce(t.post_score_datetime, '{{ var("default_date")}}')
    {% endif %}
)
select schoolyear::VARCHAR(20),
       country_code::CHARACTER(2),
       state_province_key::VARCHAR(6),
       organization_district_id::VARCHAR(255),
       organization_school_id::VARCHAR(255),
       user_account_id::VARCHAR(255),
       user_grade_level_code::CHARACTER(2),
       assessment_set_id::INTEGER,
       level::VARCHAR(10),
       skill::VARCHAR(100),
       took_both::BOOLEAN,
       pre_learning_object_id::VARCHAR(50),
       pre_score_datetime::TIMESTAMPTZ,
       pre_time_spent_seconds::INTEGER,
       pre_time_spent_seconds_capped::INTEGER,
       pre_score::INTEGER,
       pre_possible_score::INTEGER,
       pre_pct_score::NUMERIC(8,6),
       pre_performance_bucket::VARCHAR(10),
       post_learning_object_id::VARCHAR(50),
       post_score_datetime::TIMESTAMPTZ,
       post_time_spent_seconds::INTEGER,
       post_time_spent_seconds_capped::INTEGER,
       post_score::INTEGER,
       post_possible_score::INTEGER,
       post_pct_score::NUMERIC(8,6),
       post_performance_bucket::VARCHAR(10),
       score_change::INTEGER,
       pct_score_change::NUMERIC(8,6),
       pct_growth::NUMERIC(8,6),
       unique_items_completed_before::INTEGER,
       unique_items_completed_between::INTEGER,
       '{{ var("loaddate") }}'::TIMESTAMP as loaddate
from changed