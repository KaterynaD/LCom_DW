{{ config(
    materialized = 'view',
    bind = false
) }}

with data as (
select
u.mon_year
,u.mon_lastday
,u.schoolyear
,u.schoolyear_mon
,u.country
,u.state_province_code
,u.organization_district_id
,u.organization_school_id
,u.grade_level
,u.topic
--
,u.school_cnt_students
,u.school_students_launches
,u.district_cnt_students
,u.district_students_launches
,u.state_cnt_students
,u.state_students_launches
,u.country_cnt_students
,u.country_students_launches
,u.company_cnt_students
,u.company_students_launches
--
,c.school_cnt_completions
,c.school_cnt_events
,c.school_cnt_student_completions
,c.school_cnt_student_completions_cipa_digital_citizenship
,c.school_cnt_student_completions_cipa_cyberbullying
,c.school_cnt_student_completionsmeets_both_cipa
,c.district_cnt_completions
,c.district_cnt_events
,c.district_cnt_student_completions
,c.district_cnt_student_completions_cipa_digital_citizenship
,c.district_cnt_student_completions_cipa_cyberbullying
,c.district_cnt_student_completionsmeets_both_cipa
,c.state_cnt_completions
,c.state_cnt_events
,c.state_cnt_student_completions
,c.state_cnt_student_completions_cipa_digital_citizenship
,c.state_cnt_student_completions_cipa_cyberbullying
,c.state_cnt_student_completionsmeets_both_cipa
,c.country_cnt_completions
,c.country_cnt_events
,c.country_cnt_student_completions
,c.country_cnt_student_completions_cipa_digital_citizenship
,c.country_cnt_student_completions_cipa_cyberbullying
,c.country_cnt_student_completionsmeets_both_cipa
,c.company_cnt_completions
,c.company_cnt_events
,c.company_cnt_student_completions
,c.company_cnt_student_completions_cipa_digital_citizenship
,c.company_cnt_student_completions_cipa_cyberbullying
,c.company_cnt_student_completionsmeets_both_cipa
--
from {{ ref("fact_students_usage_monthly_snapshots") }} u
left outer join {{ ref("fact_students_completions_monthly_snapshots") }} c
on u.mon_year = c.mon_year
and u.topic = c.topic
and u.organization_school_id = c.organization_school_id
and u.grade_level = c.grade_level
where u.product_category = '(All)'
)
select *
from data
