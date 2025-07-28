{{ config(
        
        materialized='incremental',
        unique_key=['snp_mon_year','snp_type'],
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns',
        dist='snp_mon_year',
        sort='snp_mon_year'
)
 }}

select
to_char(GetDate(), 'yyyymm')::integer snp_mon_year,
'Scheduled Monthly Snapshot'::varchar(100) as snp_type,
mon_lastday::date,
mon::integer,
schoolyear::varchar(20),
schoolyear_mon::integer,
Country::varchar(70),
State::varchar(20),
state_initiative::boolean,
state_program_eligible::boolean,
DistrictOwner::varchar(380),
DistrictEnrollment::double precision,
DistrictName::varchar(270),
SFDC_DistrictName::varchar(780),
organization_district_id::varchar(300),
Licenses_Provisioned_District::integer,
Number_Of_Students::integer,
active_students_YTD::integer,
launches_YTD::integer,
'{{ var("loaddate") }}'::timestamp as loaddate
from {{ ref("get_monthly_snapshot_data_district_level") }}