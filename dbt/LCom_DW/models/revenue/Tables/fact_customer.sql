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
select
f.arr_type,
f.mon_year,
f.mon_lastday,
f.fiscalyear,
f.fiscalyear_mon,
f.sfdc_product_id,
c.account_id as customer_id,
bucket, --bucket is needed to exclude true 0 ARR, non-paying customers only
case when f.bucket ilike '%biz dev%' then 'State' else 'District' end as BizDevFlg,
sum(f.arr_amount) arr_amount
from {{ref("fact_arr")}} f
join {{ref("dim_account")}} a
on f.account_id = a.account_id
join {{ref("dim_account")}} c
on a.sfdc_ultimate_parent_id = c.sfdc_account_id
where current_date between f.arr_activation_date and f.arr_deactivation_date
and record_type='ARR'
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
sfdc_product_id,
customer_id,
BizDevFlg,
sum(arr_amount) arr_amount
from total_active
group by all
having sum(arr_amount)>0.01
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
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
customer_id,
BizDevFlg
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
BizDevFlg,
lag(mon_lastday) over( partition by customer_id order by mon_lastday),
datediff(month, lag(mon_lastday) over( partition by customer_id order by mon_lastday),mon_lastday) months_since_prev_ARR,
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
customer_id,
BizDevFlg
from new_returning_data
where record_type in ('New','Returning')
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
,contract_based_active_data as (
select
d.mon_year,
d.mon_lastday,
d.fiscalyear,
d.fiscalyear_mon,
ol.sfdc_product_id,
case when ol.business_type_opty_product ilike '%biz dev%' then 'State' else 'District' end as BizDevFlg,
c.account_id as customer_id
from {{ ref('fact_opportunity') }} o
join {{ ref('dim_opportunity_line') }} ol
on o.opportunity_id = ol.opportunity_id
join {{ ref('dim_account') }} a
on o.account_id = a.account_id
join {{ref("dim_account")}} c
on a.sfdc_ultimate_parent_id = c.sfdc_account_id
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
,monthly_active as 
(
select
f.arr_type,
f.record_type,
f.mon_year,
f.mon_lastday,
f.fiscalyear,
f.fiscalyear_mon,
f.sfdc_product_id,
c.account_id as customer_id,
bucket, --bucket is needed to exclude true 0 ARR, non-paying customers only
case when f.bucket ilike '%biz dev%' then 'State' else 'District' end as BizDevFlg,
sum(f.arr_amount) arr_amount
from {{ ref('fact_arr') }} f
join {{ ref('dim_account') }} a
on f.account_id = a.account_id
join {{ref("dim_account")}} c
on a.sfdc_ultimate_parent_id = c.sfdc_account_id
where current_date between f.arr_activation_date and f.arr_deactivation_date
and record_type!='ARR'
group by all
having sum(f.arr_amount)!=0
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
,Churn as (
select distinct
vfrms.arr_type,
'Churn' record_type,
vfrms.mon_year,
vfrms.mon_lastday,
vfrms.fiscalyear,
vfrms.fiscalyear_mon,
vfrms.sfdc_product_id,
vfrms.BizDevFlg,
vfrms.customer_id
from
monthly_active vfrms
--not active customer anymore
left outer join net_active ah
on ah.customer_id = vfrms.customer_id
and vfrms.mon_year = ah.mon_year
and vfrms.arr_type = ah.arr_type
and vfrms.sfdc_product_id = ah.sfdc_product_id
and vfrms.BizDevFlg = ah.BizDevFlg
-- 
where vfrms.record_type='ARR-MonthlyReduced'
and vfrms.bucket like '%Cancel%'
and ah.customer_id is null
)
,Expired as (
select distinct
vfrms.arr_type,
'Expiration' record_type,
vfrms.mon_year,
vfrms.mon_lastday,
vfrms.fiscalyear,
vfrms.fiscalyear_mon,
vfrms.sfdc_product_id,
vfrms.BizDevFlg,
vfrms.customer_id
from
monthly_active vfrms
--not active customer anymore
left outer join net_active ah
on ah.customer_id = vfrms.customer_id
and vfrms.mon_year = ah.mon_year
and vfrms.arr_type = ah.arr_type
and vfrms.sfdc_product_id = ah.sfdc_product_id
and vfrms.BizDevFlg = ah.BizDevFlg
where 
vfrms.record_type='ARR-MonthlyReduced'
and vfrms.bucket like '%Expir%'
and ah.customer_id is null
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*
 Churn at Product level
 SFDC Product can be replaced to an other one teh same by functionality a.k. old product end of life cycle or removed completly (churn)
 It would make sense if I could relible identify New and Returning at Product level

,NonRenewed as (
select distinct
vfrms.arr_type,
'NonRenewed' record_type,
vfrms.mon_year,
vfrms.mon_lastday,
vfrms.fiscalyear,
vfrms.fiscalyear_mon,
vfrms.sfdc_product_id,
vfrms.BizDevFlg,
vfrms.customer_id
from
monthly_active vfrms
--not active customer anymore
left outer join net_active ah
on ah.customer_id = vfrms.customer_id
and vfrms.mon_year = ah.mon_year
and vfrms.arr_type = ah.arr_type
and vfrms.sfdc_product_id = ah.sfdc_product_id
and vfrms.BizDevFlg = ah.BizDevFlg
where (vfrms.record_type='ARR-MonthlyAdded' and vfrms.bucket like '%Placeholder%' and vfrms.arr_amount<0)
and ah.customer_id is null
)
*/
,data as (
select 
arr_type,
'Total Active' record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
sfdc_product_id,
BizDevFlg,
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
sfdc_product_id,
BizDevFlg,
customer_id
from net_active
union all
select 
arr_type,
record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
'{{ var("default_ID") }}' as sfdc_product_id,
BizDevFlg,
customer_id
from New_Returning
union all
select 
arr_type,
record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
sfdc_product_id,
BizDevFlg,
customer_id
from Churn
union all
select 
arr_type,
record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
sfdc_product_id,
BizDevFlg,
customer_id
from Expired
union all
select
arr_type,
'Contract Active' record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
sfdc_product_id,
BizDevFlg,
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
sfdc_product_id::varchar(300),
BizDevFlg::varchar(10),
customer_id::varchar(300)
,'{{ var("loaddate") }}'::TIMESTAMP WITHOUT TIME ZONE as loaddate
from data
