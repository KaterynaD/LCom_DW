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
ah.account_id,
ah.conformed_district_id as historic_conformed_district_id,
ah.conformed_customer_id as historic_conformed_customer_id,
--
ah.name as historic_name,
ah.district_name as historic_district_name,
ah.customer_name as historic_customer_name,
ah.country as historic_country,
ah.state_code as historic_state,
ah.state_name as historic_state_name,
ah.county as historic_county,
ah.state_initiative as historic_state_initiative,
ah.owner as historic_owner,
ah.enrollment as historic_enrollment,
ah.urban_rural as historic_urban_rural,
ah.account_type as historic_account_type,
ah.customer_level as historic_customer_level,
--
--
a.conformed_district_id,
a.conformed_customer_id,
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
mon,
mon_year,
mon_lastday ,
FiscalYear,
FiscalYear_mon,
SchoolYear,
SchoolYear_mon,
--
account_id,
historic_conformed_district_id,
historic_conformed_customer_id,
--
historic_name,
historic_district_name,
historic_customer_name,
case when historic_conformed_customer_id=historic_conformed_district_id then '(Districts)' else historic_customer_name end as display_historic_customer_name,
historic_country,
historic_state,
historic_state_name,
historic_county,
historic_state_initiative,
historic_owner,
case when historic_owner ilike '%integration%' or historic_owner='{{ var("default_varchar") }}' then '(Not Set)'  else historic_owner end display_historic_owner,
historic_enrollment,
historic_urban_rural,
historic_account_type,
historic_customer_level,
--
--
conformed_district_id,
conformed_customer_id,
--
name,
district_name,
customer_name ,
case when conformed_customer_id=conformed_district_id then '(Districts)' else customer_name end as display_customer_name,
country,
state_code ,
state_name,
county,
state_initiative,
owner,
case when owner ilike '%integration%' or owner='{{ var("default_varchar") }}' then '(Not Set)'  else owner end display_owner,
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
latest_open_case_modified_date
--
from data

