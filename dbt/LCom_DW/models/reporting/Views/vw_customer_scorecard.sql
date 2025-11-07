{{ config(materialized='view',
   bind=False
)
 }}

with dim_month as
 (
select FiscalYear, FiscalYear_StartDate, FiscalYear_EndDate, FiscalYear_Mon, Mon_FirstDay, Mon_LastDay,Mon_Year
from {{ ref("dim_month") }}
where trunc(GetDate()) between Mon_FirstDay and Mon_LastDay
)
,dim_month_prev as
 (
select FiscalYear, FiscalYear_StartDate, FiscalYear_EndDate, FiscalYear_Mon, Mon_FirstDay, Mon_LastDay,Mon_Year
from {{ ref("dim_month") }}
where date_add('year', -1, trunc(GetDate())) between Mon_FirstDay and Mon_LastDay
)
,contract_based_active_data as (
select count(distinct sfdc_ultimate_parent_id) cnt_customers
from {{ ref("fact_paying_customers") }} s
join dim_month m
on s.Mon_Year = m.Mon_Year
where record_type='Contract Active'
)
,contract_based_active_data_prev as (
select count(distinct sfdc_ultimate_parent_id) cnt_customers
from {{ ref("fact_paying_customers") }} s
join dim_month_prev m
on s.Mon_Year = m.Mon_Year
where record_type='Contract Active'
)
,net_active_data as (
select count(distinct sfdc_ultimate_parent_id) cnt_customers
from {{ ref("fact_paying_customers") }} s
join dim_month m
on s.Mon_Year = m.Mon_Year
where record_type='Net Active'
)
,net_active_data_prev as (
select count(distinct sfdc_ultimate_parent_id) cnt_customers
from {{ ref("fact_paying_customers") }} s
join dim_month_prev m
on s.Mon_Year = m.Mon_Year
where record_type='Net Active'
)
,total_active_data as (
select count(distinct sfdc_ultimate_parent_id) cnt_customers
from {{ ref("fact_paying_customers") }} s
join dim_month m
on s.Mon_Year = m.Mon_Year
where record_type='Total Active'
)
,total_active_data_prev as (
select count(distinct sfdc_ultimate_parent_id) cnt_customers
from {{ ref("fact_paying_customers") }} s
join dim_month_prev m
on s.Mon_LastDay = m.Mon_LastDay
where record_type='Total Active'
)
,datedata as ( select max(fcms.loaddate) last_updated 
from {{ ref("fact_paying_customers") }} fcms
)
,vw_customer_scorecard as (
select 
dim_month.FiscalYear,
contract_based_active_data.cnt_customers contract_based_active,
net_active_data.cnt_customers net_active, 
total_active_data.cnt_customers total_active,
datedata.last_updated
from net_active_data
join total_active_data
on 1=1
join contract_based_active_data
on 1=1
join datedata
on 1=1
join dim_month
on 1=1
)
,vw_customer_scorecard_prev as (select 
dim_month_prev.FiscalYear,
contract_based_active_data_prev.cnt_customers contract_based_active,
net_active_data_prev.cnt_customers net_active, 
total_active_data_prev.cnt_customers total_active,
Mon_LastDay last_updated
from net_active_data_prev
join total_active_data_prev
on 1=1
join contract_based_active_data_prev
on 1=1
join dim_month_prev
on 1=1
)
select 
'Actual' as category,
contract_based_active,
net_active, 
total_active,
FiscalYear,
last_updated
from vw_customer_scorecard
union all
select 
'Previous' as category,
contract_based_active,
net_active, 
total_active,
FiscalYear,
last_updated
from vw_customer_scorecard_prev
union all
select 
'Target' as category,
0 contract_based_active,
0 net_active, 
0 total_active,
'N/A' FiscalYear,
cast('1900-01-01' as date) last_updated


