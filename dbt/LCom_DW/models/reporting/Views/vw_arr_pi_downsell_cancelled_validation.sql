{{ config(materialized='view',
   bind=False
)
 }}
with data as (
select
r.mon_year ,
r.arr_type,
r.bucket,
r.opportunity_id,
sum(r.arr_amount) arr_amount
from {{ ref("fact_arr") }} r
where
bucket in ('Placeholder for Price Increase or Downsell: ARR', 'Placeholder for Price Increase or Downsell: Biz Dev', 'Cancellation: Biz Dev', 'Cancellation: ARR')
and GetDate() between arr_activation_date and arr_deactivation_date
group by all
)
,data_final as (
select 
distinct
mon_year,
data.opportunity_id,
case 
 when bucket ilike '%cancel%' then bucket
 when bucket not ilike '%cancel%' and arr_amount > 0 then replace(bucket,'Placeholder for Price Increase or Downsell:','Price Increase:')
 when bucket not ilike '%cancel%' and arr_amount < 0 then replace(bucket,'Placeholder for Price Increase or Downsell:','Reduction:')
end bucket,
arr_amount
from data
where arr_amount != 0
)
,pivot_data as (
select
    mon_year,
    opportunity_id,
    sum(case when bucket  ilike '%increase%'   then arr_amount else 0 end) as price_increase_calculated,
    sum(case when bucket  ilike '%reduction%'     then arr_amount else 0 end) as downsell_calculated,
    sum(case when bucket  ilike '%cancel%'     then arr_amount else 0 end) as cancelled_calculated
from data_final
group by
    mon_year,
    opportunity_id
)
,joined_data as (
select
mon_year,
fo.opportunity_id,
fo.opportunity_number,
fo.name as opportunity_name,
fo.stage_name,
case when fo.invoiced_date='1900-01-01' then null else fo.invoiced_date end as invoiced_date,
fo.close_date,
fo.start_date,
case when fo.end_date in ('3000-01-01','1900-01-01') then null else fo.end_date end as end_date,
fo.arr,
da.account_id,
da.sfdc_account_id,
da.sfdc_name as account_name,
case when fo.stage_name != 'Closed Lost' then price_increase_calculated  else 0 end price_increase_calculated,
case when fo.stage_name != 'Closed Lost' then fo.price_increase_arr else 0 end price_increase_salesforce,
case when fo.stage_name != 'Closed Lost' then downsell_calculated else 0 end downsell_calculated,
case when fo.stage_name != 'Closed Lost' then fo.downsell  else 0 end downsell_salesforce,
case when fo.stage_name = 'Closed Lost' then cancelled_calculated  else 0 end cancelled_calculated,
case when fo.stage_name = 'Closed Lost' then fo.true_arr_formula else 0 end cancelled_salesforce
from pivot_data as data
join {{ ref("fact_opportunity") }} fo 
on data.opportunity_id = fo.opportunity_id
join {{ ref('dim_account') }} da
on da.account_id = fo.account_id
)
select
mon_year,
opportunity_id,
opportunity_number,
opportunity_name,
stage_name,
invoiced_date,
close_date,
start_date,
end_date,
arr,
account_id,
sfdc_account_id,
account_name,
price_increase_calculated,
price_increase_salesforce,
downsell_calculated,
downsell_salesforce,
cancelled_calculated,
cancelled_salesforce
from joined_data
where 
abs(price_increase_calculated - price_increase_salesforce)>0.1
or
abs(abs(downsell_calculated) - abs(downsell_salesforce))>0.1
or
abs(abs(cancelled_calculated) - abs(cancelled_salesforce))>0.1
