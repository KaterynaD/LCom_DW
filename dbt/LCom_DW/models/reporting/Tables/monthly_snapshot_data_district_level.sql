{{ config(
        
        materialized='incremental',
        unique_key='snp_mon_year',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns',
        dist='snp_mon_year',
        sort='snp_mon_year'
)
 }}

select
to_char(GetDate(), 'yyyymm')::int snp_mon_year,
mon_lastday,
mon,
schoolyear,
schoolyear_mon,
Country,
State,
state_initiative,
state_program_eligible,
DistrictOwner,
DistrictEnrollment,
DistrictName,
SFDC_DistrictName,
organization_district_id,
Licenses_Provisioned_District,
Number_Of_Students,
active_students_YTD,
launches_YTD,
'{{ var("loaddate") }}'::timestamp as loaddate
from {{ ref("get_monthly_snapshot_data_district_level") }}