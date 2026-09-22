{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}


 with
dim_date as (
select distinct SchoolYear, SchoolYear_StartDate, SchoolYear_EndDate, SchoolYear_Mon, Mon_FirstDay, Mon_LastDay,Mon_Year
from {{ ref("dim_calendar") }}
where trunc(GetDate())between Mon_FirstDay and Mon_LastDay
)
,dim_date_prev as (
select distinct SchoolYear, SchoolYear_StartDate, SchoolYear_EndDate
from {{ ref("dim_calendar") }}
where SchoolYear_StartDate =  (select  max(SchoolYear_StartDate)  from {{ ref("dim_calendar") }} where SchoolYear_StartDate<(select SchoolYear_StartDate from {{ ref("dim_calendar") }} where cal_date=trunc(GetDate())))
)
, vw_usage_scorecard_school as 
(select
dt.SchoolYear,
case
when fal.organization_school_id='00000000-0000-0000-0000-000000000000' then
fal.organization_district_id
when len(fal.organization_school_id)<2 then
fal.organization_district_id
else
isnull(fal.organization_school_id,fal.organization_district_id)
end organization_school_id,
count(distinct fal.user_account_id) as unique_students,
count(distinct fal.assignment_launch_id) as unique_students_launches,
max(TIMEZONE('UTC', fal.launch_datetime)) latest_launch
FROM {{ source("dbo","fact_assignment_launch") }} fal
join {{ source("dbo","organization") }} o
on fal.organization_district_id=o.organization_id
join {{ source("dbo","mv_student_account") }} ua
on fal.user_account_id = ua.user_account_id
and fal.organization_district_id=ua.organization_district_id
join dim_date dt
on TIMEZONE('UTC', fal.launch_datetime) BETWEEN dt.SchoolYear_StartDate AND TIMEZONE('UTC', GetDate())
where o.is_demo=false
and o.is_trial=false
group by all
)
,vw_usage_scorecard as
(
select
SchoolYear,
sum(unique_students) as unique_students,
sum(unique_students_launches) as unique_students_launches,
max(latest_launch) as latest_launch
from vw_usage_scorecard_school
group by SchoolYear  
)
, vw_usage_scorecard_prev as 
(
select distinct
fsums.schoolyear, 
sum(school_cnt_students)  as unique_students,
sum(fsums.school_students_launches) as unique_students_launches,
max(dt.SchoolYear_EndDate) as latest_launch
from {{ ref("fact_students_usage_monthly_snapshots") }} fsums 
join dim_date_prev dt
on dt.schoolyear = fsums.schoolyear
and mon_year =  to_char(dt.SchoolYear_EndDate,'yyyymm')::int
where topic='(All)'
and grade_level='All Students'
and product_category ='(All)'
group by fsums.schoolyear
)
select 
'Actual' category,
unique_students,
unique_students_launches,
schoolyear,
latest_launch as last_updated
FROM vw_usage_scorecard
union all
select 
'Previous' category,
unique_students,
unique_students_launches,
schoolyear,
latest_launch as last_updated
FROM vw_usage_scorecard_prev
union all
select 
'Target' category,
2000000 unique_students,
0 unique_students_launches,
'N/A' schoolyear,
cast('1900-01-01' as date) latest_launch

