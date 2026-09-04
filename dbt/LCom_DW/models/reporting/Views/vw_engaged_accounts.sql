{{ config(materialized='view', bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]) }}


with dim_month as --Thread to calculate monthly metrics
(select substring(c.mon_year,5,2)::int mon, c.mon_year, c.mon_firstday, c.mon_lastday, c.FiscalYear, c.SchoolYear, c.FiscalYear_startdate, c.FiscalYear_enddate , c.FiscalYear_mon, c.SchoolYear_mon
from {{ ref("dim_month") }} c
where mon_year between 202207 and to_char(GetDate(),'yyyymm')
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
a.name as current_name,
a.conformed_district_id as current_conformed_district_id,
a.district_name as current_district_name,
a.owner_id as current_owner_id,
a.owner as current_owner,
a.conformed_customer_id as current_conformed_customer_id,
a.customer_name as current_customer_name,
a.country as current_country,
a.state_code as current_state,
a.county as current_county,
a.enrollment as current_enrollment,
a.state_initiative as current_state_initiative,
a.account_type current_account_type,
--
a.lcom_organization_id as current_lcom_organization_id ,
a.lcom_parent_organization_id as current_lcom_parent_organization_id ,
--
a.sfdc_parent_id as current_sfdc_parent_id,
a.sfdc_ultimate_parent_id as current_sfdc_ultimate_parent_id,
--
a.sfdc_name as current_sfdc_name,
a.lcom_organization_name as current_lcom_organization_name ,
--
a.sfdc_customer_level as current_customer_level,
a.sfdc_urban_rural as current_urban_rural,
--
a.LCOM_organization_type current_lcom_organization_type,
--
la.total_won_opportunities, 
la.total_open_opportunities, 
la.latest_start_date, 
la.latest_end_date, 
la.latest_open_opportunities_modified_date, 
la.first_invoiced_date, 
la.total_training_sessions, 
la.latest_training_session_on, 
la.total_cases, 
la.currently_open_cases, 
la.latest_case_created_date, 
la.latest_open_case_modified_date
--
from dim_month m
join {{ ref("dim_account_history") }} ah
on m.mon_lastday between ah.fromdate and ah.todate
join {{ ref('dim_account_metrics')}} la
on la.account_id=ah.account_id
join {{ ref("dim_account") }}  a
on a.account_id = ah.account_id
where a.lcom_trial=false
and a.lcom_demo=false
and (la.has_product_usage or la.has_product_licenses or la.total_won_opportunities>0)
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
current_conformed_district_id,
current_district_name,
--
current_owner_id,
case when current_owner ilike '%integration%' or current_owner='{{ var("default_varchar") }}' then '(Not Set)'  else current_owner end current_owner,
current_conformed_customer_id,
case when current_conformed_customer_id=current_conformed_district_id then '(Districts)' else current_customer_name end as current_customer_name,
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
current_enrollment ,
current_account_type ,
current_customer_level,
current_urban_rural ,
current_lcom_organization_type,
--
total_won_opportunities, 
total_open_opportunities, 
latest_start_date, 
latest_end_date, 
latest_open_opportunities_modified_date, 
first_invoiced_date, 
total_training_sessions, 
latest_training_session_on, 
total_cases, 
currently_open_cases, 
latest_case_created_date, 
latest_open_case_modified_date
--
from data

