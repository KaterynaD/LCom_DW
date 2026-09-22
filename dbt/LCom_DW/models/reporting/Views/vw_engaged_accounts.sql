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
ah.account_id,
ah.sfdc_account_id as historical_sfdc_account_id,
ah.conformed_district_id as historical_conformed_district_id,
ah.conformed_district_sfdc_account_id as historical_conformed_district_sfdc_account_id,
ah.conformed_customer_id as historical_conformed_customer_id,
ah.conformed_customer_sfdc_account_id as historical_conformed_customer_sfdc_account_id,
--
ah.name as historical_name,
ah.district_name as historical_district_name,
ah.customer_name as historical_customer_name,
ah.country as historical_country,
ah.state_code as historical_state_code,
ah.state_name as historical_state_name,
ah.county as historical_county,
ah.state_initiative as historical_state_initiative,
ah.owner as historical_owner,
ah.enrollment as historical_enrollment,
ah.urban_rural as historical_urban_rural,
ah.account_type as historical_account_type,
ah.customer_level as historical_customer_level,
--
--
a.sfdc_account_id,
a.conformed_district_id,
a.conformed_district_sfdc_account_id,
a.conformed_customer_id,
a.conformed_customer_sfdc_account_id,
--
a.name,
a.district_name,
a.customer_name ,
a.country,
a.state_code ,
a.state_name,
a.county,
a.state_initiative,
a.owner,
a.enrollment,
a.urban_rural,
a.account_type,
a.customer_level,
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
la.latest_open_case_modified_date,
--
la.has_product_usage,
la.has_product_licenses
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
mon,
data.mon_year,
mon_lastday ,
FiscalYear,
FiscalYear_mon,
SchoolYear,
SchoolYear_mon,
--
account_id,
historical_sfdc_account_id,
historical_conformed_district_id,
historical_conformed_district_sfdc_account_id,
historical_conformed_customer_id,
historical_conformed_customer_sfdc_account_id,
historical_name,
historical_district_name,
historical_customer_name,
case when historical_conformed_customer_id=historical_conformed_district_id then '(Districts)' else historical_customer_name end as display_historical_customer_name,
historical_country,
historical_state_code,
historical_state_name,
historical_county,
historical_state_initiative,
historical_owner,
case when historical_owner ilike '%integration%' or historical_owner ilike '%salesforce%' or historical_owner='{{ var("default_varchar") }}' then '(Not Set)'  else historical_owner end display_historical_owner,
historical_enrollment,
historical_urban_rural,
historical_account_type,
historical_customer_level,
--
--
sfdc_account_id,
conformed_district_id,
conformed_district_sfdc_account_id,
data.conformed_customer_id,
conformed_customer_sfdc_account_id,
--
name,
district_name,
data.customer_name ,
case when conformed_customer_id=conformed_district_id then  data.customer_name else '(Districts)' end as display_customer_name,
country,
state_code ,
state_name,
county,
state_initiative,
owner,
case when owner ilike '%integration%' or owner ilike '%salesforce%' or owner='{{ var("default_varchar") }}' then '(Not Set)'  else owner end display_owner,
enrollment,
urban_rural,
account_type,
customer_level,
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
latest_open_case_modified_date,
--
--
has_product_usage,
has_product_licenses
from data


