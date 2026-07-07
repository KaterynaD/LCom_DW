{{ config(
    materialized='view',
    bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
) }}

select
    cal.schoolyear,
    org.lcom_country_code as country_code,
    org.lcom_state_province_key as state_province_key,
    org.lcom_state_province_name as state_province_name,
    org.sfdc_state_program_eligible as state_program_eligible,
    org.sfdc_state_initiative as state_initiative,
    org.lcom_district_id as district_id,
    coalesce(nullif(org.sfdc_district_name, 'Unknown'), org.lcom_district_name) as district_name,
    org.lcom_demo as is_demo_district,
    org.lcom_trial as is_trial_district,
    sch.lcom_school_id as school_id,
    coalesce(nullif(sch.sfdc_school_name, 'Unknown'), sch.lcom_school_name) as school_name,
    fal.user_primary_teacher_id as teacher_id,
    coalesce(tch.first_name + ' ' + tch.last_name, lp.learning_pathway_name) as teacher_name,
    tch.email as teacher_email,
    case when fal.learning_pathway_id <> '00000000-0000-0000-0000-000000000000' then 'Pathway' else 'Teacher-Assigned' end as launched_from,
    max(cal.cal_date) as last_launch_date,
    count(distinct fal.assignment_launch_id) as num_launches,
    count(distinct fal.user_account_id) as num_users
from {{ source("dbo","fact_assignment_launch") }}  as fal
inner join {{ ref("dim_district") }} as org
    on fal.organization_district_id = org.lcom_district_id
inner join {{ ref("dim_school") }} as sch
    on
        fal.organization_school_id = sch.lcom_school_id
        and fal.organization_district_id = sch.lcom_district_id
inner join {{ ref("dim_calendar") }} as cal
    on cast(fal.launch_datetime as DATE) = cal.cal_date
left join {{ source("dbo","mv_teacher_account") }} as tch
    on
        fal.user_primary_teacher_id = tch.user_account_id 
        and fal.organization_district_id = tch.organization_district_id
left join {{ source("dbo","learning_pathway") }} as lp
    on fal.learning_pathway_id = lp.learning_pathway_id
where current_date between cal.schoolyear_startdate and dateadd(year, 1, cal.schoolyear_enddate)
group by
    cal.schoolyear, org.lcom_country_code, org.lcom_state_province_key, org.lcom_state_province_name, org.sfdc_state_program_eligible, org.sfdc_state_initiative,
    org.lcom_district_id, org.sfdc_district_name, org.lcom_district_name, org.lcom_demo, org.lcom_trial,
    sch.lcom_school_id, sch.sfdc_school_name, sch.lcom_school_name,
    fal.user_primary_teacher_id, coalesce(tch.first_name + ' ' + tch.last_name, lp.learning_pathway_name), tch.email,
    case when fal.learning_pathway_id <> '00000000-0000-0000-0000-000000000000' then 'Pathway' else 'Teacher-Assigned' end
having coalesce(nullif(sch.sfdc_school_name, 'Unknown'), sch.lcom_school_name) <> 'Unknown'
