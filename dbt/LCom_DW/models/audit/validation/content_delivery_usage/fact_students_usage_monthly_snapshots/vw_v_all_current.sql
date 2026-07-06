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
, vw_usage_scorecard as 
(select
dt.SchoolYear,
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
group by dt.SchoolYear
)
select schoolyear,unique_students, unique_students_launches from {{ ref("vw_usage_scorecard") }} vus 
except
select distinct schoolyear, company_cnt_students , company_students_launches 
from {{ ref("fact_students_usage_monthly_snapshots") }}
where mon_year =  to_char(TIMEZONE('UTC', GetDate()),'yyyymm')::int
and topic='(All)'
and grade_level='All Students'
and product_category ='(All)'