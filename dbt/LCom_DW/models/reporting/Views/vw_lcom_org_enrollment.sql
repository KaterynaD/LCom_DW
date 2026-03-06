{{ config(materialized='view', bind=False) }}

select 
schoolyear, 
schoolyear_mon, 
mon_year, 
mon_lastday,  
organization_district_id, 
organization_school_id, 
user_grade_level_code,
enrollment
from {{ ref("fact_enrollment_monthly_snapshots") }} fems