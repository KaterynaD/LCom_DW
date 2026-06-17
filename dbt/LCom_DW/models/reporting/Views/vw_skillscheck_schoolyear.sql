{{ config(
    materialized='view',
    bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
) }}

select
    sc.schoolyear,
    sc.schoolyear_startdate,
    sc.country_code,
    sc.state_province_key,
    sd.lcom_state_province_name as state_province_name,
    sd.sfdc_state_program_eligible as state_program_eligible,
    sd.sfdc_state_initiative as state_initiative,
    sc.organization_district_id,
    sd.lcom_district_name as district_name,
    sd.lcom_demo as is_demo_district,
    sd.lcom_trial as is_trial_district,
    sc.organization_school_id,
    sch.lcom_school_name as school_name,
    sc.user_account_id,
    sc.user_grade_level_code,
    sc.assessment_set_id,
    aset.assessment_set_name,
    sc.level,
    sc.skill,
    sc.took_both,
    sc.pre_learning_object_id,
    pre_lo.learning_object_name as pre_learning_object_name,
    sc.pre_score_datetime,
    sc.pre_time_spent_seconds,
    sc.pre_time_spent_seconds_capped,
    sc.pre_score,
    sc.pre_possible_score,
    sc.pre_pct_score,
    sc.pre_performance_bucket,
    sc.post_learning_object_id,
    post_lo.learning_object_name as post_learning_object_name,
    sc.post_score_datetime,
    sc.post_time_spent_seconds,
    sc.post_time_spent_seconds_capped,
    sc.post_score,
    sc.post_possible_score,
    sc.post_pct_score,
    sc.post_performance_bucket,
    sc.score_change,
    sc.pct_score_change,
    sc.pct_growth,
    sc.unique_items_completed_before,
    sc.unique_items_completed_between
from {{ ref("fact_skillscheck_schoolyear_snapshots") }} as sc
inner join {{ ref("dim_calendar") }} as cal
    on sc.schoolyear_startdate = cal.cal_date
inner join {{ ref("dim_district") }} as sd
    on sc.organization_district_id = sd.district_id
inner join {{ ref("dim_school") }} as sch
    on sc.organization_school_id = sch.school_id
inner join {{ source("dbo","learning_assessment_set") }} as aset
    on sc.assessment_set_id = aset.assessment_set_id
inner join {{ ref("dim_learning_object") }} as pre_lo
    on sc.pre_learning_object_id = pre_lo.learning_object_id
inner join {{ ref("dim_learning_object") }} as post_lo
    on sc.post_learning_object_id = post_lo.learning_object_id
