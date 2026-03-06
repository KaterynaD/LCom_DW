{{ config(materialized='view', bind=False) }}


with dim_month as --Thread to calculate monthly metrics
(select substring(c.mon_year,5,2)::int mon, c.mon_year, c.mon_firstday, c.mon_lastday, c.FiscalYear, c.SchoolYear, c.FiscalYear_startdate, c.FiscalYear_enddate , c.FiscalYear_mon, c.SchoolYear_mon
from {{ ref("dim_month") }} c
where mon_year between 202207 and to_char(GetDate(),'yyyymm')
)
,alive_accounts as (
select distinct account_id from {{ ref("fact_opportunity") }} 
union
select distinct organization_district_id from {{ ref("vw_fact_license_order") }}
union
select distinct organization_school_id from {{ ref("dim_license_order_school") }}
union
select distinct organization_school_id from {{ ref("fact_students_usage_monthly_snapshots") }} 
)
--
,data as (
select
m.mon,
m.mon_year,
m.mon_lastday ,
m.FiscalYear,
m.FiscalYear_mon,
m.SchoolYear,
m.SchoolYear_mon,
--
ah.lcom_organization_id as lcom_organization_id ,
a.lcom_parent_organization_id as lcom_parent_organization_id ,
--
ah.sfdc_parent_id,
ah.sfdc_ultimate_parent_id,
--
ah.account_id,
ah.sfdc_account_id,
ah.sfdc_name,
ah.lcom_organization_name,
case
when ah.sfdc_name = 'Unknown'
then ah.lcom_organization_name
else ah.sfdc_name
end as name,
case when (ah.sfdc_state_initiative or ah.sfdc_state_initiative_school) then true else false end as state_initiative,
case
when ah.sfdc_billing_country = 'Unknown'
then ah.lcom_country_name
else ah.sfdc_billing_country
end as country,
case
when ah.sfdc_billing_state_code = 'Unknown'
then ah.lcom_state_province_code
when ah.sfdc_billing_country = 'United States'
then 'United States of America'
else ah.sfdc_billing_state_code
end as state,
ah.sfdc_county_name as county,
ah.sfdc_owner_name_text as owner,
case
when ah.sfdc_record_type = 'L' then ah.sfdc_district_enrollment
else ah.sfdc_school_enrollment
end as enrollment,
case
when ah.sfdc_record_type = 'L' then 'District'
else 'School' END as account_type,
ah.sfdc_urban_rural as urban_rural,
--
ah.LCOM_organization_type lcom_organization_type,
--
a.lcom_organization_id as current_lcom_organization_id ,
a.lcom_parent_organization_id as current_lcom_parent_organization_id ,
--
a.sfdc_parent_id as current_sfdc_parent_id,
a.sfdc_ultimate_parent_id as current_sfdc_ultimate_parent_id,
--
a.sfdc_name as current_sfdc_name,
a.lcom_organization_name as current_lcom_organization_name ,
case
when a.sfdc_name = 'Unknown'
then a.lcom_organization_name
else a.sfdc_name
end as current_name,
case when (a.sfdc_state_initiative or a.sfdc_state_initiative_school) then true else false end as current_state_initiative,
case
when a.sfdc_billing_country = 'Unknown'
then a.lcom_country_name
when a.sfdc_billing_country = 'United States'
then 'United States of America'
else a.sfdc_billing_country
end as current_country,
case
when a.sfdc_billing_state_code = 'Unknown'
then a.lcom_state_province_code
else a.sfdc_billing_state_code
end as current_state,

a.sfdc_county_name as current_county,
a.sfdc_owner_name_text as current_owner,
case
when a.sfdc_record_type = 'L' then a.sfdc_district_enrollment
else a.sfdc_school_enrollment
end as current_enrollment,
case
when a.sfdc_record_type = 'L' then 'District'
else 'School' END as current_account_type,
a.sfdc_urban_rural as current_urban_rural,
--
a.LCOM_organization_type current_lcom_organization_type
--
from dim_month m
join {{ ref("dim_account_history") }} ah
on m.mon_lastday between ah.fromdate and ah.todate
join alive_accounts la
on la.account_id=ah.account_id
join {{ ref("dim_account") }}  a
on a.account_id = ah.account_id
where a.lcom_trial=false
and a.lcom_demo=false
)
select
mon ,
mon_year ,
mon_lastday ,
fiscalyear ,
fiscalyear_mon ,
schoolyear ,
schoolyear_mon ,
--
account_id ,
sfdc_account_id ,
--
lcom_organization_id ,
lcom_parent_organization_id ,
--
sfdc_parent_id,
sfdc_ultimate_parent_id,
--
sfdc_name ,
lcom_organization_name ,
name ,
state_initiative ,
country ,
state ,
county ,
owner ,
enrollment ,
account_type ,
urban_rural ,
lcom_organization_type,
--
current_lcom_organization_id ,
current_lcom_parent_organization_id ,
--
current_sfdc_parent_id,
current_sfdc_ultimate_parent_id,
--
current_sfdc_name ,
current_lcom_organization_name ,
current_name ,
current_state_initiative ,
current_country ,
current_state ,
current_county ,
current_owner ,
current_enrollment ,
current_account_type ,
current_urban_rural ,
current_lcom_organization_type
from data

