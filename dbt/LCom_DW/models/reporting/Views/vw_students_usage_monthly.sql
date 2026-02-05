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
	,dist.lcom_organization_name as lcom_district_name	
	,dist.SFDC_name  sfdc_district_name 
    ,case when dist.sfdc_district_enrollment=0 then dist.sfdc_school_enrollment else dist.sfdc_district_enrollment end as district_enrollment
	,case when (dist.sfdc_state_initiative or dist.sfdc_state_initiative_school) then true else false end as state_initiative
	,dist.sfdc_urban_rural as urban_rural
	,fal.organization_school_id
	,sch.lcom_organization_name as lcom_school_name	
	,sch.SFDC_name as sfdc_school_name 
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
	--
	,fal.school_cnt_students_month
	,fal.school_students_launches_month
	,fal.district_cnt_students_month
	,fal.district_students_launches_month
	,fal.state_cnt_students_month
	,fal.state_students_launches_month
	,fal.country_cnt_students_month
	,fal.country_students_launches_month
	,fal.company_cnt_students_month
	,fal.company_students_launches_month	
from {{ ref("fact_students_usage_monthly_snapshots") }} fal
join {{ ref("dim_account_history") }} dist
on fal.organization_district_id=dist.account_id 
and fal.mon_lastday between dist.fromdate and  dist.todate
join {{ ref("dim_account_history") }} sch
on fal.organization_school_id=sch.account_id
and fal.mon_lastday between sch.fromdate and  sch.todate