{{ config(materialized='view',
   bind=False
)
 }}

with dim_month as
 (
select distinct FiscalYear, FiscalYear_StartDate, FiscalYear_EndDate, FiscalYear_Mon, Mon_FirstDay, Mon_LastDay,Mon_Year
from {{ source("common","dim_calendar") }}
where GetDate() between Mon_FirstDay and Mon_LastDay
)
,dim_month_prev as
 (
select distinct FiscalYear, FiscalYear_StartDate, FiscalYear_EndDate, FiscalYear_Mon, Mon_FirstDay, Mon_LastDay,Mon_Year
from {{ source("common","dim_calendar") }}
where date_add('year', -1, GetDate()) between Mon_FirstDay and Mon_LastDay
)
,contract_based_active_rawdata as (
select sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.Mon_LastDay = last_day(dateadd('month',1, m.Mon_LastDay))
where include_flg=true
and record_type='Starting'
)
,contract_based_active_rawdata_prev as (
select sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month_prev m
on s.Mon_LastDay = last_day(dateadd('month',1, m.Mon_LastDay))
where include_flg=true
and record_type='Starting'
)
, net_active_rawdata as (
select sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_year = to_char(m.FiscalYear_StartDate,'yyyymm') 
where include_flg=true
and record_type='Starting'
union
select sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_lastday between m.FiscalYear_StartDate and m.FiscalYear_EndDate
where include_flg=true
and record_type in ('New','Returning','Returning','ReturningFY' )
except
select sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_lastday between m.FiscalYear_StartDate and m.FiscalYear_EndDate
where include_flg=true
and record_type in ('Churn' )
except
select sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_lastday between m.FiscalYear_StartDate and m.FiscalYear_EndDate
where include_flg=true
and record_type in ('NonRenewal','Ghost' )
)
, net_active_rawdata_prev as (
select sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month_prev m
on s.mon_year = to_char(m.FiscalYear_StartDate,'yyyymm') 
where include_flg=true
and record_type='Starting'
union
select sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month_prev m
on s.mon_lastday between m.FiscalYear_StartDate and m.FiscalYear_EndDate
where include_flg=true
and record_type in ('New','Returning','Returning','ReturningFY' )
except
select sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month_prev m
on s.mon_lastday between m.FiscalYear_StartDate and m.FiscalYear_EndDate
where include_flg=true
and record_type in ('Churn' )
except
select sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month_prev m
on s.mon_lastday between m.FiscalYear_StartDate and m.FiscalYear_EndDate
where include_flg=true
and record_type in ('NonRenewal','Ghost' )
)
,total_active_rawdata as (
select sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_year = to_char(m.FiscalYear_StartDate,'yyyymm') 
where include_flg=true
and record_type='Starting'
union
select sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_lastday between m.FiscalYear_StartDate and m.FiscalYear_EndDate
where include_flg=true
and record_type in ('New','Returning')
)
,total_active_rawdata_prev as (
select sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month_prev m
on s.mon_year = to_char(m.FiscalYear_StartDate,'yyyymm') 
where include_flg=true
and record_type='Starting'
union
select sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month_prev m
on s.mon_lastday between m.FiscalYear_StartDate and m.FiscalYear_EndDate
where include_flg=true
and record_type in ('New','Returning')
)
,net_active_data as (
select dim_month.FiscalYear, count(distinct sfdc_ultimate_parent_id) cnt_customers
from net_active_rawdata
join dim_month
on 1=1
group by dim_month.FiscalYear
)
,net_active_data_prev as (
select dim_month_prev.FiscalYear, count(distinct sfdc_ultimate_parent_id) cnt_customers
from net_active_rawdata_prev
join dim_month_prev
on 1=1
group by dim_month_prev.FiscalYear
)
,total_active_data as (
select dim_month.FiscalYear, count(distinct sfdc_ultimate_parent_id) cnt_customers
from total_active_rawdata
join dim_month
on 1=1
group by dim_month.FiscalYear
)
,total_active_data_prev as (
select dim_month_prev.FiscalYear, count(distinct sfdc_ultimate_parent_id) cnt_customers
from total_active_rawdata_prev
join dim_month_prev
on 1=1
group by dim_month_prev.FiscalYear
)
,contract_based_active_data as (
select dim_month.FiscalYear, count(distinct sfdc_ultimate_parent_id) cnt_customers
from contract_based_active_rawdata
join dim_month
on 1=1
group by dim_month.FiscalYear
)
,contract_based_active_data_prev as (
select dim_month_prev.FiscalYear, count(distinct sfdc_ultimate_parent_id) cnt_customers
from contract_based_active_rawdata_prev
join dim_month_prev
on 1=1
group by dim_month_prev.FiscalYear
)
,datedata as (select least(max(created_date), max(last_modified_date), max(mon_lastday), max(fcms.loaddate)) last_updated from {{ ref("fact_opportunity") }} fo join {{ ref("fact_customers_monthly_snapshots") }} fcms on 1=1)
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


