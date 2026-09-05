{{
    config(

        materialized='table',        
        dist='customer_id',
        sort='mon_year'
        
        )
}}

with 
total_active as 
(
select distinct
f.arr_type,
f.mon_year,
f.mon_lastday,
f.fiscalyear,
f.fiscalyear_mon,
f.sfdc_product_id,
a.conformed_customer_id as customer_id,
bucket, --bucket is needed to exclude true 0 ARR, non-paying customers only
sum(f.arr_amount) arr_amount
from {{ref("vw_fact_arr")}} f
join {{ref("dim_account")}} a
on f.account_id = a.account_id
where  record_type='ARR'
group by all
having sum(f.arr_amount)!=0
),
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*Only "positive" ARR - no cancellations, expirations,reductions etc in total, no bucket*/
net_active as  
(
select 
arr_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
customer_id,
sfdc_product_id,
sum(arr_amount) arr_amount
from total_active
group by all
having sum(arr_amount)>0.01
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
,contract_based_active_data as (
select
d.mon_year,
d.mon_lastday,
d.fiscalyear,
d.fiscalyear_mon,
a.conformed_customer_id as customer_id,
sfdc_product_id
from {{ ref('fact_opportunity') }} o
join {{ ref('dim_opportunity_line') }} ol
on o.opportunity_id = ol.opportunity_id
join {{ ref('dim_account') }} a
on o.account_id = a.account_id
--Won, invoiced opportunities active at in the month
join {{ ref('dim_month') }} d
on d.mon_lastday between o.start_date and o.end_date
where
o.stage_name ilike '%won%'
and o.invoiced_date!='1900-01-01'
and o.invoiced_date <= current_date
and d.mon_year <= to_char(current_date,'yyyymm')
and (
ol.business_type_opty_product ilike '%arr%' or
ol.business_type_opty_product ilike '%biz_dev%'
)
group by all
having sum(o.amount)>0
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
,months as
(
select 
    mon_year,
    mon_lastday,
    fiscalyear,
    fiscalyear_mon
from {{ ref('dim_month') }}
)
,churn_rawdata as
(
select distinct
    prev.arr_type,
    m_next.mon_year,
    m_next.mon_lastday,
    m_next.fiscalyear,
    m_next.fiscalyear_mon,
    prev.customer_id
from net_active prev
join months m_next
    on m_next.mon_lastday = last_day(dateadd(month, 1, prev.mon_lastday))
left join net_active nxt
    on  prev.arr_type = nxt.arr_type
    and prev.customer_id = nxt.customer_id
    and nxt.mon_lastday = m_next.mon_lastday
where nxt.customer_id is null
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*,new_rawdata as
(
select
    nxt.arr_type,
    nxt.mon_year,
    nxt.mon_lastday,
    nxt.fiscalyear,
    nxt.fiscalyear_mon,
    nxt.customer_id,
    nxt.arr_amount as new_customer_arr_amount
from net_active nxt
left join net_active prev
    on  nxt.arr_type = prev.arr_type
    and nxt.customer_id = prev.customer_id
    and prev.mon_lastday = last_day(dateadd(month, -1, nxt.mon_lastday))
where prev.customer_id is null
)
*/
/*
 New and Returning at Product level requires more effort to implement
 SFDC Product can be replaced to an other one teh same by functionality a.k. old product end of life cycle or a essentially new product added
*/
,new_returning_rawdata as (
select
distinct
arr_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
customer_id
from net_active
)
,new_returning_data as (
select
arr_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
customer_id,
lag(mon_lastday) over( partition by customer_id order by mon_lastday),
datediff(month, lag(mon_lastday) over( partition by arr_type, customer_id order by mon_lastday),mon_lastday) months_since_prev_ARR,
case 
	when months_since_prev_ARR  is null then 'New'
	when months_since_prev_ARR = 1 then 'Existing'
	when months_since_prev_ARR > 1 then 'Returning'
end record_type
from new_returning_rawdata
)
,New_Returning as (
select
arr_type,
record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
customer_id
from new_returning_data
where record_type in ('New','Returning')
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
,data as (
select 
distinct
arr_type,
'Total Active' record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
customer_id
from total_active
union all
select 
arr_type,
'Net Active' record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
customer_id
from net_active
union all
select 
distinct
arr_type,
record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
customer_id
from New_Returning
union all
select 
arr_type,
'Churn' record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
customer_id
from churn_rawdata
union all
select
distinct
arr_type,
'Contract Active' record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
customer_id
from contract_based_active_data
cross join
(
 select distinct ARR_Type from total_active   
)
)
select
arr_type::varchar(20),
record_type::varchar(20),
mon_year::integer,
mon_lastday::date,
fiscalyear::varchar(20),
fiscalyear_mon::integer,
customer_id::varchar(300)
,'{{ var("loaddate") }}'::TIMESTAMP WITHOUT TIME ZONE as loaddate
from data
where mon_year <= to_char(current_date,'yyyymm')::integer
