
{{ config(
    materialized='incremental',
    unique_key=['schoolyear', 'organization_district_id', 'user_account_id', 'assessment_set_id'],
    incremental_strategy='merge'
) }}

with source as (
    select *
    from {{ ref('stg_skillscheck_schoolyear_data') }}
),
changed as (
    select
        s.schoolyear,
        s.country_code,
        s.state_province_key,
        s.organization_district_id,
        s.organization_school_id,
        s.user_account_id,
        s.user_grade_level_code,
        s.assessment_set_id,
        s.level,
        s.skill,
        s.took_both,
        s.pre_learning_object_id,
        s.pre_score_datetime,
        s.pre_time_spent_seconds,
        s.pre_time_spent_seconds_capped,
        s.pre_score,
        s.pre_possible_score,
        s.pre_pct_score,
        s.pre_performance_bucket,
        s.post_learning_object_id,
        s.post_score_datetime,
        s.post_time_spent_seconds,
        s.post_time_spent_seconds_capped,
        s.post_score,
        s.post_possible_score,
        s.post_pct_score,
        s.post_performance_bucket,
        s.score_change,
        s.pct_score_change,
        s.pct_growth,
        s.unique_items_completed_before,
        s.unique_items_completed_between
    from source s
    {% if is_incremental() %}
    left join {{ this }} t
      on s.schoolyear = t.schoolyear
     and s.organization_district_id = t.organization_district_id
     and s.user_account_id = t.user_account_id
     and s.assessment_set_id = t.assessment_set_id
    {% endif %}
    where 
      {% if is_incremental() %}
      t.user_account_id is null 
      or coalesce(s.pre_score_datetime, '{{ var("default_date")}}') <> coalesce(t.pre_score_datetime, '{{ var("default_date")}}')
      or coalesce(s.post_score_datetime, '{{ var("default_date")}}') > coalesce(t.post_score_datetime, '{{ var("default_date")}}')
      {% else %}
      1=1
      {% endif %}
)
select * from changed