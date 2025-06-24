{{ config(materialized='view',
   bind=False
)
 }}

select
     fal.schoolyear
	,fal.schoolyear_mon
	,fal.mon_year
	,fal.mon_lastday
	,fal.country
	,fal.state_province_code
	,fal.organization_district_id
	,dist.lcom_district_name	
	,dist.sfdc_district_name 
    ,dist.sfdc_district_enrollment	
	,sch.school_id organization_school_id
	,sch.lcom_school_name	
	,sch.sfdc_school_name 
	,fal.product_category
	,fal.grade_level
	,fal.topic
	,fal.school_cnt_students
	,fal.school_students_launches
	,fal.district_cnt_students
	,fal.district_students_launches
	,fal.state_cnt_students
	,fal.state_students_launches
	,fal.country_cnt_students
	,fal.country_students_launches
	,fal.company_cnt_students
	,fal.company_students_launches
from {{ ref("fact_students_usage_monthly_snapshots") }} fal
join {{ ref("dim_district") }} dist
on fal.organization_district_id=dist.district_id 
join {{ ref("dim_school") }} sch
on fal.organization_school_id=sch.school_id