{{
    config(

        materialized='incremental',
        unique_key='mon_year',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns',
        dist='organization_district_id',
        sort='mon_year'
        
        )
}}

with dim_month as 
(select  
c.mon_year, 
c.mon_firstday, 
c.mon_lastday, 
c.schoolyear, 
c.schoolyear_mon, 
c.schoolyear_startdate, 
c.schoolyear_enddate 
from {{ ref("dim_month") }} c 
where  mon_year<=TO_CHAR(GETDATE(), 'YYYYMM')::int
and {{ month_range_to_load() }}
)
select
dm.schoolyear :: VARCHAR(10),
dm.schoolyear_mon :: INTEGER,
dm.mon_year :: INTEGER,
dm.mon_lastday :: DATE,
isnull(dad.account_id,'{{ var("default_ID") }}') :: VARCHAR(300) as organization_district_id,
coalesce(das.account_id,dad.account_id,'{{ var("default_ID") }}'):: VARCHAR(300) as organization_school_id ,
isnull(e.user_grade_level_code,'{{ var("default_varchar") }}') :: VARCHAR(10) as user_grade_level_code,
count(distinct e.user_account_id) :: INTEGER enrollment,
'{{ var("loaddate") }}'::timestamp as loaddate
from {{ source("dbo","school_enrollment") }}  e
join dim_month dm
on dm.mon_lastday between e.enrollment_start_date and isnull(e.enrollment_end_date,'3000-12-31')
left outer join {{ ref("dim_account") }} dad
on e.organization_district_id = dad.account_id
left outer join {{ ref("dim_account") }} das
on e.organization_school_id = das.account_id
group by
dm.schoolyear,
dm.schoolyear_mon,
dm.mon_year,
dm.mon_lastday,
isnull(dad.account_id,'{{ var("default_ID") }}'),
coalesce(das.account_id,dad.account_id,'{{ var("default_ID") }}'),
isnull(e.user_grade_level_code,'{{ var("default_varchar") }}')