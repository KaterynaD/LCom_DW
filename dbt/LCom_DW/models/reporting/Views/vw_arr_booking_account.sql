{{ config(materialized='view',
   bind=False
)
 }}
 
with data as (
select 
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon ,
sfdc_account_id as sfdc_account_id,
record_type,
sum(amount) as amount
from {{ ref("vw_fact_revenue_monthly_snapshots") }}
where record_type!='Target'
and include_flg=True
group by 
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon ,
sfdc_account_id,
record_type
)
,mapping as (
select account_id,  sfdc_account_id from {{ ref("dim_account") }} where sfdc_account_id!='Unknown')
,final_data as (
select 
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon ,
a.account_id,
data.sfdc_account_id,
record_type,
amount
from data
join mapping a
on data.sfdc_account_id = a.sfdc_account_id
)
select *
from final_data